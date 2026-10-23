# RECALLY — Desain Acuan

Dokumen ini adalah **sumber kebenaran** untuk arah visual RECALLY. Semua komponen, layar, dan implementasi UI harus mengikuti aturan di sini.

- **Produk:** RECALLY — aplikasi flashcard dengan pengulangan berjarak.
- **Platform:** mobile, Android-first, portrait 390 × 844.
- **Tema:** light dan dark, keduanya pertama-class. Default mengikuti sistem.
- **Bahasa UI:** Indonesia.
- **Status:** v3.0, arah **AI sleek** dengan dua tema.
- **Bukan bagian dari palet aplikasi:** warna aksen dokumen `#5E69EE` hanya dipakai di dokumen analisis, tidak di UI aplikasi.

---

## 1. Arah Desain

**AI sleek, bukan AI slop.**

RECALLY terasa seperti alat belajar premium: permukaan bersih, teks kontras tinggi, border tipis, dan satu aksen electric blue yang dipakai sangat terkontrol. Sleek dicapai lewat kontras, tipografi, dan satu titik fokus — bukan lewat dekorasi yang ramai.

Kesan yang ingin dicapai:

- Fokus, tenang, dan premium.
- Modern seperti produk AI terbaik, tetapi tetap bisa dipercaya untuk belajar.
- High-contrast, tajam, dan presisi.
- Sedikit futuristik, tanpa kehilangan keterbacaan.
- Cukup khas untuk tidak terlihat seperti template AI generik.

Yang harus dihindari:

- Gradient ungu-biru di semua elemen.
- Glassmorphism di semua permukaan.
- Glow besar di setiap kartu.
- Blob 3D dan ilustrasi AI generik.
- Gradient text dan neon berlebihan.
- Dashboard SaaS dengan banyak kartu KPI.
- Stock photo, emoji besar, dan copy motivasi kosong.
- Shadow tebal dan sudut super bulat di semua elemen.

---

## 2. Prinsip

1. **Satu fokus per layar.** Satu pertanyaan, satu tugas, satu CTA utama.
2. **Kontras sebelum dekorasi.** Hierarki dibangun lewat skala teks, weight, dan ruang.
3. **Dua tema setara.** Light dan dark sama-sama dipelihara; tidak ada tema yang jadi tambahan.
4. **Aksen sangat terbatas.** Electric blue hanya untuk CTA utama, state aktif, fokus, dan data penting.
5. **Satu titik fokus cahaya.** Glow lembut di dark, shadow lembut di light. Jangan di setiap kartu.
6. **Glass secukupnya.** Blur hanya untuk bottom navigation dan bottom sheet.
7. **Data nyata.** Gunakan angka, nama deck, dan kalimat yang masuk akal.
8. **Konsisten.** Radius, spasi, ikon, dan tone copy tidak berubah-ubah.
9. **Aksesibel.** Kontras cukup, target sentuh 44px, tidak hanya mengandalkan warna.
10. **Tenang.** Lebih baik kurang elemen daripada terlalu ramai.

---

## 3. Mode Tema

- **Default:** ikut preferensi sistem operasi (`prefers-color-scheme`).
- **Override manual:** tersedia di Pengaturan dengan tiga pilihan: **Ikuti sistem**, **Terang**, **Gelap**.
- **Persistensi:** pilihan manual disimpan di perangkat dan dipakai saat aplikasi dibuka.
- **Perilaku:** kedua tema memakai struktur, radius, spasi, dan tipografi yang identik. Hanya token warna dan elevasi yang berubah.
- **Aturan:** jangan membuat tata letak khusus per tema. Jangan menambah ilustrasi berbeda per tema.

---

## 4. Palet

Setiap token punya nilai untuk **light** dan **dark**. Nama token selalu sama; hanya nilainya yang berubah. Implementasi dianjurkan memakai CSS variable pada `:root` (light) dan `[data-theme="dark"]` (dark).

### 4.1 Token Inti

