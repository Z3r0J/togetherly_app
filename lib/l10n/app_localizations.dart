import 'dart:convert';
import 'package:flutter/services.dart';

/// Sistema de localización simple basado en JSON
///
/// Uso:
/// ```dart
/// // En main.dart
/// await AppLocalizations.load();
///
/// // En cualquier parte de la app
/// final l10n = AppLocalizations.instance;
/// Text(l10n.tr('auth.login.title'))
/// Text(l10n.trError('AUTH_INVALID_CREDENTIALS'))
/// ```
class AppLocalizations {
  static AppLocalizations? _instance;
  static AppLocalizations get instance => _instance ?? AppLocalizations._();

  AppLocalizations._();

  Map<String, dynamic> _localizedStrings = {};
  bool _isLoaded = false;
  String _currentLocale = 'es';

  /// Idiomas soportados
  static const List<String> supportedLocales = ['es', 'en'];

  /// Obtiene el idioma actual
  String get currentLocale => _currentLocale;

  /// Carga el archivo JSON de traducciones
  /// Soporta: 'es' (español) y 'en' (inglés)
  static Future<void> load({String locale = 'es'}) async {
    _instance = AppLocalizations._();

    try {
      // Validar que el locale esté soportado
      final validLocale = supportedLocales.contains(locale) ? locale : 'es';

      final jsonString = await rootBundle.loadString(
        'assets/l10n/$validLocale.json',
      );
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      _instance!._localizedStrings = jsonMap;
      _instance!._currentLocale = validLocale;
      _instance!._isLoaded = true;
    } catch (e) {
      throw Exception('Error cargando archivo de traducción: $e');
    }
  }

  /// Cambia el idioma dinámicamente
  static Future<void> changeLocale(String locale) async {
    await load(locale: locale);
  }

  /// Traduce una clave usando notación punto
  /// Ejemplo: tr('auth.login.title') → 'Togetherly'
  /// Si no encuentra la clave, devuelve la misma clave
  String tr(String key) {
    if (!_isLoaded) {
      return key; // Fallback si no se ha cargado
    }

    final keys = key.split('.');
    dynamic current = _localizedStrings;

    for (final k in keys) {
      if (current is Map<String, dynamic> && current.containsKey(k)) {
        current = current[k];
      } else {
        // No se encontró la clave, devolver la key original
        return key;
      }
    }

    return current is String ? current : key;
  }

  /// Traduce un código de error del backend
  /// Busca en diferentes secciones: auth.error, user.error, circle.error, etc.
  ///
  /// Ejemplo: trError('AUTH_INVALID_CREDENTIALS') → 'Correo o contraseña inválidos'
  String trError(String errorCode) {
    if (!_isLoaded) {
      return errorCode;
    }

    // Determinar la sección según el prefijo del error code
    String section = _getErrorSection(errorCode);

    // Intentar buscar en la sección específica
    String key = '$section.error.$errorCode';
    String translation = tr(key);

    // Si no se encontró, devolver el errorCode
    return translation != key ? translation : errorCode;
  }

  /// Determina la sección de error basándose en el prefijo del errorCode
  String _getErrorSection(String errorCode) {
    if (errorCode.startsWith('AUTH_')) {
      return 'auth';
    } else if (errorCode.startsWith('USER_')) {
      return 'user';
    } else if (errorCode.startsWith('CIRCLE_')) {
      return 'circle';
    } else if (errorCode.startsWith('EVENT_')) {
      return 'event';
    } else if (errorCode.startsWith('VALIDATION_')) {
      return 'validation';
    } else if (errorCode.startsWith('DB_') ||
        errorCode.startsWith('INTERNAL_') ||
        errorCode.startsWith('SERVICE_') ||
        errorCode.startsWith('NOT_') ||
        errorCode.startsWith('RATE_') ||
        errorCode.startsWith('REQUEST_') ||
        errorCode.startsWith('PAYLOAD_') ||
        errorCode.startsWith('UNKNOWN_') ||
        errorCode.startsWith('EMAIL_') ||
        errorCode.startsWith('STORAGE_') ||
        errorCode.startsWith('EXTERNAL_')) {
      return 'system';
    }

    // Si no coincide con ningún prefijo, intentar auth por defecto
    return 'auth';
  }

  /// Verifica si las traducciones están cargadas
  bool get isLoaded => _isLoaded;

  /// Acceso directo a strings comunes
  String get buttonCancel => tr('common.button.cancel');
  String get buttonOk => tr('common.button.ok');
  String get buttonSave => tr('common.button.save');
  String get buttonConfirm => tr('common.button.confirm');
  String get buttonSend => tr('common.button.send');

  String get labelEmail => tr('common.label.email');
  String get labelPassword => tr('common.label.password');
  String get labelLoading => tr('common.label.loading');
  String get labelError => tr('common.label.error');

  /// Helper para errores de red comunes (cuando no viene del backend)
  String get networkError => tr('auth.error.NETWORK_ERROR');
  String get timeoutError => tr('auth.error.TIMEOUT_ERROR');
  String get unknownError => tr('auth.error.UNKNOWN_ERROR');
}
