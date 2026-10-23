# RECALLY — Dokumentasi

Dokumentasi produk, riset kebutuhan, dan sistem desain untuk aplikasi RECALLY.

## Struktur

```text
docs/
├── README.md
├── analisis_kebutuhan_recally.md
├── RECALLY_Dokumen_Analisis_Kebutuhan.docx
├── RECALLY_Dokumen_Analisis_Kebutuhan.pdf
├── flow1.png
├── flow2.png
├── flow2_triptych.png
└── design/
    └── desain.md
```

## Mulai dari Mana

1. Baca [`design/desain.md`](./design/desain.md) sebagai acuan visual tunggal.
2. Baca [`analisis_kebutuhan_recally.md`](./analisis_kebutuhan_recally.md) untuk kebutuhan produk dan alur.
3. Lihat diagram alur di `flow1.png` dan `flow2.png`.

## Catatan

- `design/desain.md` adalah sumber kebenaran untuk arah **AI sleek**, palet light dan dark, tipografi, shape, komponen, state, dan anti-AI-slop.
- Aplikasi mendukung dua tema penuh: light dan dark. Default mengikuti preferensi sistem, dengan override manual di Pengaturan.
- Auth bersifat opsional untuk sinkronisasi; aplikasi tetap bisa dipakai offline tanpa akun.
- Bagian palet di `analisis_kebutuhan_recally.md` bersifat historis dan tidak lagi menjadi acuan UI aplikasi.
