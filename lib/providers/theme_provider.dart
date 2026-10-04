import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Thème choisi par l'utilisateur, persisté. Sombre par défaut.
class ThemeProvider extends ChangeNotifier {
  ThemeProvider(this._prefs)
      : _mode = ThemeMode.values.asNameMap()[_prefs.getString(_key)] ?? ThemeMode.dark;

  static const _key = 'theme_mode';
  final SharedPreferences _prefs;
  ThemeMode _mode;

  ThemeMode get mode => _mode;

  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
    await _prefs.setString(_key, mode.name);
  }
}
