import 'package:html_unescape/html_unescape.dart';

final unescape = HtmlUnescape();

/// Calculate estimated reading time for text content
/// Based on average reading speed of 200 words per minute
String calculateReadingTime(String htmlContent, {int wordsPerMinute = 200}) {
  try {
    // Remove HTML tags to get plain text
    final plainText = htmlContent.replaceAll(RegExp(r'<[^>]*>'), '');

    // Count words (split by whitespace and filter empty strings)
    final words = plainText.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
    final wordCount = words.length;

    if (wordCount == 0) return '0 min baca';

    // Calculate reading time in minutes
    final readingTimeMinutes = (wordCount / wordsPerMinute).ceil();

    // Return formatted string in Bahasa Indonesia
    if (readingTimeMinutes == 1) {
      return '1 min baca';
    } else if (readingTimeMinutes < 60) {
      return '$readingTimeMinutes min baca';
    } else {
      // For very long articles, show in hours
      final hours = readingTimeMinutes ~/ 60;
      final remainingMinutes = readingTimeMinutes % 60;
      if (remainingMinutes == 0) {
        return '$hours jam baca';
      } else {
        return '$hours jam $remainingMinutes min baca';
      }
    }
  } catch (e) {
    // Fallback for any parsing errors
    return '3 min baca';
  }
}
