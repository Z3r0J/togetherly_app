import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Widget de campo de texto personalizado
///
/// Ejemplo de uso:
/// ```dart
/// AppTextField(
///   label: 'Email',
///   hintText: 'Enter your email address',
///   controller: emailController,
/// )
/// ```
class AppTextField extends StatelessWidget {
  /// Etiqueta del campo
  final String? label;

  /// Texto de ayuda/placeholder
  final String? hintText;

  /// Controlador del campo de texto
  final TextEditingController? controller;

  /// Tipo de teclado
  final TextInputType? keyboardType;

  /// Si el campo es para contraseña
  final bool obscureText;

  /// Ícono a mostrar al inicio
  final IconData? prefixIcon;

  /// Widget personalizado al inicio
  final Widget? prefix;

  /// Ícono a mostrar al final
  final IconData? suffixIcon;

  /// Widget personalizado al final
  final Widget? suffix;

  /// Callback para el ícono de sufijo
  final VoidCallback? onSuffixIconPressed;

  /// Número máximo de líneas
  final int? maxLines;

  /// Texto de error
  final String? errorText;

  /// Si el campo está deshabilitado
  final bool enabled;

  /// Callback cuando cambia el texto
  final ValueChanged<String>? onChanged;

  /// Callback cuando se envía el formulario
  final ValueChanged<String>? onSubmitted;

  /// Si debe autoenfocarse
  final bool autofocus;

  const AppTextField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.prefix,
    this.suffixIcon,
    this.suffix,
    this.onSuffixIconPressed,
    this.maxLines = 1,
    this.errorText,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTextStyles.titleSmall),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: obscureText ? 1 : maxLines,
          enabled: enabled,
          autofocus: autofocus,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.textSecondary)
                : null,
            prefix: prefix,
            suffixIcon: suffixIcon != null || suffix != null
                ? _buildSuffixIcon()
                : null,
            filled: true,
            fillColor: enabled ? AppColors.surfaceVariant : AppColors.divider,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (suffix != null) {
      return suffix;
    }

    if (suffixIcon != null) {
      if (onSuffixIconPressed != null) {
        return IconButton(
          icon: Icon(suffixIcon),
          onPressed: onSuffixIconPressed,
          color: AppColors.textSecondary,
        );
      }
      return Icon(suffixIcon, color: AppColors.textSecondary);
    }

    return null;
  }
}

/// Campo de texto específico para búsqueda
///
/// Ejemplo de uso:
/// ```dart
/// SearchTextField(
///   hintText: 'Search events...',
///   onChanged: (value) => print('Search: $value'),
/// )
/// ```
class SearchTextField extends StatelessWidget {
  /// Texto de ayuda/placeholder
  final String hintText;

  /// Controlador del campo de texto
  final TextEditingController? controller;

  /// Callback cuando cambia el texto
  final ValueChanged<String>? onChanged;

  /// Callback cuando se envía el formulario
  final ValueChanged<String>? onSubmitted;

  const SearchTextField({
    super.key,
    this.hintText = 'Search...',
    this.controller,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
