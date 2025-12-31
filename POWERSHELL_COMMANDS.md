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

## 🚀 Git Release Workflow (PowerShell)

### 1. Lihat perubahan
```powershell
git status
git diff
```

### 2. Add semua perubahan
```powershell
git add .
```

### 3. Commit
```powershell
git commit -m "Release v1.2.0: Performance improvements and UX enhancements"
```

### 4. Create dan push tag
```powershell
# Buat tag
git tag v1.2.0

# Push commit dan tag
git push origin master
git push origin v1.2.0
```

### 5. Jika perlu hapus tag (rollback)
```powershell
# Hapus tag lokal
git tag -d v1.2.0

# Hapus tag remote
git push origin --delete v1.2.0
```

## 🔐 Security Check

### Cek apakah file sensitif ter-track
```powershell
# Cek key.properties
git ls-files | Select-String "key.properties"

# Cek semua keystore
git ls-files | Select-String ".jks"
git ls-files | Select-String ".keystore"
```

### Jika file sensitif sudah ter-commit (DANGER!)
```powershell
# HATI-HATI: Ini akan rewrite history!
git filter-branch --force --index-filter `
  "git rm --cached --ignore-unmatch android/key.properties" `
  --prune-empty --tag-name-filter cat -- --all

# Force push (DANGER!)
git push origin --force --all
```

## 📁 File Management

### Lihat isi folder
```powershell
# List semua file
Get-ChildItem

# List dengan detail
Get-ChildItem -Force | Format-Table Name, Length, LastWriteTime

# Cari file tertentu
Get-ChildItem -Recurse -Filter "*.apk"
```

### Copy file
```powershell
Copy-Item source.txt destination.txt
```

### Move file
```powershell
Move-Item old-name.txt new-name.txt
```

## 🔄 Quick Commands untuk Release

### Pre-release checklist
```powershell
# 1. Clean dan test
flutter clean
flutter pub get
flutter analyze
flutter test

# 2. Build release APK
flutter build apk --release

# 3. Cek ukuran APK
Get-Item build/app/outputs/flutter-apk/app-release.apk | Select-Object Name, Length

# 4. Commit dan tag
git add .
git commit -m "Release v1.2.0"
git tag v1.2.0
git push origin master
git push origin v1.2.0
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
