# RECALLY

Aplikasi flashcard dengan **pengulangan berjarak** (spaced repetition) untuk pelajar SMA, mahasiswa, dan pembelajar bahasa asing.

> Belajar sedikit, ingat lebih lama.

RECALLY membantu kamu menghafal materi dengan kartu belajar dan jadwal pengulangan yang dihitung otomatis. Aplikasi berjalan **local-first**: bisa dipakai offline tanpa akun, dan sinkronisasi cloud hanya untuk cadangan serta pindah perangkat.

---

## Fitur Utama

| Kode | Fitur |
| --- | --- |
| KF-1 | Membuat deck dan kartu depan/belakang |
| KF-2 | Membuat kartu dari teks, tempelan teks, atau foto catatan (OCR) |
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
├── docs/
│   ├── README.md
│   ├── analisis_kebutuhan_recally.md
│   ├── RECALLY_Dokumen_Analisis_Kebutuhan.docx
│   ├── RECALLY_Dokumen_Analisis_Kebutuhan.pdf
│   ├── flow1.png
│   ├── flow2.png
│   ├── flow2_triptych.png
│   └── design/
│       └── desain.md
```

---

## Mulai dari Mana

1. Baca README ini untuk gambaran produk dan fitur utama.
2. Buka [`docs/design/desain.md`](docs/design/desain.md) sebagai acuan visual tunggal (light + dark).
3. Lihat [`docs/analisis_kebutuhan_recally.md`](docs/analisis_kebutuhan_recally.md) untuk kebutuhan produk dan alur.
4. Diagram alur ada di `docs/flow1.png`, `docs/flow2.png`, dan `docs/flow2_triptych.png`.

---

## Catatan

- Bagian palet di `docs/analisis_kebutuhan_recally.md` bersifat historis dan sudah digantikan oleh `docs/design/desain.md`.
- Auth bersifat opsional; aplikasi tetap bisa dipakai offline tanpa akun.
- Data lokal adalah default. Sinkronisasi cloud tidak pernah menjadi gerbang aplikasi.
