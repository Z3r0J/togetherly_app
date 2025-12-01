import 'package:flutter/material.dart';

/// Extension methods for easy theme access
extension ThemeExtensions on BuildContext {
  /// Get the current theme
  ThemeData get theme => Theme.of(this);

  /// Get the color scheme
  ColorScheme get colors => theme.colorScheme;

  /// Get text theme
  TextTheme get textTheme => theme.textTheme;

  /// Common colors for quick access
  Color get primaryColor => colors.primary;
  Color get surfaceColor => colors.surface;
  Color get backgroundColor => colors.surface;
  Color get textPrimaryColor => colors.onSurface;
  Color get textSecondaryColor => colors.onSurfaceVariant;
  Color get borderColor => colors.outline;
}
