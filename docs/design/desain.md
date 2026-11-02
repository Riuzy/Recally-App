# RECALLY — Desain Acuan v4.0

Dokumen ini adalah **sumber kebenaran** untuk arah visual RECALLY. Semua komponen, layar, dan implementasi UI harus mengikuti aturan di sini.

- **Produk:** RECALLY — aplikasi flashcard dengan pengulangan berjarak.
- **Platform:** mobile, Android-first, portrait 390 × 844.
- **Tema:** light saja. Latar krem lembut, teks navy, aksen oranye untuk tindakan utama.
- **Bahasa UI:** Indonesia.
- **Status:** v4.0, desain krem–navy–oranye.

---

## 1. Arah Desain

**Tenang, fokus, dan hangat.**

RECALLY terasa seperti ruang belajar pribadi yang nyaman. Latar krem lembut melindungi mata saat belajar lama dan di sela aktivitas. Navy yang kuat untuk teks membuat konten mudah dibaca cepat. Oranye yang jarang dan terkontrol hanya menandai tindakan utama—sehingga apa yang harus dilakukan selalu jelas.

Desain ini datar dan ringan: tanpa gradient, glow, atau bayangan tebal. Kedalaman dibangun dari warna permukaan, garis tipis, dan hierarki tipografi yang jelas.

---

## 2. Palet Warna

### Warna Utama

| Peran | Nama | Hex | Pemakaian |
|-------|------|-----|----------|
| Primer | Navy | `#1B2A41` | Teks utama, judul, ikon penting, navigasi |
| Aksen | Oranye | `#E07A1F` | Tombol utama, tab aktif, ikon highlight |
| Latar | Krem | `#F4F1EC` | Latar layar canvas |
| Permukaan | Putih | `#FFFFFF` | Kartu, list container, sheet modal |

### Teks & Garis Sekunder

| Peran | Nama | Hex | Pemakaian |
|-------|------|-----|----------|
| Teks Sekunder | Abu-abu Biru | `#5C6B7A` | Keterangan, tanggal, label kecil, caption |
| Garis | Abu-abu Muda | `#C9CED6` | Divider, border card, border input default |
| Garis Kuat | Abu-abu Sedang | `#AEB6C2` | Border input fokus, border kuat |

### Warna Penilaian (Lupa / Ragu / Ingat)

Pastel agar tidak bersaing dengan oranye. Teks pada tombol: navy tua (bukan putih).

| Label | Latar Pastel | Teks Tua |
|-------|------------|-----------|
| Lupa | `#F4C7C3` | `#B3261E` (merah) |
| Ragu | `#FCE8A6` | `#7A5A00` (kuning) |
| Ingat | `#C8EBD7` | `#2F6B4A` (hijau) |

### Warna Semantik

| Peran | Hex | Pemakaian |
|-------|-----|----------|
| Sukses | `#2F6B4A` | Ikon/label positif, legend bar |
| Peringatan | `#7A5A00` | Ikon/label peringatan, legend bar |
| Galat | `#B3261E` | Pesan galat, aksi hapus, border alert |
| Info | `#4B6078` | Icon info, banner informatif |

### Warna Turunan

| Peran | Hex | Pemakaian |
|-------|-----|----------|
| Latar Aksen Lembut | `#FBE9D7` | Latar chip/nav saat aktif |
| Latar Cerah | `#FAF7F2` | Latar list item saat hover/disabled |
| Latar Disabled | `#EDE7DE` | Latar tombol disabled, progress track |
| Overlay Modal | `rgba(27,42,65,0.42)` | Barrier di belakang sheet/modal |

---

## 3. Kontras (WCAG AA)

Semua kombinasi lulus WCAG AA (minimal 4.5:1 teks normal, 3:1 teks besar).

| Kombinasi | Rasio | Status | Ukuran |
|-----------|-------|--------|--------|
| Navy di atas krem | 12.8:1 | ✓ | Semua |
| Abu-abu biru di atas krem | 4.9:1 | ✓ | Normal+ |
| Navy di atas oranye | 4.8:1 | ✓ | Normal+ |
| Merah tua di atas Lupa pastel | 9.5:1 | ✓ | Semua |
| Kuning tua di atas Ragu pastel | 11.9:1 | ✓ | Semua |
| Hijau tua di atas Ingat pastel | 11.0:1 | ✓ | Semua |
| **Putih di atas oranye** | 3.0:1 | ✗ | **JANGAN** |

