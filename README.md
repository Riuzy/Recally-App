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
| **Mobile (Android-first)** | [Flutter](https://flutter.dev/) + [Dart](https://dart.dev/), [Riverpod](https://riverpod.dev/), [go_router](https://pub.dev/packages/go_router), [Drift](https://drift.simonbinder.eu/) | UI, state management, navigasi, dan local-first database |
| **Backend API** | [Express](https://expressjs.com/) + [TypeScript](https://www.typescriptlang.org/) + [Supabase JS](https://supabase.com/docs/reference/javascript/introduction) | Layanan admin, bukan jalur kritis aplikasi |
| **Database** | [PostgreSQL](https://www.postgresql.org/) via [Supabase](https://supabase.com/) | Sinkronisasi opsional dan penyimpanan akun |
| **Auth** | [Supabase Auth](https://supabase.com/docs/guides/auth) | Email + password, Google opsional |
| **Type Sharing** | [OpenAPI](https://www.openapis.org/) | Kontrak API di `packages/contracts` |

---

## Sistem Desain

Arah visual: **AI sleek** — presisi, kontras tinggi, dan tenang. Bukan template dashboard, bukan AI slop.

- **Dua tema penuh:** light dan dark. Default mengikuti preferensi sistem, dengan override manual di Pengaturan (Ikuti sistem / Terang / Gelap).
- **Tipografi:** SF Pro / San Francisco. SF Pro Display untuk teks 20px ke atas, SF Pro Text untuk di bawahnya.
- **Aksen:** electric blue, dipakai sangat terbatas dan terkontrol.
- **Bentuk:** kartu 16px, tombol/input 12px, chip 10px, bottom sheet 28px.
- **Elevasi:** dark memakai border tipis + satu glow; light memakai border + shadow sangat lembut.
- **Glass:** hanya pada bottom navigation dan bottom sheet.

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
│   ├── mobile/      # Flutter app (Recally)
│   └── api/         # Express + TypeScript (layanan admin Supabase)
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
- [Flutter](https://docs.flutter.dev/get-started/install) 3.38+ 
- [Node.js](https://nodejs.org/) 22+
- [pnpm](https://pnpm.io/) 11+
- Akun [Supabase](https://supabase.com/) (opsional, hanya untuk sinkronisasi)

### Instalasi
```bash
# Install dependencies untuk monorepo
pnpm install

# Terapkan skema Postgres ke Supabase (butuh apps/api/.env)
pnpm db:migrate
pnpm db:verify

# Install dependencies Flutter
cd apps/mobile
flutter pub get
```

### Menjalankan Aplikasi

**Mobile (Flutter):**
```bash
cd apps/mobile
flutter run --dart-define-from-file=env.json
```
Tanpa `env.json`, aplikasi tetap berjalan penuh secara lokal (tanpa akun/sync).

**API (Express):**
```bash
cd apps/api
pnpm dev
```

---

## Konfigurasi

- **Package ID (Android):** `com.kyriez.recally`
- **App Name:** `Recally`
- **Tema:** Light/Dark dengan mengikuti preferensi sistem (bisa diubah manual di Pengaturan)
- **Auth:** Opsional. Aplikasi tetap bisa dipakai offline tanpa akun.
- **Data:** Local-first. Data lokal tidak akan dihapus saat login/logout.

---

## Catatan

- Bagian palet di `docs/analisis_kebutuhan_recally.md` bersifat historis dan sudah digantikan oleh `docs/design/desain.md`.
- Auth bersifat opsional; aplikasi tetap bisa dipakai offline tanpa akun.
- Data lokal adalah default. Sinkronisasi cloud tidak pernah menjadi gerbang aplikasi.
