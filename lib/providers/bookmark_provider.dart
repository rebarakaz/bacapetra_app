// lib/providers/bookmark_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkProvider extends ChangeNotifier {
  List<String> _bookmarkIds = [];
  static const String _kBookmarksKey = 'bookmark_post_ids';

  List<String> get bookmarkIds => _bookmarkIds;

  BookmarkProvider() {
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    _bookmarkIds = prefs.getStringList(_kBookmarksKey) ?? [];
    notifyListeners();
  }

  Future<void> _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kBookmarksKey, _bookmarkIds);
  }

  bool isBookmarked(int postId) {
    return _bookmarkIds.contains(postId.toString());
  }

  void toggleBookmark(int postId) {
    final postIdStr = postId.toString();
    if (isBookmarked(postId)) {
      _bookmarkIds.remove(postIdStr);
    } else {
      _bookmarkIds.add(postIdStr);
    }
    _saveBookmarks();
    notifyListeners();
  }
}
