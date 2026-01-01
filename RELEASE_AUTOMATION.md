# Panduan Rilis Otomatis

## Gambaran Umum

Repositori ini sekarang menyertakan otomasi GitHub Actions untuk proses build dan
rilis file APK. Anda tidak perlu lagi membuat dan mengunggah APK secara manual!

## Cara Kerja

### Proses Rilis Otomatis

1. **Buat `tag` pada commit Anda** dengan nomor versi (contoh: `v1.2.0`).
2. **Push `tag` tersebut** ke GitHub.
3. **GitHub Actions akan secara otomatis**:
    - Melakukan build untuk APK rilis.
    - Membuat halaman GitHub Release baru.
    - Mengunggah file APK ke halaman rilis tersebut.
    - Menggunakan konten dari file catatan rilis Anda sebagai deskripsi.

### Instruksi Langkah-demi-Langkah

#### 1. Persiapan Rilis

Pastikan semua perubahan sudah di-commit dan Anda sudah membuat file catatan
rilis (`RELEASE_NOTES_vX.X.X.md`).

```bash
# Contoh commit
git add .
git commit -m "Rilis v1.2.0: Menambahkan progress bar dan cache gambar"
```

#### 2. Buat dan Push Tag Versi

```bash
# Buat tag (ganti v1.2.0 dengan versi Anda)
git tag -a v1.2.0 -m "Release v1.2.0"

# Push tag ke GitHub untuk memulai automasi
git push origin v1.2.0
```

#### 3. Tunggu Proses Otomatis Selesai

- Buka tab "Actions" di repositori GitHub Anda.
- Anda bisa memantau proses build (biasanya memakan waktu 5-10 menit).
- Setelah selesai, periksa halaman "Releases" di repositori Anda.

#### 4. Verifikasi Rilis

- File APK akan terunggah secara otomatis.
- Deskripsi rilis akan diisi dari file `RELEASE_NOTES_v1.2.0.md`.
- Tautan unduhan akan langsung tersedia.

## Format Catatan Rilis

Untuk setiap versi, buat sebuah file dengan nama `RELEASE_NOTES_v{VERSI}.md`
di direktori utama proyek.

- Contoh: `RELEASE_NOTES_v1.2.0.md`
- File ini akan digunakan sebagai deskripsi rilis.
- Sertakan informasi seperti fitur baru, perbaikan bug, dan perubahan signifikan.

## Troubleshooting

### Build Gagal

- Periksa log eror pada tab "Actions".
- Pastikan versi di `pubspec.yaml` sesuai dengan tag Anda.
- Verifikasi semua dependensi sudah benar.

### Rilis Tidak Dibuat

- Pastikan Anda melakukan push **tag**, bukan hanya commit (`git push origin v1.2.0`).
- Tag harus mengikuti format `v*.*.*` (contoh: `v1.2.0`).
- Periksa perizinan GitHub Actions di pengaturan repositori.

### Override Manual

Jika Anda terpaksa perlu melakukan build manual:

```bash
flutter build apk --release
```

File APK akan berada di: `build/app/outputs/flutter-apk/app-release.apk`

---

> **Selamat Merilis! 🚀**
