# Setup Supabase — Recally

Supabase dipakai **hanya untuk akun dan sinkronisasi opsional**. Data lokal
(Drift/SQLite) tetap sumber kebenaran dan aplikasi berjalan penuh tanpa
konfigurasi ini.

## Peran tiap lapisan

```text
Flutter (Drift = sumber kebenaran)
   ├── baca/tulis lokal, tanpa jaringan
   └── SyncService ──► PostgREST + RLS ──► Postgres (Supabase)
        └── auth: Supabase Auth (email, Google opsional)

apps/api (Express) ──► service role key ──► Postgres (admin saja)
```

Aplikasi mobile **tidak** membuka koneksi SQL langsung. Semua lewat PostgREST,
sehingga Row Level Security selalu berlaku.

## 1. Buat project

1. [supabase.com](https://supabase.com) → **New project**
2. Region: **Southeast Asia (Singapore)**
3. Simpan **database password** di tempat aman
4. Catat **Project URL** dan **anon key** dari *Project Settings → API*

Catatan free tier: project **di-pause setelah 7 hari tanpa aktivitas**. Untuk
aplikasi harian tidak masalah; kalau lama ditinggal, permintaan pertama akan
lambat.

## 2. Jalankan skema

Cara utama (tanpa perlu Supabase CLI):

```powershell
# butuh apps/api/.env berisi DIRECT_URL
cd apps/api
pnpm db:migrate

# opsional: pastikan RLS menahan data antar pengguna
pnpm db:verify
```

Dari root repo juga bisa lewat alias: `pnpm db:migrate` / `pnpm db:verify`.

`db:migrate` menjalankan semua file di `apps/api/supabase/migrations` yang belum
pernah diterapkan, dicatat di tabel `public.schema_migrations`, sehingga aman
diulang.

Alternatif dengan Supabase CLI (dari `apps/api`):

```powershell
supabase link --project-ref <project-ref>
supabase db push
```

Isi migrasi:

| Tabel | Keterangan |
| --- | --- |
| `decks` | nama, deskripsi, `updated_at`, `deleted_at` |
| `cards` | isi kartu, jadwal SRS, milik satu deck |
| `reviews` | riwayat ulasan, append-only |

Ketiganya punya `user_id → auth.users` dan RLS `auth.uid() = user_id`.

## 3. Aktifkan login

**Email + password** sudah aktif secara default (`Authentication → Providers →
Email`). Untuk pengembangan awal, ini yang paling cepat: tidak perlu Google
Cloud.

**Google (opsional, nanti):**

1. Google Cloud Console → *APIs & Services → Credentials* → **Create OAuth
   client ID** → **Web application**
2. Authorized redirect URI: `https://<project-ref>.supabase.co/auth/v1/callback`
3. Salin Client ID + Client Secret ke *Authentication → Providers → Google*
4. Daftarkan juga **Android OAuth client** dengan package
   `com.kyriez.recally` dan SHA-1 debug

Login Google di aplikasi memakai `signInWithIdToken`, jadi `GOOGLE_WEB_CLIENT_ID`
harus diisi dengan Client ID web di atas.

## 4. Konfigurasi aplikasi

Buat `apps/mobile/env.json` (tidak di-commit) dari contoh:

```powershell
Copy-Item apps/mobile/env.example.json apps/mobile/env.json
```

Isi nilainya, lalu jalankan:

```powershell
cd apps/mobile
flutter run --dart-define-from-file=env.json
```

`SUPABASE_ANON_KEY` menerima anon key lama maupun key baru berformat
`sb_publishable_...`; keduanya aman dibundel karena akses dibatasi RLS.

Tanpa `env.json`, aplikasi tetap berjalan: `SupabaseConfig.isConfigured` bernilai
`false` dan semua fitur cloud dinonaktifkan dengan rapi.

## 5. Cara kerja sinkronisasi

| Langkah | Detail |
| --- | --- |
| Push | Baris `dirty = true` di-`upsert` per tabel: deck → kartu → review |
| Pull | `updated_at >= kursor` (atau `reviewed_at` untuk review), urut naik |
| Konflik | Last-write-wins berdasarkan `updated_at` |
| Hapus | Soft delete `deleted_at`, ikut tersalin dua arah |
| Kursor | `last_pulled_decks/cards/reviews` di tabel `sync_states` lokal |

Review bersifat append-only: `upsert` dengan `ignoreDuplicates`, dan RLS tidak
mengizinkan update.

## 6. Admin API

`apps/api` memakai `@supabase/supabase-js` dengan **service role key**. Kunci
itu **hanya** boleh ada di `.env` server, tidak pernah di aplikasi mobile:

```
SUPABASE_URL=https://<project-ref>.supabase.co
SUPABASE_SERVICE_ROLE_KEY=<service-role-key>
```

## Catatan keamanan

- **Anon key** boleh dibundel di aplikasi. Keamanan bergantung pada RLS, bukan
  pada kerahasiaan kunci.
- **Service role key** melewati RLS. Jangan pernah dikirim ke klien.
- RLS wajib diuji: login sebagai pengguna A, pastikan data B tidak terbaca.
- `env.json` dan `.env` sudah masuk `.gitignore`.