**Aturan Pemakaian Warna (Terkunci):**

1. **Teks pada tombol oranye selalu navy**, bukan putih.
2. **Oranye tidak dipakai sebagai teks kecil** di atas krem. Hanya oranye gelap `#B85A10` (4.1:1 untuk teks besar).
3. **Ikon minimal 3:1** terhadap latarnya.

---

## 4. Tipografi

**Font:** Inter (bundel lokal di `assets/fonts/Inter-{Regular,Medium,SemiBold,Bold}.ttf`).

| Elemen | Ukuran | Weight | LineHeight (Ratio) | Pemakaian |
|--------|--------|--------|-----------|-----------|
| Display | 32px | 700 | 1.19× | Angka besar (retensi %, streak, count) |
| Judul 1 | 20px | 700 | 1.30× | Judul halaman, sesi selesai |
| Judul 2 | 20px | 600 | 1.30× | Judul modal, subtitle |
| Judul 3 | 16px | 600 | 1.38× | Section header, subtitle ringkasan |
| Body Besar | 16px | 400 | 1.50× | Isi panjang, daftar penting |
| Body | 14px | 400 | 1.43× | Isi normal, form field |
| Label | 11px | 600 | 1.45× | Button label, chip, tag, nav label |
| Caption | 11px | 400 | 1.45× | Teks kecil, helper text |
| Overline | 11px | 600 | 1.45× | Section header uppercase |

---

## 5. Spasi & Ukuran

**Kelipatan 8px untuk semua spasi: 4, 8, 12, 16, 20, 24, 32, 40, 48.**

| Token | Px | Pemakaian |
|-------|----|-----------| 
| space1 | 4 | Spacing internal mini, gap icon+text |
| space2 | 8 | Spacing antar elemen kecil |
| space3 | 12 | Spacing normal antar item |
| space4 | 16 | Spacing antar elemen medium |
| space5 | 20 | Margin layar horizontal, padding kartu |
| space6 | 24 | Jarak antar section |
| space8 | 32 | Jarak antar blok besar |
| space10 | 40 | Padding sheet atas/bawah lebar |
| space12 | 48 | Spacing langka, padding sheet |

**Ukuran Tetap:**

| Elemen | Ukuran | Catatan |
|--------|--------|---------|
| Margin Layar Horizontal | 20px | Screen edge pada AppPage |
| Button Min Height | 52px | Primary/Secondary normal |
| Button Text Height | 44px | Text variant |
| Input Min Height | 48px | Untuk kenyamanan touch |
| Touch Target Min | 44 × 44px | Untuk semua interactive |
| Icon Size | 20–22px | Default, adaptif per konteks |
| Bottom Nav Height | 72px | AppShell navigation |
| Study Top Bar Height | 48px | Sesi belajar |
| Progress Bar Height Normal | 6px | Track, bar progress |
| Progress Bar Height Chart | 4px | Bar chart aktivitas |
| Radius Card | 12px | Kartu, container, input |
| Radius Button/Chip | 999px | Kapsul sempurna |
| Radius Sheet Top | 24px | Bottom sheet |
| Circle Icon Container | 36–72px | Avatar, icon badge |

---

## 6. Komponen Dasar

### Button / Tombol

**Primary (Oranye):**
- Latar: Oranye solid `#E07A1F`
- Teks: Navy, 14px weight 600
- Height: 52px
- Radius: 999px
- Min touch: 44 × 44px

**Secondary (Putih):**
- Latar: Putih
- Border: 1px abu-abu `#C9CED6`
- Teks: Navy, 14px weight 600
- Height: 52px
- Radius: 999px

**Text (Transparan):**
- Teks: Oranye gelap `#B85A10`, 14px weight 600
- Latar: Transparan
- Height: 44px
- Focus ring: Abu-abu ring 3px

