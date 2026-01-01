# PowerShell Commands Cheat Sheet untuk BacaPetra Development

## 🔍 Git Status & File Checking

### Cek status git

```powershell
git status
```

### Cek apakah file tertentu ada di git status (alternatif grep)

```powershell
# Cek apakah key.properties muncul di git status
git status | Select-String "key.properties"

# Atau lebih simple
git ls-files | Select-String "key.properties"
```

### Lihat file yang diabaikan gitignore

```powershell
git status --ignored
```

## 🗑️ Menghapus File

### Hapus file log (PowerShell)

```powershell
# Hapus semua file .log
Remove-Item *.log -ErrorAction SilentlyContinue

# Hapus file dengan pattern tertentu
Remove-Item flutter_*.log, build_log.txt -ErrorAction SilentlyContinue

# Hapus folder build
Remove-Item -Recurse -Force build
```

### Hapus file dari Git tracking (tapi tetap di lokal)

```powershell
# Hapus key.properties dari git tracking
git rm --cached android/key.properties

# Hapus folder dari git tracking
git rm -r --cached android/app/build
```

## 📦 Flutter Commands

### Build APK Release

```powershell
flutter build apk --release
```

### Clean build

```powershell
flutter clean
flutter pub get
```

### Run debug

```powershell
flutter run --debug
```

## 🚀 Alur Kerja Rilis Otomatis (via GitHub Actions)

Proses rilis sekarang sepenuhnya otomatis.
Anda tidak perlu lagi build APK secara manual.

### 1. Persiapan

Pastikan semua perubahan kode sudah di-commit dan Anda sudah membuat file
`RELEASE_NOTES_vX.X.X.md` yang sesuai.

```powershell
# Contoh: commit semua perubahan
git add .
git commit -m "Fitur baru untuk v1.2.0"
git push origin main
```

### 2. Memicu Rilis

Cukup buat tag baru dan push tag tersebut ke remote. Hal ini akan secara otomatis
memulai proses build dan rilis di GitHub.

```powershell
# Ganti v1.2.0 dengan versi baru Anda
git tag -a v1.2.0 -m "Release v1.2.0"

# Push tag untuk memulai automasi
git push origin v1.2.0
```

Setelah push, periksa tab "Actions" di repositori GitHub Anda
untuk melihat prosesnya berjalan.

### Jika Perlu Membatalkan Rilis (Rollback Tag)

```powershell
# Hapus tag lokal
git tag -d v1.2.0

# Hapus tag di remote
git push origin --delete v1.2.0
```

## 💡 Tips PowerShell

### Buat alias untuk command yang sering dipakai

```powershell
# Tambahkan ke $PROFILE
Set-Alias -Name frun -Value "flutter run --debug"
Set-Alias -Name fbuild -Value "flutter build apk --release"
```

### Lihat history command

```powershell
Get-History
```

### Clear terminal

```powershell
Clear-Host
# atau
cls
```

## 🆘 Troubleshooting

### Git tidak mengenali perubahan gitignore

```powershell
# Clear git cache
git rm -r --cached .
git add .
git commit -m "Update gitignore"
```

### Flutter build error

```powershell
# Full clean
flutter clean
Remove-Item -Recurse -Force build
flutter pub get
flutter pub upgrade
```

### Gradle build error

```powershell
# Clean gradle
cd android
./gradlew clean
cd ..
flutter clean
```

---

**Simpan file ini untuk referensi cepat!** 📌
