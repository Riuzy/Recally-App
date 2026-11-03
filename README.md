# RECALLY

Aplikasi flashcard dengan **pengulangan berjarak** (spaced repetition) untuk pelajar SMA, mahasiswa, dan pembelajar bahasa asing.

> Belajar sedikit, ingat lebih lama.

RECALLY membantu kamu menghafal materi dengan kartu belajar dan jadwal pengulangan yang dihitung otomatis. Aplikasi berjalan **local-first**: bisa dipakai offline tanpa akun, dan sinkronisasi cloud hanya untuk cadangan serta pindah perangkat.

---

## Fitur Utama

| Kode | Fitur |
| --- | --- |
| KF-1 | Membuat deck dan kartu depan/belakang |
| KF-2 | Membuat kartu dari teks atau tempelan teks |
| KF-3 | Sesi berisi kartu yang jatuh tempo |
| KF-4 | Penilaian ingatan manual: Lupa / Ragu / Ingat |
| KF-5 | Jadwal pengulangan berikutnya dihitung otomatis |
| KF-6 | Notifikasi pengingat pada jam pilihan |
| KF-7 | Statistik kemajuan dan streak |
| KF-8 | Pelafalan kosakata dengan TTS |
| KF-9 | Ekspor dan impor data |
| KF-10 | Tetap berfungsi tanpa koneksi |

Alur belajar inti: **Tulis Jawaban → Periksa Jawaban → bandingkan "Jawabanmu" dan "Jawaban benar" → nilai Lupa/Ragu/Ingat → ringkasan**. Ada juga **Mode Hafalan** sebagai alternatif tanpa mengetik.

---

## Teknologi

