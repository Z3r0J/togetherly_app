import 'package:flutter/material.dart';

/// Paleta de colores de la aplicación Togetherly
/// Basada en Material 3 con colores personalizados del diseño
class AppColors {
  // Prevenir instanciación
  AppColors._();

  // Colores primarios
  static const Color primary = Color(0xFF5B4FFF); // Púrpura principal
  static const Color primaryLight = Color(0xFF8A7FFF);
  static const Color primaryDark = Color(0xFF4538DB);

  // Colores de superficie
  static const Color surface = Color(0xFFFAFAFC);
  static const Color surfaceVariant = Color(0xFFF5F5F9);
  static const Color background = Color(0xFFFFFFFF);

  // Colores de texto
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textTertiary = Color(0xFF9B9B9B);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Colores de estado
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);
  static const Color info = Color(0xFF007AFF);

  // Colores para círculos/categorías
  static const Color circleGreen = Color(0xFF34C759);
  static const Color circlePurple = Color(0xFF9B6FFF);
  static const Color circleOrange = Color(0xFFFF9500);
  static const Color circleBlue = Color(0xFF007AFF);
  static const Color circlePink = Color(0xFFFF6B9D);
  static const Color circleTeal = Color(0xFF32AFA9);
  static const Color circleRed = Color(0xFFFF3B30);
  static const Color circleYellow = Color(0xFFFFCC00);

  // Colores de RSVP
  static const Color rsvpGoing = Color(0xFF34C759);
  static const Color rsvpMaybe = Color(0xFFFF9500);
  static const Color rsvpNotGoing = Color(0xFFFF3B30);

  // Colores de borde y división
  static const Color border = Color(0xFFE5E5EA);
  static const Color divider = Color(0xFFF2F2F7);

  // Sombras
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);

  // Colores de overlay
  static const Color overlay = Color(0x33000000);
  static const Color scrim = Color(0x80000000);
}

/// Lista de colores disponibles para círculos
const List<Color> circleColors = [
  AppColors.circlePurple,
  AppColors.circleBlue,
  AppColors.circleGreen,
  AppColors.circleOrange,
  AppColors.circlePink,
  AppColors.circleTeal,
  AppColors.circleRed,
  AppColors.circleYellow,
];