| Token | Light | Dark | Penggunaan |
| --- | --- | --- | --- |
| `canvas` | `#F7F8FB` | `#090A0F` | Latar utama aplikasi |
| `surface` | `#FFFFFF` | `#111319` | Kartu, input, header |
| `surface-2` | `#F1F3F8` | `#171A23` | Sheet, nav, kartu sekunder |
| `surface-3` | `#E7EAF2` | `#1D2130` | Hover, selected row, track |
| `ink` | `#0E1220` | `#F5F7FC` | Judul dan teks utama |
| `ink-soft` | `#4A5165` | `#A7AEBD` | Body sekunder |
| `muted` | `#7A8296` | `#737B8C` | Placeholder, caption, helper |
| `border` | `#DDE2EC` | `#262B38` | Garis kartu, input, divider |
| `border-strong` | `#C3CAD9` | `#343B4D` | Outline aktif |
| `overlay` | `rgba(14,18,32,0.40)` | `rgba(0,0,0,0.72)` | Modal dan bottom sheet |
| `glass` | `rgba(255,255,255,0.78)` | `rgba(17,19,25,0.72)` | Bottom nav dan sheet |

### 4.2 Token Aksen

| Token | Light | Dark | Penggunaan |
| --- | --- | --- | --- |
| `accent` | `#2F5BD6` | `#5B8CFF` | Ikon aktif, teks aksen, fokus |
| `accent-strong` | `#2A50C2` | `#3F6FE0` | Awal gradient CTA |
| `accent-2` | `#1E9FD4` | `#4DD4FF` | Akhir gradient, highlight data |
| `accent-pressed` | `#2444A6` | `#2F5BD6` | State pressed |
| `accent-soft` | `#E4EAFC` | `#17213A` | Latar state aktif, chip aktif |

Light memakai aksen yang lebih gelap agar teks dan ikon tetap kontras di atas permukaan terang. Dark memakai aksen yang lebih terang agar menyala di atas kanvas gelap.

### 4.3 Token Semantik

| Token | Light | Dark | Penggunaan |
| --- | --- | --- | --- |
| `success` | `#0F8A5F` | `#3DDC97` | Nilai “Ingat” |
| `success-soft` | `#E2F6EC` | `#0F2A22` | Latar nilai “Ingat” |
| `warning` | `#9A6503` | `#F5B544` | Nilai “Ragu” |
| `warning-soft` | `#FBF0DA` | `#2A2111` | Latar nilai “Ragu” |
| `danger` | `#C93A57` | `#FF5C7A` | Nilai “Lupa”, hapus data |
| `danger-soft` | `#FCE8EC` | `#2A1218` | Latar nilai “Lupa” |
| `info` | `#1E7FA8` | `#7DD3FC` | Informasi netral |
| `info-soft` | `#E3F2FA` | `#13202A` | Latar informasi |

### 4.4 Gradient dan Elevasi

| Token | Light | Dark |
| --- | --- | --- |
| `gradient-primary` | `linear-gradient(135deg, #2A50C2 0%, #1E7FD8 100%)` | `linear-gradient(135deg, #3F6FE0 0%, #2F7FD8 100%)` |
| `glow-accent` | `0 8px 24px rgba(47,91,214,0.22)` | `0 0 24px rgba(91,140,255,0.28)` |
| `inner-highlight` | `inset 0 1px 0 rgba(255,255,255,0.60)` | `inset 0 1px 0 rgba(255,255,255,0.04)` |
| `shadow-surface` | `0 1px 2px rgba(14,18,32,0.06)` | `none` |

### 4.5 Aturan Warna

- **Tidak ada oranye dan ungu.** Aksen utama adalah electric blue.
- Electric blue hanya untuk:
  - CTA utama.
  - Ikon dan label tab aktif.
  - Fokus input.
  - Angka atau data yang benar-benar penting.
- Gradient hanya untuk:
  - Primary button.
  - Progress fill.
  - Satu hero glow/shadow.
- Jangan memakai gradient pada teks, kartu, atau background penuh.
- Jangan memakai lebih dari satu accent gradient dalam satu layar.
- Status memakai warna semantik dengan latar `*-soft`, bukan gradient.
- Teks body tidak boleh memakai `accent`.
- Jangan memakai warna semantik sebagai dekorasi.
- Status tidak boleh dibedakan hanya dengan warna.

### 4.6 Kontras

