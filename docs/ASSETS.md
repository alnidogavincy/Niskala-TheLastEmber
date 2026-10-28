# Asal aset dan lisensi

## Arah seni

Referensi pengguna: **2D Art & Animation PORTFOLIO**, Trần Phương Thảo / Tran Thao, Behance, terutama bagian Senmu, karakter Rinn, golem Zigal, dan Ancient Forest of Nuior.

https://www.behance.net/gallery/236471005/2D-Art-Animation-PORTFOLIO

Screenshot dan HTML referensi tidak dikemas ke dalam build. Ilustrasi, karakter, atlas, props, canopy, serta pose lari Niskala dibuat baru menggunakan tool imagegen bawaan. Prompt tersimpan dalam `IMAGE_PROMPTS.md`. Gambar tidak diklaim sebagai karya manual seniman referensi.

## Aset proyek

| Aset | Sumber |
|---|---|
| forest.png | Ilustrasi hutan hasil imagegen |
| nara.png | Desain Nara hasil imagegen |
| nara_run.png | Empat pose lari hasil imagegen dengan nara.png sebagai referensi identitas |
| forest_atlas.png | Platform berlumut, makhluk akar, roh hutan, dan golem hasil imagegen |
| props.png | Altar serta portal hasil imagegen |
| canopy.png | Foreground dedaunan hasil imagegen |
| logo.svg, icon.svg, touch_*.svg | Geometri/lettering SVG khusus proyek |
| audio/*.wav | Sintesis musik, ambience, dan efek orisinal oleh tools/prepare_assets.py; tidak memakai rekaman pihak ketiga |
| Nunito.ttf | Nunito variable, Google Fonts, SIL Open Font License 1.1; teks lisensi: assets/Nunito-OFL.txt |
| Godot Engine 4.5.1 | Godot contributors, MIT; teks lisensi: docs/GODOT_LICENSE.txt |

Font sumber: https://github.com/google/fonts/tree/main/ofl/nunito

Sumber .ora menyimpan piksel asli, dengan layer foreground/background terpisah untuk hutan. Atlas tetap berupa satu layer raster yang bisa dipotong lebih lanjut dalam Krita. Tidak ada paket PSD/KRA dengan rig skeletal terpisah dalam versi ini.
