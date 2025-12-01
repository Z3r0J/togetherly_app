import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';

/// ViewModel para gestionar el idioma de la aplicación
/// Soporta: system, es (español), en (inglés)
class LocaleViewModel extends ChangeNotifier {
  static const String _localeKey = 'app_locale';

  Locale? _locale; // null = system

  Locale? get locale => _locale;

  /// Obtiene el idioma del sistema
  String _getSystemLocale() {
    final systemLocale = PlatformDispatcher.instance.locale.languageCode;

    // Validar que esté soportado
    if (AppLocalizations.supportedLocales.contains(systemLocale)) {
      return systemLocale;
    }

    // Fallback a español
    return 'es';
  }

  /// Carga el idioma guardado al iniciar la app
  Future<void> loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocale = prefs.getString(_localeKey);

      if (savedLocale != null && savedLocale != 'system') {
        _locale = Locale(savedLocale);
        // Cargar las traducciones del idioma guardado
        await AppLocalizations.load(locale: savedLocale);
        notifyListeners();
      } else {
        // Usar idioma del sistema
        _locale = null;
        final systemLocale = _getSystemLocale();
        await AppLocalizations.load(locale: systemLocale);
        notifyListeners();
      }
    } catch (e) {
      print('⚠️ Error loading locale: $e');
      // Fallback a español
      await AppLocalizations.load(locale: 'es');
    }
  }

  /// Cambia el idioma y lo guarda en SharedPreferences
  /// Si locale es null, usa el idioma del sistema
  Future<void> setLocale(Locale? newLocale) async {
    final oldLocale = _locale;
    _locale = newLocale;

    // Determinar qué idioma cargar
    final localeCode = newLocale?.languageCode ?? _getSystemLocale();

    // Cargar las traducciones del nuevo idioma
    await AppLocalizations.load(locale: localeCode);

    // Solo notificar si el locale cambió realmente
    if (oldLocale != newLocale) {
      notifyListeners();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      if (newLocale == null) {
        await prefs.setString(_localeKey, 'system');
      } else {
        await prefs.setString(_localeKey, newLocale.languageCode);
      }
    } catch (e) {
      print('⚠️ Error saving locale: $e');
    }
  }

  /// Verifica si está usando el idioma del sistema
  bool get isSystemLocale => _locale == null;

  /// Obtiene el código de idioma actual (para mostrar en UI)
  String get currentLocaleCode {
    if (_locale == null) {
      return 'system';
    }
    return _locale!.languageCode;
  }
}