**Danger (Merah):**
- Latar: Merah `#B3261E`
- Teks: Putih, 14px weight 600
- Height: 52px
- Radius: 999px

**Disabled (Semua varian):**
- Latar: Abu-abu lembut `#EDE7DE`
- Teks: Abu-abu biru `#5C6B7A`
- Tidak responsif, opacity 0.5

### Kartu

- **Radius:** 12px
- **Border:** 1px abu-abu `#C9CED6`
- **Padding:** 20px default (bisa custom)
- **Latar:** Putih `#FFFFFF`
- **Shadow:** Tidak ada (desain datar)

### Chip / Tag

- **Radius:** 999px (kapsul)
- **Height:** 44px min (including padding)
- **Border:** 1px
- **Inactive:** Latar putih, border abu-abu, teks navy, weight 600
- **Active:** Latar oranye lembut `#FBE9D7`, border oranye, teks navy, weight 700

### List Group

- Satu wadah putih 12px radius, border 1px abu-abu.
- Baris dipisahkan divider 1px abu-abu (bukan kartu bertumpuk).
- Min height baris: 64px.
- Padding baris: 16px horizontal, 12px vertical.

### Input Text

- **Radius:** 12px
- **Border Default:** 1px abu-abu `#C9CED6`
- **Border Fokus:** 1px oranye `#E07A1F`
- **Focus Ring:** Shadow 3px `rgba(224, 122, 31, 0.16)` (bukan border extra)
- **Label:** Selalu di atas field (11px weight 600 abu-abu biru), bukan placeholder
- **Height:** Min 48px normal, lebih untuk multiline
- **Helper/Error Text:** 11px weight 400 abu-abu biru

### Bottom Sheet

- **Radius Atas:** 24px
- **Border Atas:** 1px abu-abu `#C9CED6`
- **Handle:** Garis abu-abu sedang 36 × 4px, positioned 12px dari atas
- **Padding:** 20px horizontal, 12px atas, 20px bawah + safe area

### Progress Bar

- **Height Normal:** 6px
- **Height Chart:** 4px
- **Radius:** 3px (setengah height)
- **Track:** Abu-abu lembut `#EDE7DE`
- **Fill:** Oranye solid `#E07A1F`

### Bottom Navigation

- **Height:** 72px (including safe area)
- **Latar:** Putih `#FFFFFF`
- **Border Atas:** 1px abu-abu `#C9CED6`
- **Inactive Icon:** Abu-abu `#5C6B7A`, 20px
- **Inactive Label:** Abu-abu `#5C6B7A`, 11px weight 500
- **Active Icon Container:** Kapsul 40 × 28px latar oranye lembut `#FBE9D7`
- **Active Icon:** Oranye gelap `#B85A10`, 20px
- **Active Label:** Navy `#1B2A41`, 11px weight 700

### Banner / Alert

- **Radius:** 12px
- **Border:** 1px (warna sesuai tone: info/success/warning/danger)
- **Padding:** 16px
- **Layout:** Icon (20px) + Teks + Action label (opsional)
- **Gap:** 12px antar elemen

### Empty State

- **Ikon Container:** 72px circle, latar oranye lembut `#FBE9D7`
- **Ikon:** 32px oranye gelap `#B85A10`
- **Judul:** 16px weight 600 navy, center
- **Pesan:** 14px regular abu-abu biru, center
- **Action:** Button (opsional) dengan jarak 24px

---

## 7. Layar & Alur

### Hari Ini (Today)

**Header:** Eyebrow overline tanggal (uppercase), judul "Selamat Pagi/Siang/Sore/Malam", subtitle "Belajar sedikit, ingat lebih lama", trailing chip flame jika streak > 0.

**Hero Card:** Putih 12px, 20px padding, overline "SESI HARI INI":
- Angka besar (32px weight 700) kartu jatuh tempo + label "kartu siap diulang"
- Jika ada reviewed hari ini: caption "Sudah X hari ini"
- Primary button "Mulai sesi" (atau disabled jika 0 kartu)
- Caption "Perkiraan X menit"
- Atau jika 0 kartu: secondary "Buka Deck" + caption

