#!/bin/bash

# BacaPetra Beta Release Build Script
# Version: 1.1.0-beta.1

echo "🚧 Building BacaPetra Beta v1.1.0-beta.1 🚧"
echo "=========================================="

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build APK for beta release
echo "🔨 Building APK..."
flutter build apk --release --build-name=1.1.0 --build-number=1

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo ""
    echo "📱 APK Location:"
    echo "   build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    echo "📋 Release Information:"
    echo "   Version: 1.1.0-beta.1"
    echo "   Build: 1"
    echo "   Branch: release/beta-v1.1.0"
    echo ""
    echo "📄 Release Notes: BETA_README.md"
    echo ""
    echo "🎯 Ready for beta distribution!"
else
    echo "❌ Build failed!"
    exit 1
fi
