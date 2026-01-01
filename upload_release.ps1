# Definisikan variabel untuk versi dan nama aplikasi
$appVersion = "1.2.0"
$appName = "BacaPetra"
$githubTag = "$appName v$appVersion - Stable"
$apkFileName = "$appName-v$appVersion.apk"

# Path standar output dari Flutter build
$sourceApkPath = "build\app\outputs\flutter-apk\app-release.apk"
$renamedApkPath = "build\app\outputs\flutter-apk\$apkFileName"

# 1. Build APK untuk release
Write-Host "Memulai proses build Flutter APK..."
flutter build apk --release

if (-not $?) {
    Write-Error "Build Flutter gagal. Silakan periksa error di atas."
    exit 1
}

Write-Host "Build APK berhasil."

# 2. Rename file APK
Write-Host "Mengganti nama file dari app-release.apk menjadi $apkFileName..."
if (Test-Path $renamedApkPath) {
    Remove-Item $renamedApkPath
    Write-Host "File lama ($apkFileName) ditemukan dan telah dihapus."
}
Rename-Item -Path $sourceApkPath -NewName $apkFileName
Write-Host "File berhasil diganti namanya menjadi $renamedApkPath"

# 3. Upload ke GitHub Release
Write-Host "Mengupload $apkFileName ke GitHub Release dengan tag '$githubTag'..."
# Opsi --clobber akan menimpa file jika sudah ada di release tersebut
gh release upload $githubTag $renamedApkPath --clobber

if ($?) {
    Write-Host "Upload berhasil! Cek rilis di GitHub Anda."
} else {
    Write-Error "Upload gagal. Pastikan tag '$githubTag' sudah ada di GitHub dan Anda sudah login via 'gh auth login'."
}
