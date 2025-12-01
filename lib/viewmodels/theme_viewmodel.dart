import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ViewModel para gestionar el tema de la aplicación
/// Soporta: light, dark y system (automático según el dispositivo)
class ThemeViewModel extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  /// Carga el tema guardado al iniciar la app
  Future<void> loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_themeModeKey);

      if (savedMode != null) {
        _themeMode = _parseThemeMode(savedMode);
        notifyListeners();
      }
    } catch (e) {
      print('⚠️ Error loading theme mode: $e');
    }
  }

  /// Cambia el tema y lo guarda en SharedPreferences
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, _themeModeToString(mode));
    } catch (e) {
      print('⚠️ Error saving theme mode: $e');
    }
  }

  /// Convierte ThemeMode a String para guardar
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// Convierte String a ThemeMode al cargar
  ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
