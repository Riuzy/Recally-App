# Setup Firebase — Recally

Dokumen ini mencatat langkah menghubungkan Recally ke Firebase. Sebagian langkah
butuh akun Google pemilik project, jadi tidak bisa diotomatiskan lewat repo.

## Prasyarat

- Node.js 22+ dan pnpm
- Dart/Flutter SDK
- Akun Google

## 1. Pasang tooling

```bash
# Firebase CLI
pnpm add -g firebase-tools

# FlutterFire CLI
dart pub global activate flutterfire_cli
```

Kedua tool menaruh executable di folder yang mungkin belum ada di `PATH`:

| Tool | Lokasi default di Windows |
| --- | --- |
| `firebase` | `C:\Users\<user>\AppData\Local\pnpm\bin` |
| `flutterfire` | `C:\Users\<user>\AppData\Local\Pub\Cache\bin` |

Kalau `firebase` atau `flutterfire` tidak dikenali, jalankan `pnpm setup` lalu
restart terminal, atau panggil lewat path lengkap.

## 2. Login

```bash
firebase login
```

Perintah ini membuka browser. Selesaikan login dengan akun Google yang akan
menjadi pemilik project.

## 3. Buat project Firebase

Lewat [console.firebase.google.com](https://console.firebase.google.com):

1. **Add project** → nama `Recally`
2. Google Analytics: **matikan** (tidak dipakai)
3. Catat **Project ID** (contoh: `recally-1a2b3`). ID ini dipakai di langkah 5.

## 4. Aktifkan layanan

| Layanan | Langkah |
| --- | --- |
| **Authentication** | Sign-in method → **Google** → Enable → simpan |
| **Firestore Database** | Create database → **Production mode** → region `asia-southeast2` (Jakarta) |

Production mode dipilih supaya tidak ada akses terbuka. Aturan akses sudah
disiapkan di `firestore.rules` dan wajib di-deploy (langkah 7).

## 5. Hubungkan app ke project

Dari folder `apps/mobile`:

```bash
flutterfire configure --project=<PROJECT_ID>
```

Perintah ini menghasilkan:

- `apps/mobile/lib/firebase_options.dart`
- `apps/mobile/android/app/google-services.json`

Pilih platform **android** saja saat diminta.

## 6. Daftarkan SHA-1 (wajib untuk Google Sign-In)

```bash
keytool -list -v -alias androiddebugkey ^
  -keystore "%USERPROFILE%\.android\debug.keystore" ^
  -storepass android -keypass android
```

Ambil baris **SHA1**, lalu di console: *Project settings → Your apps → Android →
Add fingerprint*.

Tanpa langkah ini, Google Sign-In akan gagal dengan error `ApiException: 10`.

## 7. Deploy aturan dan index

```bash
firebase deploy --only firestore:rules,firestore:indexes --project=<PROJECT_ID>
```

File yang dipakai:

| File | Isi |
| --- | --- |
| `firebase.json` | menunjuk ke rules dan indexes |
| `firestore.rules` | user hanya bisa mengakses `users/{uid}/**` miliknya |
| `firestore.indexes.json` | index untuk query sync `updatedAt` / `reviewedAt` |

## 8. Struktur data

```text
users/{uid}
├── profile          { name, email, updatedAt }
├── decks/{deckId}   { name, description, createdAt, updatedAt, deletedAt }
│   └── cards/{cardId}  { deckId, front, back, dueAt, intervalDays, ease,
│                         reps, lapses, createdAt, updatedAt, deletedAt }
└── reviews/{reviewId}  { cardId, rating, reviewedAt, prevInterval, newInterval }
```

## Catatan keamanan

- `google-services.json` **boleh** di-commit; isinya konfigurasi client, bukan
  rahasia server.
- **Service account key** untuk `apps/api` **tidak boleh** di-commit. Simpan di
  environment variable `GOOGLE_APPLICATION_CREDENTIALS`.
- `firebase_options.dart` juga boleh di-commit (berisi API key client).

## Tanpa login

Recally tetap berfungsi penuh tanpa akun. Firestore hanya dipakai untuk
sinkronisasi opsional; data lokal (Drift) adalah sumber kebenaran.
