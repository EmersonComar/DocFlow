import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; 
  static const String _themePrefKey = 'themeMode';

  ThemeMode get themeMode => _themeMode;

  Future<void> loadTheme() async {
    final themeString = await DatabaseHelper.instance.getPreference(_themePrefKey);
    if (themeString == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (themeString == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system; 
    }
    notifyListeners();
  }

  void toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _saveThemePreference();
    notifyListeners();
  }

  Future<void> _saveThemePreference() async {
    final themeString = _themeMode == ThemeMode.dark ? 'dark' : 'light';
    await DatabaseHelper.instance.savePreference(_themePrefKey, themeString);
  }
}
