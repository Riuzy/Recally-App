// Memeriksa bahwa Row Level Security benar-benar menahan data antar pengguna.
//
//   cd apps/api
//   pnpm db:verify
//
// Mensimulasikan sesi `authenticated` dengan dua user id berbeda, tanpa
// memerlukan akun sungguhan. Keluar dengan kode 1 kalau ada kebocoran.
import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import pg from 'pg';

// Script ini berada di apps/api/scripts.
const apiRoot = fileURLToPath(new URL('..', import.meta.url));

function readDotEnv() {
  try {
    const raw = readFileSync(join(apiRoot, '.env'), 'utf8');
    const values = {};
    for (const line of raw.split(/\r?\n/)) {
      const match = /^([A-Z0-9_]+)=(.*)$/.exec(line.trim());
      if (match) values[match[1]] = match[2].replace(/^"|"$/g, '');
    }
    return values;
  } catch {
    return {};
  }
}

const dotenv = readDotEnv();
const connectionString =
  process.env.DIRECT_URL || process.env.DATABASE_URL || dotenv.DIRECT_URL || dotenv.DATABASE_URL;

if (!connectionString) {
  console.error('DIRECT_URL/DATABASE_URL tidak ditemukan. Isi apps/api/.env dulu.');
  process.exit(1);
}

const client = new pg.Client({ connectionString, ssl: { rejectUnauthorized: false } });
await client.connect();

const failures = [];
const check = (label, ok, detail) => {
  console.log(`${ok ? 'LULUS' : 'GAGAL'}  ${label}${detail ? ` — ${detail}` : ''}`);
  if (!ok) failures.push(label);
};

const rls = await client.query(`
  select relname, relrowsecurity from pg_class
  where relnamespace = 'public'::regnamespace and relname in ('decks', 'cards', 'reviews')
  order by relname
`);
for (const row of rls.rows) {
  check(`RLS aktif di ${row.relname}`, row.relrowsecurity);
}

const userA = '11111111-1111-1111-1111-111111111111';
const userB = '22222222-2222-2222-2222-222222222222';

await client.query('begin');
await client.query('set local role authenticated');
await client.query(`set local request.jwt.claims = '{"sub":"${userA}"}'`);

const visible = await client.query('select count(*)::int as n from decks');
check('user A hanya melihat deck miliknya', visible.rows[0].n === 0, `${visible.rows[0].n} baris`);

let rejected = false;
try {
  await client.query(
    `insert into decks (id, user_id, name, created_at, updated_at)
     values (gen_random_uuid(), $1, 'curang', now(), now())`,
    [userB],
  );
} catch (error) {
  rejected = error.code === '42501';
}
check('insert dengan user_id orang lain ditolak', rejected);

await client.query('rollback');
await client.end();

if (failures.length > 0) {
  console.error(`\n${failures.length} pemeriksaan gagal.`);
  process.exit(1);
}

console.log('\nSemua pemeriksaan RLS lulus.');
