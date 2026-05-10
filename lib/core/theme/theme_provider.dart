// lib/core/theme/theme_provider.dart
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDark => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setDark()  { _themeMode = ThemeMode.dark;   notifyListeners(); }
  void setLight() { _themeMode = ThemeMode.light;  notifyListeners(); }
  void setSystem(){ _themeMode = ThemeMode.system; notifyListeners(); }
}