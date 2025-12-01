import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Tipos de notificación
enum NotificationType {
  reminder,
  conflict,
  rsvpUpdate,
  invitation,
  circleInvitation,
}

/// Configuración de estilo para cada tipo de notificación
class NotificationConfig {
  final Color color;
  final Color backgroundColor;
  final IconData icon;

  const NotificationConfig({
    required this.color,
    required this.backgroundColor,
    required this.icon,
  });
}

final Map<NotificationType, NotificationConfig> notificationConfigs = {
  NotificationType.reminder: NotificationConfig(
    color: AppColors.info,
    backgroundColor: Color(0xFFE3F2FD),
    icon: Icons.calendar_today,
  ),
  NotificationType.conflict: NotificationConfig(
    color: AppColors.warning,
    backgroundColor: Color(0xFFFFF3E0),
    icon: Icons.warning_amber_rounded,
  ),
  NotificationType.rsvpUpdate: NotificationConfig(
    color: AppColors.success,
    backgroundColor: Color(0xFFE8F5E9),
    icon: Icons.person_outline,
  ),
  NotificationType.invitation: NotificationConfig(
    color: Color(0xFF6200EA),
    backgroundColor: Color(0xFFEDE7F6),
    icon: Icons.event,
  ),
  NotificationType.circleInvitation: NotificationConfig(
    color: AppColors.circleTeal,
    backgroundColor: Color(0xFFE0F2F1),
    icon: Icons.group_add,
  ),
};

/// Card de notificación
///
/// Ejemplo de uso:
/// ```dart
/// NotificationCard(
///   type: NotificationType.reminder,
///   message: 'Reminder: Family Dinner is at 7:00 PM at Mom\'s House.',
///   timeAgo: '5m ago',
///   onPrimaryAction: () => print('View Event'),
///   primaryActionLabel: 'View Event',
/// )
/// ```
class NotificationCard extends StatelessWidget {
  /// Tipo de notificación
  final NotificationType type;

  /// Mensaje de la notificación
  final String message;

  /// Tiempo transcurrido
  final String timeAgo;

  /// Callback para la acción principal
  final VoidCallback? onPrimaryAction;

  /// Etiqueta de la acción principal
  final String? primaryActionLabel;

  /// Callback para la acción secundaria
  final VoidCallback? onSecondaryAction;

  /// Etiqueta de la acción secundaria
  final String? secondaryActionLabel;

  /// Si la notificación no ha sido leída
  final bool isUnread;

  const NotificationCard({
    super.key,
    required this.type,
    required this.message,
    required this.timeAgo,
    this.onPrimaryAction,
    this.primaryActionLabel,
    this.onSecondaryAction,
    this.secondaryActionLabel,
    this.isUnread = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = notificationConfigs[type]!;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(left: BorderSide(color: config.color, width: 4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícono
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: config.backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(config.icon, color: config.color, size: 20),
            ),
            const SizedBox(width: 12),

            // Contenido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(message, style: AppTextStyles.bodyMedium),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeAgo,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),

                  // Acciones
                  if (onPrimaryAction != null || onSecondaryAction != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (onPrimaryAction != null)
                          ElevatedButton(
                            onPressed: onPrimaryAction,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: config.color,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              minimumSize: Size.zero,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              primaryActionLabel ?? 'Action',
                              style: AppTextStyles.labelMedium,
                            ),
                          ),
                        if (onSecondaryAction != null) ...[
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: onSecondaryAction,
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              minimumSize: Size.zero,
                            ),
                            child: Text(
                              secondaryActionLabel ?? 'Dismiss',
                              style: AppTextStyles.labelMedium,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Indicador de no leído
            if (isUnread)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Banner de conflicto de horario
///
/// Ejemplo de uso:
/// ```dart
/// ConflictBanner(
///   message: 'This event overlaps with "Design Sync" (2:30 PM - 3:30 PM)',
///   onResolve: () => print('Resolve conflict'),
/// )
/// ```
class ConflictBanner extends StatelessWidget {
  /// Mensaje del conflicto
  final String message;

  /// Callback para resolver el conflicto
  final VoidCallback? onResolve;

  const ConflictBanner({super.key, required this.message, this.onResolve});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conflict Warning',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Alerta de conflicto detectado
///
/// Ejemplo de uso:
/// ```dart
/// ConflictAlert(
///   message: 'You have a conflict with Dentist Appointment',
///   onResolve: () => print('Resolve'),
/// )
/// ```
class ConflictAlert extends StatelessWidget {
  /// Mensaje del conflicto
  final String message;

  /// Callback para resolver
  final VoidCallback? onResolve;

  /// Callback para cambiar RSVP
  final VoidCallback? onChangeRsvp;

  const ConflictAlert({
    super.key,
    required this.message,
    this.onResolve,
    this.onChangeRsvp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              Text(
                'Conflict Detected',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (onResolve != null)
                Expanded(
                  child: ElevatedButton(
                    onPressed: onResolve,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Resolve Conflict'),
                  ),
                ),
              if (onChangeRsvp != null) ...[
                if (onResolve != null) const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onChangeRsvp,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Change RSVP'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Banner informativo general
///
/// Ejemplo de uso:
/// ```dart
/// InfoBanner(
///   message: 'Time Confirmed: 11:00 AM',
///   type: InfoBannerType.success,
///   subtitle: 'Locked by Alex',
/// )
/// ```
enum InfoBannerType { success, info, warning, error }

class InfoBanner extends StatelessWidget {
  /// Mensaje principal
  final String message;

  /// Subtítulo opcional
  final String? subtitle;

  /// Tipo de banner
  final InfoBannerType type;

  const InfoBanner({
    super.key,
    required this.message,
    this.subtitle,
    this.type = InfoBannerType.info,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(config.icon, color: config.color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: AppTextStyles.titleSmall.copyWith(color: config.color),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  NotificationConfig _getConfig() {
    switch (type) {
      case InfoBannerType.success:
        return const NotificationConfig(
          color: AppColors.success,
          backgroundColor: Color(0xFFE8F5E9),
          icon: Icons.check_circle,
        );
      case InfoBannerType.info:
        return const NotificationConfig(
          color: AppColors.info,
          backgroundColor: Color(0xFFE3F2FD),
          icon: Icons.info,
        );
      case InfoBannerType.warning:
        return const NotificationConfig(
          color: AppColors.warning,
          backgroundColor: Color(0xFFFFF3E0),
          icon: Icons.warning_amber_rounded,
        );
      case InfoBannerType.error:
        return const NotificationConfig(
          color: AppColors.error,
          backgroundColor: Color(0xFFFFEBEE),
          icon: Icons.error,
        );
    }
  }
}
