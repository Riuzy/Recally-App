# Rencana Pengerjaan — Recally

Dokumen ini adalah urutan kerja yang disepakati setelah fondasi selesai. Acuan
visual tetap [`design/desain.md`](./design/desain.md); dokumen ini hanya mengatur
**apa dikerjakan lebih dulu dan kapan dianggap selesai**.

## Status fondasi

| Bagian | Status |
| --- | --- |
| Monorepo, Flutter, theme light/dark | ✅ selesai |
| Android build (JDK 25, Gradle 9.8.2, AGP 9.4.1) | ✅ `flutter build apk` hijau |
| Drift: `decks`, `cards`, `reviews`, `sync_states` + kolom sync | ✅ selesai |
| Repository deck & kartu + `applyReview` transaksional | ✅ selesai |
| SRS engine (Lupa/Ragu/Ingat) + 9 unit test | ✅ selesai |
| Firebase project, Auth, Firestore, rules | ✅ terpasang & ter-deploy |
| Bootstrap Firebase + `AuthRepository` | ✅ selesai |
| **UI aplikasi** | ❌ belum ada (masih layar kosong) |
| Google Sign-In provider | ❌ belum diaktifkan di console |

## Prinsip yang tidak boleh dilanggar

1. **Local-first.** Semua fitur inti jalan tanpa akun dan tanpa jaringan.
   Firebase tidak pernah menjadi gerbang masuk aplikasi.
2. **Alur belajar inti tidak diubah.** Tulis Jawaban → Periksa Jawaban →
   bandingkan → Lupa/Ragu/Ingat → ringkasan.
3. **`design/desain.md` sumber kebenaran visual.** Tidak ada warna, radius,
   bayangan, atau tipografi di luar token.
4. **Data lokal tidak pernah dihapus** oleh login, logout, atau kegagalan sync.

---

## Milestone 1 — Aplikasi bisa dipakai offline

Target: membuat deck, mengisi kartu, belajar, dan mengulang — tanpa akun.

### 1.1 Komponen design system

| # | Komponen | Catatan |
| --- | --- | --- |
| 1 | `AppButton` (primary, secondary, ghost, destructive) | state pressed/disabled/loading |
| 2 | `AppTextField` | label, helper, error, counter |
| 3 | `AppCard` | varian surface & elevated, border tipis |
| 4 | `AppChip` | filter deck, status |
| 5 | `AppBottomSheet` | radius 28, hanya di sini dan bottom nav boleh glass |
| 6 | `AppEmptyState` | ikon + judul + satu aksi |
| 7 | `AppSnackBar` / inline banner | error ringan, bukan dialog |
| 8 | Token tambahan | spacing scale, durasi animasi, elevation |

**Selesai bila:** semua komponen punya varian light & dark, tidak ada nilai
hardcoded di luar `AppColors`/`AppThemeExtension`, dan dites minimal satu widget
test per komponen bervarasi penting.

### 1.2 Shell navigasi

| # | Tugas |
| --- | --- |
| 1 | `StatefulShellRoute` go_router dengan 4 tab: Hari Ini, Deck, Progres, Pengaturan |
| 2 | Bottom navigation glass, state aktif jelas di light & dark |
| 3 | `themeMode` provider + persist pilihan (Ikuti sistem / Terang / Gelap) |
| 4 | Placeholder layar untuk 4 tab (bukan teks kosong; pakai `AppEmptyState`) |

**Selesai bila:** pindah tab tidak kehilangan state, tema bertahan setelah app
ditutup, dan tidak ada overflow di layar kecil.

### 1.3 Deck & kartu (KF-1, KF-2)

| # | Tugas |
| --- | --- |
| 1 | Daftar deck + buat/ubah/hapus (soft delete lewat `deletedAt`) |
| 2 | Detail deck: daftar kartu, tambah/ubah/hapus kartu |
| 3 | Tempel teks untuk membuat banyak kartu (pisah baris `depan;belakang`) |
| 4 | Hitungan kartu per deck dan badge "jatuh tempo" |

**Selesai bila:** CRUD penuh offline, hapus deck ikut menyembunyikan kartunya,
dan validasi menolak kartu kosong.

### 1.4 Hari Ini + sesi belajar (KF-3, KF-4, KF-5)

| # | Tugas |
| --- | --- |
| 1 | Hari Ini: jumlah kartu jatuh tempo, streak, tombol "Mulai belajar" |
| 2 | Layar sesi: Tulis Jawaban → Periksa Jawaban |
| 3 | Layar bandingkan: "Jawabanmu" vs "Jawaban benar" |
| 4 | Tiga tombol penilaian memanggil `CardRepository.applyReview` |
| 5 | Ringkasan sesi: jumlah kartu, akurasi, tombol selesai |
| 6 | Mode Hafalan (tanpa mengetik) sebagai jalur alternatif |

