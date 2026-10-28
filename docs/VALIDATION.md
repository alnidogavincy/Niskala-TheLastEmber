# Verifikasi Niskala — 28 Oktober 2026

## Hasil yang telah diperiksa

| Pemeriksaan | Hasil |
|---|---|
| Godot 4.5.1 stable, Compatibility | Proyek berhasil diimpor dan dijalankan |
| Smoke test | 23 pemeriksaan lulus, 0 gagal |
| Gerak dan lompatan | InputMap dan collision TileMap diuji melalui physics frame |
| Serangan | Area2D mengenai musuh; satu swing hanya memberi satu hit |
| Kesehatan | Lima poin awal, damage dan periode kebal lulus |
| Altar/checkpoint | Aktivasi, healing, save/load, respawn dan preservasi altar lulus |
| Mini-boss | Telegraph, damage pukulan tanah, jeda pemulihan, lontaran akar dan defeat lulus |
| Kemenangan | Tiga altar + boss membuka portal dan layar kemenangan |
| Lintasan | Seluruh platform dapat dilewati dengan input fisika; x=14900.55 setelah 3350 tick dalam tes tanpa musuh |
| Multitouch simulasi | Kanan + lompat + serang aktif bersamaan; ketiganya dilepas dengan benar |
| Tampilan | Menu, gameplay, boss 1280×720 dan kontrol sentuh 1600×720 dirender dan ditinjau |
| Build Windows | EXE dengan PCK tertanam diekspor; diluncurkan dari folder distribusi, renderer OpenGL aktif, exit code 0 |
| Build Android | APK ARM64 berhasil diekspor dan lolos verifikasi tanda tangan v2/v3 |
| Android metadata | Package com.niskala.lastember, version 0.1.0, minimum API 24, target API 35; tidak meminta izin internet |

## Performa Windows

GPU pengujian: AMD Radeon Vega 10 Graphics, Compatibility/OpenGL 3.3.

- Pengambilan gambar dan simulasi kontrol dengan pembatas runtime 60 FPS: rata-rata sekitar **60.66 FPS**, sampel 180 frame.
- Pengukuran kapasitas render tanpa VSync/pembatas frame: **178.90 FPS** pada 1280×720 dan **170.15 FPS** pada 1600×720, masing-masing 180 frame.
- Sampel singkat pada scene gameplay, bukan pengujian panjang seluruh level atau pengukuran konsumsi daya/thermal. Angka monitor CPU dalam log benchmark diperbarui secara periodik oleh engine dan tidak digunakan untuk menghitung waktu frame.

## Batas pengujian

- `adb devices -l` tidak menemukan perangkat. Instalasi, performa, safe-area notch, suspend/resume Android, dan multitouch pada ponsel fisik **belum diverifikasi**.
- APK menggunakan debug signing untuk pengujian, belum berupa rilis Play Store.
- Durasi 5–10 menit adalah target desain bagi pemain pertama; belum ada playtest manusia untuk memvalidasi durasi dan tingkat kesulitan.
- Uji lintasan menyingkirkan musuh untuk mengisolasi geometri. Smoke test menguji combat dan kondisi kemenangan secara terpisah; bukan rekaman seorang pemain menyelesaikan semua encounter.
- Animasi lari mempunyai empat frame. State lain menggunakan pose dasar dengan transformasi AnimationPlayer dan efek; belum berupa animasi frame-by-frame lengkap untuk setiap state.
- Artwork tersedia sebagai PNG dan OpenRaster yang bisa diedit di Krita. Atlas karakter/props adalah raster, bukan rig skeletal atau PSD berlapis per anggota badan.
- Sandbox Windows mengeluarkan pesan engine `Failed to read the root certificate store`. Tidak ada script error atau aset hilang pada smoke test/capture akhir dan game tidak menggunakan jaringan. Pesan tersebut dicatat sebagai keterbatasan lingkungan pengujian.

## Bukti lokal dan reproduksi

Log lokal: `builds/smoke.log`, `builds/capture.log`, `builds/performance.log`, `builds/windows-runtime.log`, `builds/export-windows.log`, dan `builds/export-android.log`.

Gambar langsung dari game: `builds/menu-preview.png`, `builds/game-preview.png`, `builds/boss-preview.png`, dan `builds/touch-20x9-preview.png`.

Perintah reproduksi terdapat pada README. Gunakan direktori user-data terpisah saat menjalankan tes agar progres main pribadi tetap aman.
