import 'package:flutter/material.dart';
import '../../data/datasources/local_database.dart';

class ThemeNotifier extends ChangeNotifier {
  final LocalDatabase _database;
  ThemeMode _themeMode = ThemeMode.system;
  static const String _themePrefKey = 'themeMode';

  ThemeNotifier(this._database);

  ThemeMode get themeMode => _themeMode;

  Future<void> loadTheme() async {
    try {
      final themeString = await _database.getPreference(_themePrefKey);
      
      _themeMode = switch (themeString) {
        'dark' => ThemeMode.dark,
        'light' => ThemeMode.light,
        'system' => ThemeMode.system,
        _ => ThemeMode.system,
      };
      
      notifyListeners();
    } catch (_) {
      _themeMode = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    await _saveThemePreference();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = switch (_themeMode) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
      ThemeMode.system => ThemeMode.light,
    };
    
    await _saveThemePreference();
    notifyListeners();
  }

  Future<void> _saveThemePreference() async {
    final themeString = switch (_themeMode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
    };
    
    try {
      await _database.savePreference(_themePrefKey, themeString);
    } catch (_) {}
  }
}