// App-wide constants
class AppConstants {
  // API Configuration
  static const String baseUrl = 'https://www.bacapetra.co/wp-json/wp/v2';
  static const int defaultPageSize = 10;
  static const int kirimTulisanPageId = 59;

  // UI Constants
  static const double cardBorderRadius = 12.0;
  static const double cardElevation = 5.0;
  static const double defaultPadding = 16.0;
  static const double cardMargin = 12.0;

  // Image dimensions
  static const double postImageHeight = 200.0;

  // Text limits
  static const int excerptMaxLines = 3;

  // Scroll thresholds
  static const double scrollThreshold = 200.0;

  // Theme keys
  static const String themeModeKey = 'theme_mode';

  // Feature Flags (for future development planning)
  static const bool enablePushNotifications = false;
  static const bool enableOfflineReading = true; // Offline reading implemented
  static const bool enableSocialFeatures = true; // Sharing already implemented
  static const bool enableReadingTracker = true; // Reading progress implemented
  static const bool enableAdvancedSearch = true; // Already implemented
  static const bool enablePopularPosts = true; // Popular posts by comment count implemented
  static const bool enableCommentPosting = false; // Temporarily disabled
  static const bool enablePullToRefresh = true; // Already implemented across all screens
}
