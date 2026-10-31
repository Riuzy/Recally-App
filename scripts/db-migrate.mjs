// Menjalankan migrasi SQL Recally ke Postgres/Supabase.
//
//   pnpm db:migrate
//
// Membaca DIRECT_URL dari apps/api/.env (atau environment). Setiap file di
// supabase/migrations dijalankan sekali dan dicatat di public.schema_migrations,
// jadi aman dijalankan berulang.
import { readFileSync, readdirSync } from 'node:fs';
import { join } from 'node:path';
import pg from 'pg';

const repoRoot = new URL('..', import.meta.url).pathname.replace(/^\/([A-Za-z]:)/, '$1');
const migrationsDir = join(repoRoot, 'supabase', 'migrations');

function readDotEnv() {
  try {
    const raw = readFileSync(join(repoRoot, 'apps', 'api', '.env'), 'utf8');
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

await client.query(`
  create table if not exists public.schema_migrations (
    name text primary key,
    applied_at timestamptz not null default now()
  )
`);

const applied = new Set(
  (await client.query('select name from public.schema_migrations')).rows.map((r) => r.name),
);
const files = readdirSync(migrationsDir).filter((f) => f.endsWith('.sql')).sort();
const pending = files.filter((f) => !applied.has(f));

if (pending.length === 0) {
  console.log(`Tidak ada migrasi baru (${files.length} sudah diterapkan).`);
} else {
  for (const file of pending) {
    const sql = readFileSync(join(migrationsDir, file), 'utf8');
    process.stdout.write(`Menerapkan ${file} ... `);
    try {
      await client.query('begin');
      await client.query(sql);
      await client.query('insert into public.schema_migrations (name) values ($1)', [file]);
      await client.query('commit');
      console.log('ok');
    } catch (error) {
      await client.query('rollback');
      console.log('gagal');
      console.error(error.message);
      await client.end();
      process.exit(1);
    }
  }
}

const tables = await client.query(`
  select table_name from information_schema.tables
  where table_schema = 'public' and table_name in ('decks', 'cards', 'reviews')
  order by table_name
`);
console.log('Tabel tersedia:', tables.rows.map((r) => r.table_name).join(', ') || '(kosong)');

await client.end();
