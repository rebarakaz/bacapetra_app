# 🚧 BacaPetra Beta Release v1.1.0-beta.1 🚧

## ⚠️ Beta Version Warning

**This is a BETA release that may contain bugs and unfinished features.**

- Please report any issues you encounter
- Some features may not work as expected
- Data loss is possible (backup important articles)
- Performance may vary on different devices

## 📱 What's New in Beta v1.1.0

### ✨ Major Features

#### 🏪 **Offline Reading** (NEW!)
- **Download articles** for offline reading
- **Local storage** with SQLite database
- **Offline screen** to manage saved articles
- **Smart storage management** with usage statistics
- **Swipe-to-delete** for easy article removal

#### ⚡ **Performance Optimizations**
- **Smooth scrolling** in article reading
- **Throttled progress updates** (100ms intervals)
- **Optimized HTML rendering** with shrinkWrap
- **Reduced battery consumption** during reading

#### 🎨 **UI/UX Improvements**
- **Navigation drawer** with offline access
- **Beta warning banner** in app bar
- **Enhanced error handling** and user feedback
- **Consistent design** across all screens

### 🔧 Technical Improvements

#### Database & Storage
- SQLite integration for offline articles
- Efficient data serialization
- Storage statistics and cleanup tools

#### Performance
- Scroll event throttling
- Smart state management
- Memory-efficient rendering

#### Code Quality
- Clean architecture with services
- Proper error handling
- Comprehensive logging

## 🐛 Known Issues & Limitations

### Current Beta Limitations:
- **Push notifications** not yet implemented
- **Comment posting** temporarily disabled
- **Advanced search filters** in development
- **Social features** expansion planned

### Development Notes:
- **Linting warnings**: Some VS Code analysis warnings for sqflite imports may appear
  - These are analysis server issues, not runtime problems
  - The app builds and runs correctly despite the warnings
  - Restart VS Code analysis server if needed: `Ctrl+Shift+P` → `Dart: Restart Analysis Server`

### Performance Notes:
- First app launch may be slower due to database initialization
- Large articles may take time to download for offline reading
- Storage management is manual (auto-cleanup coming in future)

## 📋 Installation Instructions

### For Beta Testers:

1. **Download the APK** from the beta release
2. **Install** on your Android device
3. **Grant permissions** when requested
4. **First launch** will initialize the database

### System Requirements:
- **Android 5.0+** (API 21+)
- **50MB free storage** for app + offline articles
- **Internet connection** for initial setup and article downloads

## 🐛 Bug Reporting

Found a bug? Please report it:

### How to Report:
1. **Go to app drawer** → **About App**
2. **Note the version**: `1.1.0-beta.1`
3. **Describe the issue** with steps to reproduce
4. **Include device info** (Android version, device model)
5. **Attach screenshots** if possible

### Report Channels:
- **GitHub Issues**: [Report Bug](https://github.com/rebarakaz/bacapetra_app/issues)
- **Email**: Include "BETA BUG REPORT" in subject
- **In-app feedback**: Coming in future beta

## 📊 Beta Testing Goals

### We're testing:
- ✅ **Offline reading functionality**
- ✅ **Performance optimizations**
- ✅ **Database reliability**
- ✅ **User interface consistency**
- 🔄 **Cross-device compatibility**
- 🔄 **Memory management**
- 🔄 **Battery efficiency**

## 🗺️ Roadmap for Stable Release

### v1.1.0 (Stable) - Coming Soon:
- [ ] Push notifications
- [ ] Advanced search filters
- [ ] Reading streaks and analytics
- [ ] Enhanced social features
- [ ] Auto-cleanup for offline storage
- [ ] Performance monitoring

### v1.2.0 - Future:
- [ ] Dark mode improvements
- [ ] Reading themes
- [ ] Export functionality
- [ ] Multi-language support

## 🙏 Beta Tester Thanks

Thank you for helping us improve BacaPetra! Your feedback is invaluable in creating the best reading experience possible.

### Beta Tester Perks:
- **Early access** to new features
- **Direct influence** on app development
- **Bug fixes** prioritized for your reports
- **Special mentions** in release notes

## 📞 Support

### For Beta Issues:
- **Check this README** first
- **Restart the app** if experiencing issues
- **Clear app data** as last resort (will lose offline articles)

### Contact:
- **Version**: 1.1.0-beta.1
- **Build**: 1
- **Release Date**: September 2025

---

**🚧 This is a BETA release. Use at your own risk. 🚧**

*Made with ❤️ for the Indonesian literary community*