- Teks utama `ink` di atas `canvas` dan `surface` harus ≥ 7:1 di kedua tema.
- Teks sekunder `ink-soft` harus ≥ 4.5:1 di kedua tema.
- `muted` hanya untuk helper, caption, dan placeholder.
- Label putih di atas gradient CTA harus ≥ 4.5:1 di kedua tema.
- Jangan memakai `muted` untuk informasi penting.
- Uji setiap pasangan warna di light dan dark, bukan hanya di salah satu tema.

---

## 5. Tipografi

### 5.1 Font

- **SF Pro / San Francisco** — satu-satunya typeface aplikasi.
- **SF Pro Display** — untuk ukuran 20px ke atas: display, judul layar, nama deck, angka besar.
- **SF Pro Text** — untuk ukuran di bawah 20px: seluruh UI, body, tombol, label, caption.
- **Fallback:** `-apple-system, BlinkMacSystemFont, "SF Pro Text", "SF Pro Display", "Segoe UI", Roboto, system-ui, sans-serif`.

Di Android, SF Pro tidak selalu tersedia. Gunakan system sans-serif terdekat tanpa mengubah hierarki, ukuran, atau weight. Jangan menambahkan font serif atau font dekoratif.

### 5.2 Skala

| Peran | Font | Ukuran | Weight |
| --- | --- | --- | --- |
| Display | SF Pro Display | 36/40 | 700 |
| H1 | SF Pro Display | 30/36 | 700 |
| H2 | SF Pro Display | 24/30 | 600 |
| H3 | SF Pro Text | 18/24 | 600 |
| Body L | SF Pro Text | 16/24 | 400 |
| Body | SF Pro Text | 15/23 | 400 |
| Label | SF Pro Text | 13/18 | 600 |
| Caption | SF Pro Text | 12/16 | 500 |
| Overline | SF Pro Text | 10/14 | 700 |

### 5.3 Aturan

- Sentence case. Jangan ALL CAPS kecuali overline kecil.
- Maksimal tiga ukuran teks dalam satu kartu.
- Gunakan SF Pro Display hanya untuk teks 20px ke atas.
- Jangan memakai SF Pro Display untuk paragraf panjang.
- Display dan H1 boleh memakai tracking -0.03em.
- Body tidak memakai letter-spacing.
- Overline memakai tracking 0.12em.
- Jangan memakai lebih dari dua weight SF Pro dalam satu komponen.
- Jangan mencampur SF Pro dengan font serif, handwriting, atau font dekoratif.
- Angka besar memakai tabular figures jika tersedia.
- Skala yang sama dipakai di light dan dark; jangan mengubah ukuran per tema.

---

## 6. Shape, Spacing, dan Elevasi

### 6.1 Spacing

- Grid dasar: 4pt.
- Gunakan: 4, 8, 12, 16, 20, 24, 32, 40, 48.
- Margin layar: 20px kiri dan kanan.
- Jarak antar-section: 32px.
- Padding kartu: 20px.
- Jarak antar-baris list: 14–16px.

### 6.2 Radius

| Elemen | Radius |
| --- | --- |
| Kartu | 16px |
| Tombol | 12px |
| Input | 12px |
| Chip | 10px |
| Icon tile | 12px |
| Bottom sheet | 28px atas |
| Toast | 12px |

**Aturan shape:**

- Tidak ada kartu dengan radius lebih dari 20px, kecuali bottom sheet.
- Tidak ada chip berbentuk pill penuh. Chip memakai radius 10px.
- Tidak ada tombol bulat penuh, kecuali icon button 44×44px.
- Jangan mencampur terlalu banyak radius dalam satu layar.

### 6.3 Elevasi per Tema

**Dark:**

- **Tidak ada shadow tebal.** Kartu memakai `surface` dengan border 1px `border` dan inner highlight tipis.
- Primary CTA boleh memakai glow `0 0 24px rgba(91,140,255,0.28)`.
- Hero boleh memakai satu radial glow lembut di belakangnya.
- Bottom navigation memakai `glass` dengan backdrop blur 18px dan border atas 1px.
- Bottom sheet memakai `surface-2`, border atas 1px, dan overlay.

**Light:**

