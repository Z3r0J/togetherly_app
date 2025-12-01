import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Widget de avatar de usuario
///
/// Ejemplo de uso:
/// ```dart
/// UserAvatar(
///   imageUrl: 'https://example.com/avatar.jpg',
///   name: 'John Doe',
///   size: 48,
/// )
/// ```
class UserAvatar extends StatelessWidget {
  /// URL de la imagen del avatar
  final String? imageUrl;

  /// Nombre del usuario (usado para iniciales si no hay imagen)
  final String name;

  /// Tamaño del avatar
  final double size;

  /// Color de fondo para el avatar con iniciales
  final Color? backgroundColor;

  /// Si debe mostrar un borde
  final bool showBorder;

  /// Color del borde
  final Color borderColor;

  const UserAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 40,
    this.backgroundColor,
    this.showBorder = false,
    this.borderColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder ? Border.all(color: borderColor, width: 2) : null,
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildInitialsAvatar();
                },
              )
            : _buildInitialsAvatar(),
      ),
    );
  }

  Widget _buildInitialsAvatar() {
    return Container(
      width: size,
      height: size,
      color: backgroundColor ?? _getColorFromName(name),
      child: Center(
        child: Text(
          _getInitials(name),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Color _getColorFromName(String name) {
    final colors = [
      AppColors.circlePurple,
      AppColors.circleBlue,
      AppColors.circleGreen,
      AppColors.circleOrange,
      AppColors.circlePink,
      AppColors.circleTeal,
    ];

    final hash = name.hashCode;
    return colors[hash.abs() % colors.length];
  }
}

/// Lista horizontal de avatares apilados
///
/// Ejemplo de uso:
/// ```dart
/// AvatarStack(
///   avatars: [
///     AvatarData(name: 'John', imageUrl: '...'),
///     AvatarData(name: 'Jane', imageUrl: '...'),
///   ],
///   maxVisible: 3,
/// )
/// ```
class AvatarStack extends StatelessWidget {
  /// Lista de datos de avatares
  final List<AvatarData> avatars;

  /// Tamaño de cada avatar
  final double size;

  /// Número máximo de avatares visibles
  final int maxVisible;

  /// Si debe mostrar el contador de avatares adicionales
  final bool showCount;

  const AvatarStack({
    super.key,
    required this.avatars,
    this.size = 32,
    this.maxVisible = 5,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context) {
    final visibleAvatars = avatars.take(maxVisible).toList();
    final remainingCount = avatars.length - maxVisible;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            for (int i = 0; i < visibleAvatars.length; i++)
              Padding(
                padding: EdgeInsets.only(left: i * (size * 0.7)),
                child: UserAvatar(
                  imageUrl: visibleAvatars[i].imageUrl,
                  name: visibleAvatars[i].name,
                  size: size,
                  showBorder: true,
                ),
              ),
          ],
        ),
        if (showCount && remainingCount > 0) ...[
          SizedBox(width: size * 0.2),
          Text(
            '+$remainingCount',
            style: AppTextStyles.labelMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

/// Datos de avatar para usar en listas
class AvatarData {
  final String name;
  final String? imageUrl;

  const AvatarData({required this.name, this.imageUrl});
}

/// Badge con ícono de círculo/grupo
///
/// Ejemplo de uso:
/// ```dart
/// CircleBadge(
///   color: AppColors.circleGreen,
///   icon: Icons.groups,
/// )
/// ```
class CircleBadge extends StatelessWidget {
  /// Color del badge
  final Color color;

  /// Ícono a mostrar
  final IconData icon;

  /// Tamaño del badge
  final double size;

  const CircleBadge({
    super.key,
    required this.color,
    this.icon = Icons.groups,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

/// Selector de color para círculos
///
/// Ejemplo de uso:
/// ```dart
/// ColorSelector(
///   selectedColor: AppColors.circlePurple,
///   onColorSelected: (color) => print('Selected: $color'),
/// )
/// ```
class ColorSelector extends StatelessWidget {
  /// Color actualmente seleccionado
  final Color selectedColor;

  /// Callback cuando se selecciona un color
  final ValueChanged<Color>? onColorSelected;

  /// Colores disponibles
  final List<Color> colors;

  const ColorSelector({
    super.key,
    required this.selectedColor,
    this.onColorSelected,
    this.colors = circleColors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: colors.map((color) {
        final isSelected = color == selectedColor;
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () => onColorSelected?.call(color),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 3,
                      )
                    : null,
              ),
              child: isSelected
                  ? Icon(Icons.check, color: Colors.white, size: 24)
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}