**Selesai bila:** menyelesaikan satu sesi mengubah `dueAt` sesuai
`SrsEngine`, dan kartu "Lupa" muncul lagi setelah 10 menit.

---

## Milestone 2 — Rasa aplikasi selesai

### 2.1 Progres (KF-7)

- Ringkasan: total kartu, kartu dikuasai, jatuh tempo hari ini.
- Streak harian dari tabel `reviews` (bukan tabel baru).
- Grafik 7/30 hari: ulasan per hari.
- Per-deck: progres dan jumlah kartu.

**Selesai bila:** angka konsisten dengan isi tabel `reviews` dan tetap benar
setelah app dibuka-tutup.

### 2.2 Pengaturan

- Tema (sudah ada dari 1.2).
- Jam pengingat + izin notifikasi.
- Bahasa pelafalan TTS.
- Ekspor/impor (lihat 2.4).
- Baris "Akun & Sinkronisasi" → membuka layar opsional (Milestone 3).

### 2.3 Notifikasi (KF-6)

- `flutter_local_notifications` + `timezone`.
- Penjadwalan harian berulang pada jam pilihan.
- Penjadwalan ulang setelah reboot/perubahan jam.
- Tidak ada notifikasi kalau tidak ada kartu jatuh tempo.

**Selesai bila:** notifikasi muncul di jam yang dipilih dan tetap ada setelah
perangkat restart.

### 2.4 Ekspor & impor (KF-9)

- Ekspor JSON (deck + kartu, tanpa data akun) lewat share sheet.
- Impor dengan dua mode: gabung atau ganti.
- Validasi file: tolak versi tak dikenal, jangan pernah menimpa data diam-diam.

---

## Milestone 3 — Cloud opsional

### 3.1 Sinkronisasi Drift ⇄ Firestore

| # | Tugas |
| --- | --- |
| 1 | `SyncService.push()`: kirim baris `dirty = true` (deck → kartu → review) per batch |
| 2 | `SyncService.pull()`: ambil `updatedAt > lastPulledAt`, last-write-wins |
| 3 | Propagasi soft delete (`deletedAt`) dua arah |
| 4 | Simpan `lastPulledAt` di `sync_states` |
| 5 | Status sync di UI: belum login, tersinkron, menunggu, gagal |
| 6 | Sync dipicu manual + saat app dibuka, tidak ada listener realtime |

Catatan: `firestore.rules` mewajibkan semua field kartu ada saat create/update.
Mapper harus selalu menulis field lengkap, termasuk `deckId` yang cocok dengan
dokumen induk.

**Selesai bila:** dua perangkat dengan akun sama berakhir di data identik,
perubahan offline tetap terkirim setelah online, dan logout tidak menghapus
data lokal.

### 3.2 Layar Akun

- Login Google, tampil nama/email/foto, tombol logout.
- Penjelasan singkat: "Data tetap tersimpan di perangkat setelah logout".
- Kalau Firebase gagal init, layar ini menampilkan pesan, bukan crash.

**Prasyarat:** provider Google aktif dan `googleServerClientId` terisi di
`lib/core/firebase/firebase_config.dart`.

### 3.3 Admin API (`apps/api`)

- Hapus Prisma dan seluruh referensi PostgreSQL.
- `firebase-admin` dengan `GOOGLE_APPLICATION_CREDENTIALS`.
- Endpoint: `GET /admin/health`, `GET /admin/stats`, `GET /admin/users`.
- Verifikasi Firebase ID token pada setiap request.

**Selesai bila:** server jalan tanpa database relasional dan menolak request
tanpa token valid.

---

## Milestone 4 — Rilis

- Ikon aplikasi + splash (dari `assets/icons`, `assets/images`).
- Keystore release + daftarkan SHA-1 release ke Firebase.
- `flutter build appbundle --release`, periksa ukuran.
- Uji di perangkat fisik: offline, notifikasi, TTS, login.
- README dan `docs/setup/firebase.md` diperbarui.

---

## Urutan yang disarankan

```text
1.1 → 1.2 → 1.3 → 1.4   (offline usable)   ← mulai di sini
2.1 → 2.2 → 2.3 → 2.4   (lengkap)
3.1 → 3.2 → 3.3         (cloud opsional)
4                        (rilis)
```

Milestone 3 sengaja ditaruh setelah UI karena backend-nya sudah siap dan tidak
memblokir apa pun; pengguna tetap bisa memakai aplikasi penuh tanpa akun.

## Blocker aktif

| Blocker | Dampak | Tindakan |
| --- | --- | --- |
| Provider Google belum aktif | `signInWithGoogle` gagal, `oauth_client` kosong di `google-services.json` | Aktifkan di Firebase Console |
| `googleServerClientId` masih kosong | ID token tidak keluar di Android | Isi setelah provider aktif |

Selain dua hal itu, seluruh Milestone 1–2 tidak punya ketergantungan eksternal.