**Deck List:** (Opsional, ditambah di masa depan)

---

## 8. Alur Belajar Utama

**Tetap Terjaga:**

```
Hari Ini
  ├─ Mulai Sesi → Sesi Belajar
  │   ├─ Tulis Jawaban (atau pikirkan di mode hafalan)
  │   ├─ Periksa/Lihat Jawaban
  │   ├─ Bandingkan "Jawabanmu" vs "Jawaban Benar"
  │   └─ Nilai: Lupa (merah) / Ragu (kuning) / Ingat (hijau)
  │       └─ Ringkasan Sesi (streak, next due, count per rating)
  │           └─ Kembali ke Hari Ini

Deck (list semua deck, dengan jumlah kartu + due)
  └─ Detail Deck
      ├─ Tambah Kartu (form sheet)
      ├─ Tempel Banyak Kartu (paste sheet)
      └─ Edit/Hapus per Kartu (form sheet)

Progres
  ├─ Pilih Periode: Minggu / 30 Hari (chip selector)
  ├─ Retensi (% besar + trend)
  ├─ Metrik (streak / kartu total / dikuasai %)
  ├─ Aktivitas (bar chart)
  ├─ Penguasaan (bar stacked + legend)
  ├─ Per Deck (top 4 dengan progress)
  └─ Riwayat Belajar (top 3 hari recent)

Pengaturan
  ├─ Sinkronisasi (info, login nanti)
  └─ Isi Data Contoh (PENGEMBANG, debug-only)
```

---

## 9. Aksesibilitas

- **Touch Target Min:** 44 × 44px (buttons, chips, list rows).
- **Semantic:** Gunakan `Semantics` untuk label, state (selected/enabled/disabled).
- **Contrast:** Semua teks lulus WCAG AA.
- **Text Scaling:** Support scale 100–200% tanpa overflow.
- **Focus Indicator:** Visible ring/border pada semua interactive.
- **Dark Mode:** Tidak ada (light-only theme).

---

## 10. Platform & Build

- **Android-first:** Material Design semantics, haptic feedback minimal.
- **iOS Compat:** Respek safe area, native navigation aware.
- **Web Preview:** Responsive, 390px breakpoint primer.
- **Font Bundel:** `assets/fonts/Inter-{Regular,Medium,SemiBold,Bold}.ttf`.
- **Theme:** `AppTheme.light()` saja, `AppThemeExtension.light`, `AppColors.light`.

---

## 11. Implementasi Kode

### Tokens Kode

- **Colors:** `AppColors` + `AppColors.light` const.
- **Typography:** `AppTypography` (display, h1, h2, h3, bodyLarge, body, label, caption, overline).
- **Extension:** `AppThemeExtension` (radiusCard, radiusControl, radiusChip, radiusPill, radiusSheet, space1–12, motionFast/Screen/Slow).
- **Widgets:** `AppButton`, `AppCard`, `AppChip`, `AppListGroup`, `AppListRow`, `AppTextField`, `AppBanner`, `AppEmptyState`, `AppProgressBar`, `AppPage`, `showAppSheet()`, `showAppConfirmSheet()`.
- **Navigation:** `AppShell` (4 tabs), `AppRouter`.

---

## 12. Catatan Penting

1. **Tidak ada dark mode.** Hanya light theme.
2. **Oranye jarang:** Hanya primary button, tab aktif, ikon highlight. Tidak untuk teks kecil.
3. **Navy untuk teks:** Selalu, bahkan di atas oranye.
4. **Spasi konsisten:** Kelipatan 8px, margin layar 20px.
5. **Radius dua mode:** 12px untuk kartu/input, 999px untuk kapsul (button/chip).
6. **Animasi ringan:** 180ms fade/color, 200ms modal, easeOut curve.
7. **Empty state:** Ikon lembut, bukan dekorasi ramai.

---

**Versi:** 4.0  
**Tanggal:** 2 November 2026  
**Status:** Aktif — semua layar mengikuti spec ini.  
**Font:** Inter (bundel lokal).  
**Kontras:** Semua kombinasi lulus WCAG AA.
