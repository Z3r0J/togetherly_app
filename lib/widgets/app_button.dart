import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Tipos de botón disponibles en la aplicación
enum AppButtonType { primary, secondary, outline, text, destructive }

/// Tamaños de botón disponibles
enum AppButtonSize { small, medium, large }

/// Widget de botón personalizado y reutilizable
///
/// Ejemplo de uso:
/// ```dart
/// AppButton(
///   text: 'Create Event',
///   onPressed: () => print('Button pressed'),
///   type: AppButtonType.primary,
/// )
/// ```
class AppButton extends StatelessWidget {
  /// Texto del botón
  final String text;

  /// Callback cuando se presiona el botón
  final VoidCallback? onPressed;

  /// Tipo de botón (primary, secondary, outline, etc.)
  final AppButtonType type;

  /// Tamaño del botón
  final AppButtonSize size;

  /// Ícono opcional a mostrar antes del texto
  final IconData? icon;

  /// Si el botón debe ocupar todo el ancho disponible
  final bool fullWidth;

  /// Si el botón está en estado de carga
  final bool isLoading;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.large,
    this.icon,
    this.fullWidth = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();
    final buttonChild = _buildButtonChild();

    Widget button;

    switch (type) {
      case AppButtonType.primary:
      case AppButtonType.secondary:
      case AppButtonType.destructive:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
      case AppButtonType.outline:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
      case AppButtonType.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
    }

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  Widget _buildButtonChild() {
    if (isLoading) {
      return SizedBox(
        height: _getIconSize(),
        width: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_getLoadingColor()),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getIconSize()),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }

    return Text(text);
  }

  ButtonStyle _getButtonStyle() {
    final padding = _getPadding();
    final textStyle = _getTextStyle();

    switch (type) {
      case AppButtonType.primary:
        return ElevatedButton.styleFrom(
          // Los colores ahora se toman del tema en ElevatedButton
          elevation: 0,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: textStyle,
        );

      case AppButtonType.secondary:
        return ElevatedButton.styleFrom(
          // Los colores ahora se toman del tema en ElevatedButton
          elevation: 0,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: textStyle,
        );

      case AppButtonType.destructive:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: textStyle,
        );

      case AppButtonType.outline:
        return OutlinedButton.styleFrom(
          // Los colores ahora se toman del tema en OutlinedButton
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: textStyle,
        );

      case AppButtonType.text:
        return TextButton.styleFrom(
          // Los colores ahora se toman del tema en TextButton
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: textStyle,
        );
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 14);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case AppButtonSize.small:
        return AppTextStyles.labelMedium;
      case AppButtonSize.medium:
        return AppTextStyles.labelLarge;
      case AppButtonSize.large:
        return AppTextStyles.buttonText;
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 18;
      case AppButtonSize.large:
        return 20;
    }
  }

  Color _getLoadingColor() {
    switch (type) {
      case AppButtonType.primary:
      case AppButtonType.destructive:
        return Colors.white;
      case AppButtonType.secondary:
      case AppButtonType.outline:
      case AppButtonType.text:
        return AppColors.primary;
    }
  }
}

/// Botón de ícono circular
///
/// Ejemplo de uso:
/// ```dart
/// AppIconButton(
///   icon: Icons.add,
///   onPressed: () => print('Icon button pressed'),
/// )
/// ```
class AppIconButton extends StatelessWidget {
  /// Ícono a mostrar
  final IconData icon;

  /// Callback cuando se presiona el botón
  final VoidCallback? onPressed;

  /// Color de fondo del botón
  final Color? backgroundColor;

  /// Color del ícono
  final Color? iconColor;

  /// Tamaño del botón
  final double size;

  /// Tamaño del ícono
  final double? iconSize;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 48,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: size,
      height: size,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        iconSize: iconSize ?? size * 0.5,
        color: iconColor ?? theme.colorScheme.onSurface,
        style: IconButton.styleFrom(
          backgroundColor:
              backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
          shape: const CircleBorder(),
        ),
      ),
    );
  }
}
