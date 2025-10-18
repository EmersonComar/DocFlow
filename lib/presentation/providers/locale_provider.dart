import 'package:flutter/material.dart';
import '../../data/datasources/local_database.dart';

/// LocaleProvider persists the user's language choice in the local
/// `user_preferences` table. Behavior:
/// - When `locale` is null the app follows the system locale.
/// - When `locale` is non-null the app forces the selected language.
class LocaleProvider extends ChangeNotifier {
  final LocalDatabase _database;

  Locale? _locale;

  LocaleProvider(this._database) {
    // Load saved preference on creation (fire-and-forget).
    _loadSavedLocale();
  }

  Locale? get locale => _locale;

  Future<void> _loadSavedLocale() async {
    try {
      final saved = await _database.getPreference('locale');
      if (saved != null && saved.isNotEmpty) {
        _locale = Locale(saved);
        notifyListeners();
      }
    } catch (_) {
      // ignore errors and leave locale null (follow system)
    }
  }

  /// Public method to reload the locale from persistent storage.
  Future<void> reload() async => await _loadSavedLocale();

  /// Sets the locale and persists the choice. Use `null` to follow system.
  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    notifyListeners();
    try {
      final value = locale == null ? '' : locale.languageCode;
      await _database.savePreference('locale', value);
    } catch (_) {
      // ignore persistence errors but UI already updated
    }
  }

  Future<void> clearLocale() async => await setLocale(null);
}