- Elevasi dibangun dengan border 1px `border` **dan** shadow sangat lembut `0 1px 2px rgba(14,18,32,0.06)`.
- Shadow tidak boleh dipakai untuk semua elemen: hanya kartu, sheet, dan elemen yang benar-benar mengambang.
- Primary CTA memakai gradient dengan shadow lembut `0 8px 24px rgba(47,91,214,0.22)`.
- Hero boleh memakai satu soft shadow besar tanpa glow neon.
- Bottom navigation memakai `glass` putih transparan dengan backdrop blur 18px dan border atas 1px.
- Bottom sheet memakai `surface` dengan radius 28px atas, border 1px, dan overlay `rgba(14,18,32,0.40)`.

**Aturan untuk kedua tema:**

- Jangan memakai shadow untuk membuat hierarki. Gunakan spasi, border, dan tipografi lebih dulu.
- Jangan memakai glow berwarna di light theme.
- Divider memakai 1px `border` di kedua tema.

---

## 7. Komponen

Semua komponen di bawah memakai token tema. Nilai warna yang disebut adalah contoh dark; di light gunakan pasangan token yang sama.

### 7.1 Tombol

**Primary**
- Gradient `gradient-primary`.
- Teks putih, SF Pro Text 15px Semibold.
- Tinggi 52px, radius 12px.
- Dark: glow `0 0 24px rgba(91,140,255,0.28)`. Light: shadow `0 8px 24px rgba(47,91,214,0.22)`.
- Satu per layar.
- Disabled: latar `surface-3`, teks `muted`, tanpa glow/shadow.

**Secondary**
- Latar `surface`, border 1px `border`, teks `ink`.
- Tinggi 52px, radius 12px.
- Untuk aksi alternatif.

**Text button**
- Tanpa background.
- Teks `accent` atau `ink`, ikon 20px.
- Untuk “Lihat jawaban”, “Lewati”, “Ganti mode”.

**Danger**
- Latar `danger`, teks putih (dark) atau `surface` (light), atau text button `danger`.
- Hanya untuk hapus data dan konfirmasi destruktif.

### 7.2 Input

- Tinggi minimal 56px, radius 12px.
- Latar `surface`, border 1px `border`.
- Placeholder `muted`.
- Fokus: border 1px `accent` + focus ring 3px `accent-soft` (light) / `rgba(91,140,255,0.18)` (dark).
- Error: border `danger` + helper `danger`.
- Textarea minimal 3 baris.
- Label selalu di atas input, bukan placeholder-only.

### 7.3 Kartu

- Latar `surface`, border 1px `border`, radius 16px.
- Padding 20px.
- Dark: inner highlight tipis, tanpa shadow.
- Light: shadow `0 1px 2px rgba(14,18,32,0.06)`, tanpa glow.
- Jangan menumpuk kartu di dalam kartu.

### 7.4 Chip

- Tinggi 32px, radius 10px, padding 0 12px.
- Default: latar `surface-2`, border 1px `border`, teks `ink-soft`.
- Aktif: latar `accent-soft`, border `accent`, teks `accent`.
- Jangan memakai pill penuh.

### 7.5 Progress

- Track 4px `surface-3`, radius 2px.
- Fill memakai gradient `accent-strong` ke `accent-2`.
- Jangan memakai animasi shimmer.

### 7.6 Bottom Navigation

- Tinggi 72px plus safe area.
- Latar `glass` dengan backdrop blur 18px.
- Border atas 1px `border`.
- 4 tab: Hari Ini, Deck, Progres, Pengaturan.
- Aktif: ikon dan label `accent`, plus indikator 2px gradient di atas tab.
- Nonaktif: `muted`.
- Tidak ada pill di belakang ikon.

### 7.7 Bottom Sheet

- Latar `surface-2` (dark) atau `surface` (light), radius 28px atas.
- Border atas 1px `border-strong`.
- Overlay `overlay`.
- Drag handle 36 × 4px `border-strong`.
- Padding 20px.

### 7.8 List Row

- Tinggi minimal 64px.
- Divider 1px `border`.
- Judul `ink`, metadata `muted`.
- Chevron atau aksi di kanan.
- Jangan memakai kartu terpisah untuk setiap baris.

### 7.9 Toast dan Banner

