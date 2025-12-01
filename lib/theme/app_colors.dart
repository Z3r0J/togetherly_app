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

  // Helper method to get circle color from string (supports both hex and color names)
  static Color getCircleColor(String colorInput) {
    // If it starts with #, parse as hex
    if (colorInput.startsWith('#')) {
      try {
        return Color(int.parse(colorInput.replaceFirst('#', '0xFF')));
      } catch (e) {
        print('⚠️ Failed to parse hex color: $colorInput, using default');
        return circlePurple;
      }
    }

    // Otherwise, treat as color name
    switch (colorInput.toLowerCase()) {
      case 'purple':
        return circlePurple;
      case 'blue':
        return circleBlue;
      case 'green':
        return circleGreen;
      case 'orange':
        return circleOrange;
      case 'pink':
        return circlePink;
      case 'teal':
        return circleTeal;
      case 'red':
        return circleRed;
      case 'yellow':
        return circleYellow;
      default:
        return circlePurple; // Default fallback
    }
  }

  // Helper method to convert hex string to Color
  static Color hexToColor(String hexString) {
    try {
      final hex = hexString.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      print('⚠️ Failed to parse hex color: $hexString, using default');
      return circlePurple;
    }
  }
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

/// Paleta de colores para modo oscuro
class AppColorsDark {
  // Prevenir instanciación
  AppColorsDark._();

  // Colores primarios
  static const Color primary = Color(
    0xFF7D72FF,
  ); // Púrpura más brillante para dark
  static const Color primaryLight = Color(0xFFA199FF);
  static const Color primaryDark = Color(0xFF5B4FFF);

  // Colores de superficie
  static const Color surface = Color(0xFF1C1C1E); // Fondo gris oscuro
  static const Color surfaceVariant = Color(0xFF2C2C2E);
  static const Color background = Color(0xFF000000);

  // Colores de texto
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textTertiary = Color(0xFF8E8E93);
  static const Color textOnPrimary = Color(0xFF000000);

  // Colores de estado (más brillantes para dark mode)
  static const Color success = Color(0xFF30D158);
  static const Color warning = Color(0xFFFFB340);
  static const Color error = Color(0xFFFF453A);
  static const Color info = Color(0xFF0A84FF);

  // Colores para círculos/categorías (más brillantes)
  static const Color circleGreen = Color(0xFF30D158);
  static const Color circlePurple = Color(0xFFAF8FFF);
  static const Color circleOrange = Color(0xFFFFB340);
  static const Color circleBlue = Color(0xFF0A84FF);
  static const Color circlePink = Color(0xFFFF7AB2);
  static const Color circleTeal = Color(0xFF40C8C2);
  static const Color circleRed = Color(0xFFFF453A);
  static const Color circleYellow = Color(0xFFFFD60A);

  // Colores de RSVP
  static const Color rsvpGoing = Color(0xFF30D158);
  static const Color rsvpMaybe = Color(0xFFFFB340);
  static const Color rsvpNotGoing = Color(0xFFFF453A);

  // Colores de borde y división
  static const Color border = Color(0xFF38383A);
  static const Color divider = Color(0xFF2C2C2E);

  // Sombras
  static const Color shadow = Color(0x4D000000);
  static const Color shadowLight = Color(0x26000000);

  // Colores de overlay
  static const Color overlay = Color(0x66000000);
  static const Color scrim = Color(0xB3000000);

  // Helper method to get circle color from string
  static Color getCircleColor(String colorInput) {
    if (colorInput.startsWith('#')) {
      try {
        return Color(int.parse(colorInput.replaceFirst('#', '0xFF')));
      } catch (e) {
        print('⚠️ Failed to parse hex color: $colorInput, using default');
        return circlePurple;
      }
    }

    switch (colorInput.toLowerCase()) {
      case 'purple':
        return circlePurple;
      case 'blue':
        return circleBlue;
      case 'green':
        return circleGreen;
      case 'orange':
        return circleOrange;
      case 'pink':
        return circlePink;
      case 'teal':
        return circleTeal;
      case 'red':
        return circleRed;
      case 'yellow':
        return circleYellow;
      default:
        return circlePurple;
    }
  }

  // Helper method to convert hex string to Color
  static Color hexToColor(String hexString) {
    try {
      final hex = hexString.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      print('⚠️ Failed to parse hex color: $hexString, using default');
      return circlePurple;
    }
  }
}

/// Lista de colores disponibles para círculos en modo oscuro
const List<Color> circleColorsDark = [
  AppColorsDark.circlePurple,
  AppColorsDark.circleBlue,
  AppColorsDark.circleGreen,
  AppColorsDark.circleOrange,
  AppColorsDark.circlePink,
  AppColorsDark.circleTeal,
  AppColorsDark.circleRed,
  AppColorsDark.circleYellow,
];
