# Setup Firebase — Recally

Dokumen ini mencatat status koneksi Recally ke Firebase dan langkah yang masih
butuh akun Google pemilik project.

## Ringkasan project

| Item | Nilai |
| --- | --- |
| Nama tampilan | `recally-app` |
| Project ID | `recally-app-f1f3f` |
| Project number | `1001950032387` |
| Android app ID | `1:1001950032387:android:8b1459217c9ea6da7c9436` |
| Package name | `com.kyriez.recally` |
| SHA-1 debug | `21:DF:1D:ED:CE:C8:B3:3D:C7:E6:60:88:68:10:89:22:B6:7B:9D:2F` |
| Database Firestore | `projects/recally-app-f1f3f/databases/(default)` — STANDARD, Firestore Native |
| Region Firestore | `asia-southeast2` (Jakarta) |

`.firebaserc` di root repo sudah menunjuk `default` → `recally-app-f1f3f`.

## Status

| Langkah | Status |
| --- | --- |
| Firebase CLI terpasang & login | ✅ `15.34.1`, akun `makabegamecarft@gmail.com` |
| Project dibuat | ✅ `recally-app-f1f3f` |
| Android app terdaftar | ✅ lewat `flutterfire configure` |
| `firebase_options.dart` | ✅ `apps/mobile/lib/firebase_options.dart` |
| `google-services.json` | ✅ `apps/mobile/android/app/google-services.json` |
| SHA-1 debug terdaftar | ✅ lewat `firebase apps:android:sha:create` |
| Build APK dengan Firebase | ✅ `flutter build apk --debug` |
| Cloud Firestore API aktif | ✅ |
| Database Firestore dibuat | ✅ `(default)`, region `asia-southeast2` |
| Rules di-deploy | ✅ `firebase deploy --only firestore:rules` |
| Indexes di-deploy | ✅ (file kosong — lihat catatan di bawah) |
| **Provider Google diaktifkan** | ✅ |
| **Web client ID diisi di `firebase_config.dart`** | ✅ |

## Verifikasi cepat

```powershell
# Database ada
firebase firestore:databases:list --project=recally-app-f1f3f

# Provider Google aktif (oauth_client tipe 3 harus muncul)
firebase apps:sdkconfig android 1:1001950032387:android:8b1459217c9ea6da7c9436 --project=recally-app-f1f3f
```

Nilai yang dipakai app:

| Item | Nilai |
| --- | --- |
| Web client ID (`client_type: 3`) | `1001950032387-j3rpdvvjrshs7ps1ohot3jlb92q47c0a.apps.googleusercontent.com` |
| Android client ID (`client_type: 1`) | `1001950032387-mfnki9og2274iqdhdbmdfed1aess0p4j.apps.googleusercontent.com` |

### Kenapa `firestore.indexes.json` kosong

Query sinkronisasi hanya memakai satu field (`updatedAt > lastPulledAt`,
`reviewedAt > lastPulledAt`). Firestore membuat index single-field otomatis,
dan API-nya menolak index single-field yang dideklarasikan manual:

```
400 this index is not necessary, configure using single field index controls
```

Index manual di file itu baru diperlukan kalau nanti ada query gabungan, misal
`deckId == x` + urut `dueAt`.

## Konfigurasi Google Sign-In

Mengaktifkan provider Google membuat *Web OAuth client* di project. Client ID
itu wajib diisi supaya Google Sign-In di Android menghasilkan ID token yang
diterima Firebase Auth. Langkah yang sudah dilakukan:

1. Ambil konfigurasi Android:
   `firebase apps:sdkconfig android 1:1001950032387:android:8b1459217c9ea6da7c9436 --project=recally-app-f1f3f`
2. Ambil `oauth_client` dengan `"client_type": 3`.
3. Isi `googleServerClientId` di `apps/mobile/lib/core/firebase/firebase_config.dart`.
4. Simpan hasil `sdkconfig` sebagai `apps/mobile/android/app/google-services.json`
   (sekarang sudah memuat OAuth client Android dan Web).

Kalau nanti `googleServerClientId` dikosongkan, `AuthRepository.signInWithGoogle`
akan melempar `GoogleSignInTokenException`.

`client_type: 1` (Android) memuat `certificate_hash` — pastikan itu sama dengan
SHA-1 terdaftar. Kalau berbeda, Google Sign-In gagal dengan `ApiException: 10`.

## Tooling

```powershell
# Firebase CLI (dipasang lewat npm karena bin pnpm belum ada di PATH)
npm install -g firebase-tools

# FlutterFire CLI
dart pub global activate flutterfire_cli
```

| Tool | Lokasi di Windows |
| --- | --- |
| `firebase` | `C:\Users\<user>\AppData\Roaming\npm\firebase.ps1` |
| `flutterfire` | `C:\Users\<user>\AppData\Local\Pub\Cache\bin\flutterfire.bat` |

`flutterfire` belum masuk `PATH`; panggil lewat path lengkap kalau perlu.

Perintah yang sudah dijalankan untuk menghubungkan app:

```powershell
cd apps/mobile
flutterfire configure --project=recally-app-f1f3f --platforms=android --yes
```

## SHA-1

Debug keystore (dipakai `flutter run` dan build debug):

```powershell
& "D:\Apk\Android\Android Studio\jbr\bin\keytool.exe" -list -v `
  -alias androiddebugkey `
  -keystore "$env:USERPROFILE\.android\debug.keystore" `
  -storepass android -keypass android
```

Daftarkan hasilnya tanpa membuka console:

```powershell
firebase apps:android:sha:create 1:1001950032387:android:8b1459217c9ea6da7c9436 `
  <SHA1> --project=recally-app-f1f3f

firebase apps:android:sha:list 1:1001950032387:android:8b1459217c9ea6da7c9436 `
  --project=recally-app-f1f3f
```

Saat rilis, tambahkan juga SHA-1 dari keystore release. Tanpa itu Google
Sign-In di build rilis gagal dengan error `ApiException: 10`.

## Catatan build Android

`google_sign_in_android` 7.2.11 — versi terakhir yang masih kompatibel dengan
Flutter 3.38 — masih memakai plugin `kotlin-android`, sementara AGP 9 sudah
punya Kotlin bawaan. Karena itu `apps/mobile/android/gradle.properties` memuat:

```properties
android.builtInKotlin=false
```

dan `org.jetbrains.kotlin.android` diaplikasikan manual di `settings.gradle.kts`
serta `app/build.gradle.kts`, dengan `jvmTarget` disamakan ke 17. Hapus
opt-out ini setelah Flutter dan `google_sign_in_android` mendukung AGP 9
(butuh Flutter ≥ 3.44).

## Struktur data

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
- `firebase_options.dart` juga boleh di-commit (berisi API key client).
- **Service account key** untuk `apps/api` **tidak boleh** di-commit. Simpan di
  luar repo dan arahkan lewat environment variable
  `GOOGLE_APPLICATION_CREDENTIALS`. Pola `serviceAccountKey*.json` sudah masuk
  `.gitignore`.

## Tanpa login

Recally tetap berfungsi penuh tanpa akun. Firestore hanya dipakai untuk
sinkronisasi opsional; data lokal (Drift) adalah sumber kebenaran.