Monorepo menggunakan [pnpm workspaces](https://pnpm.io/workspaces).

| Bagian | Teknologi | Keterangan |
| --- | --- | --- |
| **Mobile (Android-first)** | [Expo](https://expo.dev/) + [React Native](https://reactnative.dev/) + [TypeScript](https://www.typescriptlang.org/), [Expo Router](https://docs.expo.dev/router/introduction/), [expo-sqlite](https://docs.expo.dev/versions/latest/sdk/sqlite/) + [Drizzle ORM](https://orm.drizzle.team/) | UI, navigasi, dan local-first database berbasis SQLite |
| **Backend API** | [Express](https://expressjs.com/) + [TypeScript](https://www.typescriptlang.org/) + [Supabase JS](https://supabase.com/docs/reference/javascript/introduction) | Layanan admin, bukan jalur kritis aplikasi |
| **Database** | [PostgreSQL](https://www.postgresql.org/) via [Supabase](https://supabase.com/) | Sinkronisasi opsional dan penyimpanan akun |
| **Auth** | [Supabase Auth](https://supabase.com/docs/guides/auth) | Email + password, Google opsional |
| **Type Sharing** | [OpenAPI](https://www.openapis.org/) | Kontrak API di `packages/contracts` |

---

## Sistem Desain

Arah visual **v4.0 krem-navy-oranye**: ruang belajar yang tenang dan premium. Bukan template dashboard, bukan AI slop.

- **Satu tema:** light saja. Latar krem `#F4F1EC`, teks navy `#1B2A41`, aksen oranye `#E07A1F` hanya untuk tindakan utama. Tanpa mode gelap dan tanpa pemilih tema.
- **Tipografi:** Inter, ukuran 20 / 16 / 14 / 11.
- **Bentuk:** kartu radius 12, tombol dan chip pill (999), margin layar 20, tombol minimal 48, target sentuh 44×44.
- **Warna penilaian:** Lupa `#F4C7C3`, Ragu `#FCE8A6`, Ingat `#C8EBD7` dengan teks navy.
- **Kedalaman:** datar dan ringan, tanpa gradient, glow, atau bayangan tebal.
- **Spasi:** kelipatan 8.

Acuan lengkap (palet, token, komponen, state, aksesibilitas, anti-slop) ada di [`docs/design/desain.md`](docs/design/desain.md).

---

## Struktur Repositori

```text
Recally-app/
├── README.md
├── .gitignore
├── package.json
├── pnpm-workspace.yaml
├── apps/
│   ├── mobile/      # Expo + React Native app (Recally)
│   └── api/         # Backend: Express, migrasi Postgres, skrip DB
│       ├── scripts/     # db:migrate, db:verify
│       └── supabase/    # migrasi SQL + policy RLS
├── packages/
│   ├── contracts/   # OpenAPI spec
│   └── types/       # Shared TypeScript types
└── docs/
    ├── README.md
    ├── analisis_kebutuhan_recally.md
    ├── flow1.png
    ├── flow2.png
    ├── flow2_triptych.png
    └── design/
        └── desain.md
```

---

## Mulai Pengembangan

### Prasyarat
- [Node.js](https://nodejs.org/) 22+
- [pnpm](https://pnpm.io/) 11+
- [Expo Go](https://expo.dev/go) di perangkat Android, atau emulator Android Studio
- Akun [Supabase](https://supabase.com/) (opsional, hanya untuk API/sinkronisasi)

### Instalasi
```bash
# Install dependencies untuk monorepo (termasuk apps/mobile)
pnpm install

# Terapkan skema Postgres ke Supabase (butuh apps/api/.env)
pnpm db:migrate
pnpm db:verify
```

### Menjalankan Aplikasi

**Mobile (Expo):**
```bash
pnpm mobile            # expo start, lalu pindai QR dengan Expo Go
pnpm mobile:android    # langsung ke emulator/perangkat Android
```

**Pratinjau web (khusus development):**
```bash
pnpm mobile:web
```
Untuk mencoba dengan data contoh, jalankan dengan
`EXPO_PUBLIC_DEMO_SEED=true`, lalu buka **Pengaturan → Isi data contoh**.
Data contoh (satu deck Biologi Sel, 12 kartu, riwayat 7 hari) dibuat secara
idempoten, tidak menduplikasi baris, dan tidak menimpa deck pengguna.

Web memakai SQLite via WASM di dalam Web Worker sehingga butuh header
`Cross-Origin-Embedder-Policy: credentialless` dan
`Cross-Origin-Opener-Policy: same-origin`. Header itu sudah diatur untuk
`expo start --web` dan `expo export --platform web`. Build statis bisa dicoba
dengan:
```bash
# bash
EXPO_PUBLIC_DEMO_SEED=true pnpm mobile:export
```
```powershell
# PowerShell
$env:EXPO_PUBLIC_DEMO_SEED='true'; pnpm mobile:export
```

**Pemeriksaan kode:**
```bash
pnpm mobile:typecheck
pnpm mobile:lint
pnpm mobile:test
```

**API (Express):**
```bash
cd apps/api
pnpm dev
```

---

## Konfigurasi

- **Package ID (Android):** `com.recally.app`
- **App Name:** `Recally`
- **Tema:** Light saja, palet krem-navy-oranye v4.0. Tanpa mode gelap.
- **Auth & sinkronisasi:** Ditunda untuk versi Expo ini. Aplikasi berjalan penuh secara lokal tanpa akun dan tanpa koneksi.
- **Data:** Local-first di SQLite perangkat. Kolom `dirty` dan `deleted_at` sudah disiapkan untuk sinkronisasi berikutnya.

---

## Catatan

- Bagian palet di `docs/analisis_kebutuhan_recally.md` bersifat historis dan sudah digantikan oleh `docs/design/desain.md`.
- Migrasi Flutter → Expo tetap tersimpan di riwayat git; source Flutter lama ada di commit sebelum migrasi.
- Auth dan sinkronisasi Supabase belum aktif di aplikasi mobile. API/Postgres tetap ada untuk pekerjaan berikutnya.
- Data lokal adalah default. Sinkronisasi cloud tidak pernah menjadi gerbang aplikasi.
