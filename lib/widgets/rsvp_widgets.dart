import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Estados posibles de RSVP
enum RsvpStatus { going, maybe, notGoing, none }

/// Configuración de color para cada estado de RSVP
class RsvpConfig {
  final Color color;
  final Color backgroundColor;
  final String label;
  final IconData icon;

  const RsvpConfig({
    required this.color,
    required this.backgroundColor,
    required this.label,
    required this.icon,
  });
}

/// Mapa de configuraciones para cada estado de RSVP
const Map<RsvpStatus, RsvpConfig> rsvpConfigs = {
  RsvpStatus.going: RsvpConfig(
    color: AppColors.rsvpGoing,
    backgroundColor: Color(0xFFE8F5E9),
    label: 'Going',
    icon: Icons.check_circle,
  ),
  RsvpStatus.maybe: RsvpConfig(
    color: AppColors.rsvpMaybe,
    backgroundColor: Color(0xFFFFF3E0),
    label: 'Maybe',
    icon: Icons.help_outline,
  ),
  RsvpStatus.notGoing: RsvpConfig(
    color: AppColors.rsvpNotGoing,
    backgroundColor: Color(0xFFFFEBEE),
    label: 'Not Going',
    icon: Icons.cancel_outlined,
  ),
  RsvpStatus.none: RsvpConfig(
    color: AppColors.textSecondary,
    backgroundColor: AppColors.surfaceVariant,
    label: 'No Response',
    icon: Icons.help_outline,
  ),
};

/// Badge de estado RSVP
///
/// Ejemplo de uso:
/// ```dart
/// RsvpBadge(status: RsvpStatus.going)
/// ```
class RsvpBadge extends StatelessWidget {
  /// Estado de RSVP
  final RsvpStatus status;

  /// Si debe mostrar el ícono
  final bool showIcon;

  /// Tamaño del badge
  final double? fontSize;

  const RsvpBadge({
    super.key,
    required this.status,
    this.showIcon = true,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final config = rsvpConfigs[status]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(config.icon, size: fontSize ?? 14, color: config.color),
            const SizedBox(width: 4),
          ],
          Text(
            config.label,
            style:
                (fontSize != null
                        ? AppTextStyles.labelSmall.copyWith(fontSize: fontSize)
                        : AppTextStyles.labelSmall)
                    .copyWith(color: config.color),
          ),
        ],
      ),
    );
  }
}

/// Selector de RSVP con botones
///
/// Ejemplo de uso:
/// ```dart
/// RsvpSelector(
///   currentStatus: RsvpStatus.maybe,
///   onStatusChanged: (status) => print('New status: $status'),
/// )
/// ```
class RsvpSelector extends StatelessWidget {
  /// Estado actual de RSVP
  final RsvpStatus currentStatus;

  /// Callback cuando cambia el estado
  final ValueChanged<RsvpStatus>? onStatusChanged;

  /// Si debe mostrar todos los estados o solo Going/Maybe
  final bool showNotGoing;

  const RsvpSelector({
    super.key,
    required this.currentStatus,
    this.onStatusChanged,
    this.showNotGoing = true,
  });

  @override
  Widget build(BuildContext context) {
    final statuses = showNotGoing
        ? [RsvpStatus.going, RsvpStatus.maybe, RsvpStatus.notGoing]
        : [RsvpStatus.going, RsvpStatus.maybe];

    return Row(
      children: statuses.map((status) {
        final config = rsvpConfigs[status]!;
        final isSelected = currentStatus == status;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _RsvpButton(
              config: config,
              isSelected: isSelected,
              onTap: () => onStatusChanged?.call(status),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _RsvpButton extends StatelessWidget {
  final RsvpConfig config;
  final bool isSelected;
  final VoidCallback? onTap;

  const _RsvpButton({
    required this.config,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? config.color : config.backgroundColor,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? config.color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              config.icon,
              size: 18,
              color: isSelected ? Colors.white : config.color,
            ),
            const SizedBox(width: 6),
            Text(
              config.label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? Colors.white : config.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Resumen de RSVPs con contadores
///
/// Ejemplo de uso:
/// ```dart
/// RsvpSummary(
///   goingCount: 4,
///   maybeCount: 1,
///   notGoingCount: 0,
/// )
/// ```
class RsvpSummary extends StatelessWidget {
  /// Número de personas que van
  final int goingCount;

  /// Número de personas que tal vez vayan
  final int maybeCount;

  /// Número de personas que no van
  final int notGoingCount;

  const RsvpSummary({
    super.key,
    required this.goingCount,
    required this.maybeCount,
    required this.notGoingCount,
  });

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];

    if (goingCount > 0) {
      items.add(_buildItem('$goingCount Going', AppColors.rsvpGoing));
    }

    if (maybeCount > 0) {
      if (items.isNotEmpty) items.add(_buildDot(context));
      items.add(_buildItem('$maybeCount Maybe', AppColors.rsvpMaybe));
    }

    if (notGoingCount > 0) {
      if (items.isNotEmpty) items.add(_buildDot(context));
      items.add(_buildItem('$notGoingCount Not Going', AppColors.rsvpNotGoing));
    }

    if (items.isEmpty) {
      items.add(
        Text(
          'No responses yet',
          style: AppTextStyles.bodySmall.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withOpacity(0.6),
          ),
        ),
      );
    }

    return Row(children: items);
  }

  Widget _buildItem(String text, Color color) {
    return Text(text, style: AppTextStyles.bodySmall.copyWith(color: color));
  }

  Widget _buildDot(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Container(
        width: 3,
        height: 3,
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withOpacity(0.6),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
