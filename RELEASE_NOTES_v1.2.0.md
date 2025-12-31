# BacaPetra v1.2.0 Release Notes 🎉

**Release Date:** January 1, 2026

## 🚀 What's New

### Performance Improvements
- **⚡ Image Caching**: Implemented intelligent image caching using `cached_network_image`. Images are now cached locally, resulting in:
  - Faster loading times for previously viewed articles
  - Reduced data usage (images load instantly from cache)
  - Smoother scrolling experience
  
- **📊 Reading Progress Bar**: Added a visual progress indicator at the top of article screens
  - Shows your reading progress in real-time
  - Optimized implementation using `ValueNotifier` to prevent UI lag
  - Smooth, butter-like scrolling even on mid-range devices

### UX Enhancements
- **🔍 Improved Navigation**: Redesigned bottom navigation for better usability
  - Moved "Search" from bottom nav to AppBar for quick access from anywhere
  - Renamed "Kirim Tulisan" to "Menulis" to prevent text clipping
  - Cleaner 4-tab layout: Beranda, Rubrik, Populer, Menulis

- **📱 Enhanced Drawer Menu**: Completely revamped hamburger menu
  - Added beautiful CircleAvatar with book icon in header
  - Renamed "Tersimpan" to "Bookmark" for clarity
  - New "Media Sosial" section with direct links to:
    - BacaPetra Website
    - BacaPetra Instagram
  - Expanded "Tentang Aplikasi" with more detailed information about Yayasan Klub Buku Petra

### Bug Fixes
- Fixed Hero animation tag collisions between popular posts carousel and regular posts
- Resolved scroll performance issues in article detail screen
- Fixed Android build path issues for better compatibility

## 🔧 Technical Improvements
- Optimized reading time calculation (now cached during initialization)
- Improved state management for scroll progress tracking
- Better error handling for external link launches
- Updated app version display in About dialog

## 📦 Dependencies
- Added `cached_network_image` for image optimization
- Updated existing dependencies to latest stable versions

## 🎯 Breaking Changes
None - this is a fully backward-compatible release.

## 📱 Download
Download the latest APK from the [Releases page](https://github.com/rebarakaz/bacapetra_app/releases/tag/v1.2.0).

## 🙏 Acknowledgments
Special thanks to the BacaPetra community and Yayasan Klub Buku Petra for their continued support.

---

**Full Changelog**: [v1.1.0...v1.2.0](https://github.com/rebarakaz/bacapetra_app/compare/v1.1.0...v1.2.0)