- Toast: `surface-2`, border 1px `border`, radius 12px, teks `ink`.
- Success: border `success`, ikon `success`.
- Warning: latar `warning-soft`, border `warning`, teks `warning`.
- Danger: latar `danger-soft`, border `danger`, teks `danger`.
- Jangan memakai banner selebar layar untuk hal yang bukan status penting.

### 7.10 Ikon dan Ilustrasi

- Ikon outline Phosphor atau Lucide, 24px, stroke 1.75px.
- Ikon aktif boleh memakai `accent`.
- Ilustrasi hanya line art sederhana dengan satu aksen.
- Line art memakai `border-strong` dan `accent` di kedua tema; jangan memakai warna solid penuh.
- Jangan memakai 3D blob, stock photo, atau ilustrasi AI generik.

---

## 8. State

Semua state harus punya padanan di light dan dark.

### 8.1 Empty

- Line illustration sederhana.
- Judul `ink`, body `ink-soft`.
- Satu CTA utama.

### 8.2 Loading

- Skeleton `surface-2` dengan bar `surface-3`.
- Tanpa shimmer gradient.
- Tanpa spinner besar.

### 8.3 Offline

- Banner `warning-soft` dengan border `warning`.
- Teks `warning`.
- Aksi “Coba lagi” dalam `accent`.

### 8.4 Error

- Inline error di bawah field atau kartu.
- Border `danger`, teks `danger`.
- Jangan memakai halaman error penuh untuk kesalahan kecil.

### 8.5 Permission

- Bottom sheet tema-aware.
- Ikon outline dalam lingkaran `accent-soft`.
- Satu CTA utama dan satu “Nanti saja”.

### 8.6 Disabled

- Latar `surface-3`, teks `muted`, tanpa glow/shadow.
- Tetap terbaca, jangan turunkan opacity di bawah 40%.

---

## 9. Aksesibilitas

- Target sentuh minimal 44×44px.
- Kontras teks minimal 4.5:1 untuk teks normal di kedua tema.
- Jangan menyampaikan status hanya dengan warna.
- Setiap ikon aksi punya label aksesibel.
- Dukung font scaling tanpa memotong teks.
- Fokus keyboard terlihat dengan outline 2px `accent`.
- Jangan memakai teks di dalam gambar.
- Tombol grade harus punya label teks, bukan hanya ikon.
- Progress sesi harus terbaca oleh screen reader.
- Glow atau shadow tidak boleh menjadi satu-satunya penanda state.
- Uji light dan dark secara terpisah; kontras satu tema tidak menjamin tema lain.

---

## 10. Motion

- Transisi layar: 200–240ms ease-out.
- Perubahan state: 180ms.
- Progress bar: 220ms.
- Bottom sheet: 240ms.
- Glow/shadow: 240ms, hanya untuk fokus atau CTA.
- Transisi tema: 180ms pada warna latar dan teks. Jangan menganimasikan setiap elemen sampai terasa berat.
- Tidak ada bounce, elastic, atau animasi berlebihan.
- Hormati preferensi “kurangi gerakan”.
- Jangan memakai confetti atau animasi gamifikasi.

---

## 11. Copy dan Tone

- Bahasa Indonesia.
- Gunakan “kamu”, bukan “Anda”.
- Sentence case.
- Spesifik: “18 kartu siap diulang”, bukan “Ayo belajar!”.
- Tidak menghakimi: “Belum ada kartu jatuh tempo”, bukan “Kamu tertinggal”.
- Maksimal dua baris helper.
- Hindari tanda seru berlebihan.
- Hindari kata “AI”, “pintar”, “ajaib”, dan “super” jika tidak perlu.
- Gunakan istilah konsisten: deck, kartu, sesi, jatuh tempo, pengingat.

---

## 12. Anti-AI-Slop

### Jangan

- Gradient ungu-biru di semua elemen.
- Gradient text.
- Glassmorphism di semua kartu.
- Glow di setiap komponen.
- Blob 3D dan bola mengambang.
- Shadow tebal.
- Kartu dengan radius 24px di mana-mana.
- Enam kartu KPI di dashboard.
- Terlalu banyak chip, badge, dan label.
- Emoji besar sebagai ikon.
- Stock photo orang tersenyum.
- Lorem ipsum.
- Ilustrasi AI yang tidak berhubungan dengan belajar.
- Copy motivasi kosong.
- Sparkle/AI magic icon yang tidak punya fungsi.
- Lebih dari satu accent gradient per layar.
- Warna neon atau glow berwarna di light theme.

