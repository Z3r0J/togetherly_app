import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Card de círculo/grupo reutilizable
///
/// Ejemplo de uso:
/// ```dart
/// CircleCard(
///   name: 'Family Get-Together',
///   memberCount: 5,
///   eventCount: 2,
///   color: AppColors.circlePurple,
///   lastActivity: '2h ago',
///   onTap: () => print('Circle tapped'),
/// )
/// ```
class CircleCard extends StatelessWidget {
  /// Nombre del círculo
  final String name;

  /// Número de miembros
  final int memberCount;

  /// Número de eventos próximos
  final int eventCount;

  /// Color identificador del círculo
  final Color color;

  /// Última actividad
  final String lastActivity;

  /// Ícono del círculo
  final IconData icon;

  /// Callback cuando se toca el card
  final VoidCallback? onTap;

  const CircleCard({
    super.key,
    required this.name,
    required this.memberCount,
    required this.eventCount,
    required this.color,
    required this.lastActivity,
    this.icon = Icons.groups,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícono del círculo
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),

              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTextStyles.circleTitle),
                    const SizedBox(height: 4),
                    Text(
                      '$memberCount members, $eventCount ${eventCount == 1 ? 'upcoming event' : 'upcoming events'}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Active $lastActivity',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),

              // Flecha
              Icon(Icons.chevron_right, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card compacto de círculo para home
///
/// Ejemplo de uso:
/// ```dart
/// CompactCircleCard(
///   name: 'Family',
///   memberCount: 8,
///   nextEventTitle: "Mom's Birthday",
///   nextEventDate: 'Oct 20, 7:00 PM',
///   color: AppColors.circleGreen,
/// )
/// ```
class CompactCircleCard extends StatelessWidget {
  /// Nombre del círculo
  final String name;

  /// Número de miembros
  final int memberCount;

  /// Título del próximo evento
  final String? nextEventTitle;

  /// Fecha del próximo evento
  final String? nextEventDate;

  /// Color identificador del círculo
  final Color color;

  /// Callback cuando se toca el card
  final VoidCallback? onTap;

  /// Callback para ver el círculo
  final VoidCallback? onViewCircle;

  const CompactCircleCard({
    super.key,
    required this.name,
    required this.memberCount,
    this.nextEventTitle,
    this.nextEventDate,
    required this.color,
    this.onTap,
    this.onViewCircle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border(left: BorderSide(color: color, width: 4)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      name.toUpperCase(),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: color,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Miembros
                Text(
                  '$memberCount members',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                // Próximo evento
                if (nextEventTitle != null && nextEventDate != null) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Text(
                    'NEXT EVENT',
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nextEventTitle!,
                    style: AppTextStyles.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nextEventDate!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Botón de ver círculo
                if (onViewCircle != null)
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: onViewCircle,
                      style: TextButton.styleFrom(
                        backgroundColor: color.withOpacity(0.1),
                        foregroundColor: color,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('View Circle'),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
