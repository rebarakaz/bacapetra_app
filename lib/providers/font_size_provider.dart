import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontSizeProvider with ChangeNotifier {
  static const String _fontSizeScaleKey = 'fontSizeScale';
  double _fontSizeScale = 1.0; // Default scale

  FontSizeProvider() {
    _loadFontSizeScale();
  }

  double get fontSizeScale => _fontSizeScale;

  void _loadFontSizeScale() async {
    final prefs = await SharedPreferences.getInstance();
    _fontSizeScale = prefs.getDouble(_fontSizeScaleKey) ?? 1.0;
    notifyListeners();
  }

  void setFontSizeScale(double newScale) async {
    if (newScale != _fontSizeScale) {
      _fontSizeScale = newScale;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      prefs.setDouble(_fontSizeScaleKey, newScale);
    }
  }

  void increaseFontSize() {
    if (_fontSizeScale < 1.5) { // Max 1.5x
      setFontSizeScale(_fontSizeScale + 0.1);
    }
  }

  void decreaseFontSize() {
    if (_fontSizeScale > 0.7) { // Min 0.7x
      setFontSizeScale(_fontSizeScale - 0.1);
    }
  }

  void resetFontSize() {
    setFontSizeScale(1.0);
  }
}