### Lakukan

- Satu CTA utama.
- Banyak ruang kosong.
- Border 1px dan permukaan bersih.
- Hierarki tipografi yang jelas.
- Data nyata.
- Ikon garis yang konsisten.
- Electric blue hanya di titik penting.
- Satu titik fokus (glow di dark, shadow lembut di light) per layar.
- Glass hanya di bottom nav dan sheet.
- Komposisi asimetris yang tenang, bukan centered semua.

---

## 13. Checklist Implementasi

- [ ] Light dan dark sama-sama diimplementasikan, bukan salah satu saja.
- [ ] Default mengikuti preferensi sistem; override manual tersedia di Pengaturan.
- [ ] Palet hanya memakai token di dokumen ini.
- [ ] Tidak ada oranye atau ungu di kedua tema.
- [ ] Gradient hanya di primary CTA, progress fill, dan satu hero.
- [ ] Glass hanya di bottom nav dan bottom sheet.
- [ ] Dark: tidak ada shadow tebal, glow maksimal satu per layar.
- [ ] Light: shadow lembut hanya di kartu, sheet, dan elemen mengambang.
- [ ] Radius kartu 16px, tombol/input 12px, chip 10px, sheet 28px.
- [ ] Satu CTA utama per layar.
- [ ] Bottom nav 4 tab, aktif electric blue dengan indikator 2px.
- [ ] Target sentuh minimal 44×44px.
- [ ] Kontras teks diuji terpisah untuk light dan dark.
- [ ] Status tidak hanya dibedakan dengan warna.
- [ ] Empty, loading, offline, error, dan permission state tersedia di kedua tema.
- [ ] Auth opsional dan bisa dilewati tanpa akun.
- [ ] Logout tidak menghapus data lokal maupun data cloud.
- [ ] Copy Indonesia konsisten dan menggunakan “kamu”.
- [ ] Tidak ada elemen dekoratif yang tidak membantu tugas utama.
- [ ] Tampilan terasa seperti alat belajar premium, bukan template dashboard.

---

## 14. Token untuk Implementasi

