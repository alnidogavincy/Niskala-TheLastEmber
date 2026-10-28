# Niskala: The Last Ember

Game aksi platformer 2D offline, satu pemain, berbahasa Indonesia. Dibangun dengan **Godot 4.5.1 stable + GDScript**, renderer Compatibility. Bab pertama: **Hutan Bara Sunyi**.

## Mainkan

- Windows x86-64: buka `builds/windows/Niskala.exe`. Semua aset tertanam dalam EXE.
- Android ARM64, Android 7.0/API 24 atau lebih baru: pasang `builds/android/Niskala.apk`. APK ditandatangani dengan debug key untuk pengujian lokal.
- Editor: impor `project.godot` melalui Godot **4.5.1** dan tekan F6 pada main scene atau F5 untuk menjalankan proyek.
- Engine portabel yang dipakai saat pengembangan tersedia lokal di `tools/godot/` (tidak masuk Git/distribusi).

## Kontrol dan tujuan

| Aksi | Keyboard | Android |
|---|---|---|
| Bergerak | A/D atau panah kiri/kanan | Dua tombol kiri |
| Lompat | Space; lepas lebih cepat untuk lompat pendek | Tombol panah atas |
| Serangan bara | J | Tombol api |
| Jeda | Esc | Tombol jeda / Back |

Nyalakan tiga altar dengan mendekatinya. Altar mengisi kesehatan dan menyimpan checkpoint. Kalahkan Penunggu Akar di gerbang kuno, lalu masuki portal. Lompat ketika tanah menyala atau akar meluncur; serang saat golem sedang pulih.

Kematian mengembalikan Nara ke checkpoint dengan lima kesehatan, mempertahankan altar aktif, dan mengulang musuh setelah checkpoint. `Lanjutkan` memuat checkpoint terakhir. Pilihan `Mulai perjalanan` memulai progres baru. Audio tersimpan terpisah dari progres. Save lokal menggunakan `user://niskala_v1.json`.

## Isi proyek

- `scenes/`: main, menu, level, pemain, musuh, boss, altar, dan HUD.
- `scripts/`: controller, combat, sesi/save, level, UI, dan audio. Nilai gerak/HP/damage/cooldown diekspos melalui Inspector.
- `assets/`: PNG ilustrasi, sprite sheet lari, atlas makhluk/terrain, props, canopy, SVG UI, Nunito, serta WAV.
- `art_source/`: sumber **OpenRaster (.ora)** yang dapat dibuka di Krita lalu disimpan sebagai `.kra`. `forest-layered.ora` memisahkan canopy dan vista; karakter, sprite sheet, serta atlas tersedia dalam dokumen sumber masing-masing. Ini merupakan sumber raster hasil generasi, bukan rekaman brush-stroke Photoshop/Krita.
- `tools/`: pembuatan audio/UI dan pembungkus scene, konfigurasi export, serta pengujian Godot.
- `docs/`: hasil verifikasi, asal aset, dan prompt generasi.

Terrain memakai TileSet/TileMapLayer dan collision bawaan; karakter menggunakan CharacterBody2D. Empat lapisan Parallax2D memisahkan vista, reruntuhan, kabut, dan canopy. Animasi lari memakai empat frame AnimatedSprite2D; idle/jump/fall/attack/hurt/death menggunakan pose dasar dengan AnimationPlayer dan efek serangan. Kontrol layar sentuh menggunakan TouchScreenButton, bukan implementasi multitouch sendiri.

## Build ulang

Gunakan engine dan export template **4.5.1 stable** yang sama.

```powershell
New-Item -ItemType Directory -Force builds/windows,builds/android | Out-Null
godot --headless --editor --path . --import --quit
godot --headless --path . --export-release "Windows Desktop" builds/windows/Niskala.exe
godot --headless --path . --export-debug Android builds/android/Niskala.apk
```

Android memakai JDK 17, Android SDK platform 35, build-tools 35.0.1, dan platform-tools. Atur Java SDK Path, Android SDK Path, serta debug keystore pada Editor Settings. Instalasi lokal terdapat di `tools/android/`; `tools/configure_exports.py` mengatur engine portabel terhadap instalasi ini. Keystore debug tidak masuk Git.

`tools/prepare_assets.py` membutuhkan Python, NumPy, dan Pillow; hanya perlu dijalankan untuk meregenerasi audio/UI/scene pembungkus dan paket ORA. Setelah menjalankannya, selalu lakukan import Godot sebelum menjalankan game.

## Pengujian

```powershell
godot --headless --path . --script tools/smoke.gd
godot --headless --path . --script tools/traversal.gd --fixed-fps 60 --disable-render-loop
godot --path . --script tools/capture.gd --resolution 1280x720
godot --path . --script tools/performance.gd --resolution 1280x720
```

Tes membuat progres sementara; gunakan APPDATA khusus pengujian untuk menjaga save pribadi. Capture mensimulasikan multitouch dan menyimpan gambar 16:9 serta 20:9. Traversal mematikan musuh untuk menguji keterjangkauan semua platform, sedangkan smoke test menguji combat dan kemenangan secara terpisah.

Hasil serta batas pengujian terdapat di `docs/VALIDATION.md`. Durasi 5–10 menit merupakan target pengalaman pemain pertama, bukan hasil playtest manusia. Android fisik belum diuji karena tidak ada perangkat terhubung.