```css
:root {
  /* Light theme */
  --color-canvas: #F7F8FB;
  --color-surface: #FFFFFF;
  --color-surface-2: #F1F3F8;
  --color-surface-3: #E7EAF2;
  --color-ink: #0E1220;
  --color-ink-soft: #4A5165;
  --color-muted: #7A8296;
  --color-border: #DDE2EC;
  --color-border-strong: #C3CAD9;

  --color-accent: #2F5BD6;
  --color-accent-strong: #2A50C2;
  --color-accent-2: #1E9FD4;
  --color-accent-pressed: #2444A6;
  --color-accent-soft: #E4EAFC;

  --color-success: #0F8A5F;
  --color-success-soft: #E2F6EC;
  --color-warning: #9A6503;
  --color-warning-soft: #FBF0DA;
  --color-danger: #C93A57;
  --color-danger-soft: #FCE8EC;
  --color-info: #1E7FA8;
  --color-info-soft: #E3F2FA;

  --color-overlay: rgba(14, 18, 32, 0.40);
  --color-glass: rgba(255, 255, 255, 0.78);

  --gradient-primary: linear-gradient(135deg, #2A50C2 0%, #1E7FD8 100%);
  --glow-accent: 0 8px 24px rgba(47, 91, 214, 0.22);
  --inner-highlight: inset 0 1px 0 rgba(255, 255, 255, 0.60);
  --shadow-surface: 0 1px 2px rgba(14, 18, 32, 0.06);

  --radius-card: 16px;
  --radius-control: 12px;
  --radius-chip: 10px;
  --radius-sheet: 28px;

  --space-1: 4px;
  --space-2: 8px;
  --space-3: 12px;
  --space-4: 16px;
  --space-5: 20px;
  --space-6: 24px;
  --space-8: 32px;
  --space-10: 40px;
  --space-12: 48px;

  --duration-theme: 180ms;
}

[data-theme="dark"] {
  --color-canvas: #090A0F;
  --color-surface: #111319;
  --color-surface-2: #171A23;
  --color-surface-3: #1D2130;
  --color-ink: #F5F7FC;
  --color-ink-soft: #A7AEBD;
  --color-muted: #737B8C;
  --color-border: #262B38;
  --color-border-strong: #343B4D;

  --color-accent: #5B8CFF;
  --color-accent-strong: #3F6FE0;
  --color-accent-2: #4DD4FF;
  --color-accent-pressed: #2F5BD6;
  --color-accent-soft: #17213A;

  --color-success: #3DDC97;
  --color-success-soft: #0F2A22;
  --color-warning: #F5B544;
  --color-warning-soft: #2A2111;
  --color-danger: #FF5C7A;
  --color-danger-soft: #2A1218;
  --color-info: #7DD3FC;
  --color-info-soft: #13202A;

  --color-overlay: rgba(0, 0, 0, 0.72);
  --color-glass: rgba(17, 19, 25, 0.72);

  --gradient-primary: linear-gradient(135deg, #3F6FE0 0%, #2F7FD8 100%);
  --glow-accent: 0 0 24px rgba(91, 140, 255, 0.28);
  --inner-highlight: inset 0 1px 0 rgba(255, 255, 255, 0.04);
  --shadow-surface: none;
}

@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) {
    --color-canvas: #090A0F;
    --color-surface: #111319;
    --color-surface-2: #171A23;
    --color-surface-3: #1D2130;
    --color-ink: #F5F7FC;
    --color-ink-soft: #A7AEBD;
    --color-muted: #737B8C;
    --color-border: #262B38;
    --color-border-strong: #343B4D;

    --color-accent: #5B8CFF;
    --color-accent-strong: #3F6FE0;
    --color-accent-2: #4DD4FF;
    --color-accent-pressed: #2F5BD6;
    --color-accent-soft: #17213A;

    --color-success: #3DDC97;
    --color-success-soft: #0F2A22;
    --color-warning: #F5B544;
    --color-warning-soft: #2A2111;
    --color-danger: #FF5C7A;
    --color-danger-soft: #2A1218;
    --color-info: #7DD3FC;
    --color-info-soft: #13202A;

    --color-overlay: rgba(0, 0, 0, 0.72);
    --color-glass: rgba(17, 19, 25, 0.72);

    --gradient-primary: linear-gradient(135deg, #3F6FE0 0%, #2F7FD8 100%);
    --glow-accent: 0 0 24px rgba(91, 140, 255, 0.28);
    --inner-highlight: inset 0 1px 0 rgba(255, 255, 255, 0.04);
    --shadow-surface: none;
  }
}
```

**Catatan implementasi:**

- Terapkan `data-theme="light"` atau `data-theme="dark"` pada elemen root.
- Jika pengguna memilih “Ikuti sistem”, hapus `data-theme` dan gunakan `prefers-color-scheme`.
- Simpan pilihan tema di penyimpanan lokal perangkat.
- Jangan memuat aset gambar berbeda per tema; gunakan token warna.

---

## 15. Auth (Opsional)

Auth hanya digunakan untuk sinkronisasi cloud. Aplikasi tetap **local-first**: onboarding, deck, kartu, sesi, dan progres bisa dipakai tanpa akun.

- Login, register, dan logout tidak boleh menjadi gerbang aplikasi.
- Auth dibuka dari layar **Sinkronisasi** atau **Akun**, bukan dari splash.
- Layout satu kolom dengan margin 20px; wordmark di atas, headline SF Pro Display, body SF Pro Text.
- Input 52px, radius 12px, border 1px. Tombol utama 52px, radius 12px, gradient.
- Hanya ada satu opsi pihak ketiga: **Masuk dengan Google**.
- Error ditampilkan inline di bawah field; jangan memakai alert browser atau halaman error penuh.
- Logout memakai bottom sheet 28px dan tidak menghapus data lokal maupun data cloud.
- Jangan memakai ilustrasi auth, gradient panel marketing, atau copy yang menakut-nakuti.
- Sediakan state loading, offline, error, dan sesi berakhir.
- Auth mengikuti tema aktif, termasuk light.
