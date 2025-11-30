import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'rsvp_widgets.dart';

/// Card de evento reutilizable
///
/// Ejemplo de uso:
/// ```dart
/// EventCard(
///   title: 'Annual BBQ Party',
///   date: 'Saturday, August 17',
///   time: '2:00 PM - 7:00 PM',
///   location: "Alex's Backyard",
///   rsvpStatus: RsvpStatus.going,
///   onTap: () => print('Event tapped'),
/// )
/// ```
class EventCard extends StatelessWidget {
  /// Título del evento
  final String title;

  /// Fecha del evento
  final String date;

  /// Hora del evento
  final String time;

  /// Ubicación del evento
  final String location;

  /// Estado de RSVP del usuario
  final RsvpStatus? rsvpStatus;

  /// Contador de asistentes
  final int? attendeeCount;

  /// Etiqueta del círculo/categoría
  final String? circleLabel;

  /// Color del círculo/categoría
  final Color? circleColor;

  /// Si hay conflicto de horario
  final bool hasConflict;

  /// Evento con el que hay conflicto
  final String? conflictWith;

  /// Callback cuando se toca el card
  final VoidCallback? onTap;

  /// Callback para ver detalles
  final VoidCallback? onViewDetails;

  /// Callback to resolve conflict (open resolver)
  final VoidCallback? onResolve;

  const EventCard({
    super.key,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    this.rsvpStatus,
    this.attendeeCount,
    this.circleLabel,
    this.circleColor,
    this.hasConflict = false,
    this.conflictWith,
    this.onTap,
    this.onViewDetails,
    this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Text(title, style: AppTextStyles.eventTitle),
              const SizedBox(height: 12),

              // Fecha
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    date,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Hora
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    time,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Ubicación
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      location,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),

              // RSVP y asistentes
              if (rsvpStatus != null || attendeeCount != null) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (rsvpStatus != null) ...[
                      RsvpBadge(status: rsvpStatus!),
                      const SizedBox(width: 12),
                    ],
                    if (attendeeCount != null) ...[
                      Icon(
                        Icons.people_outline,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$attendeeCount',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (onViewDetails != null)
                      TextButton(
                        onPressed: onViewDetails,
                        child: Row(
                          children: [
                            Text('View Details'),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_forward, size: 16),
                          ],
                        ),
                      ),
                  ],
                ),
              ],

              // Alerta de conflicto
              if (hasConflict) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          conflictWith != null
                              ? 'Conflicts with "$conflictWith"'
                              : 'Schedule conflict detected',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: onResolve ?? () {},
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.warning,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                        ),
                        child: const Text('Resolve'),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Card compacto de evento para calendario
///
/// Ejemplo de uso:
/// ```dart
/// CompactEventCard(
///   title: 'Team Standup',
///   time: '9:00 AM - 9:15 AM',
///   location: 'Remote (Google Meet)',
///   colorTag: AppColors.warning,
/// )
/// ```
class CompactEventCard extends StatelessWidget {
  /// Título del evento
  final String title;

  /// Hora del evento
  final String time;

  /// Ubicación del evento
  final String? location;

  /// Notas del evento
  final String? notes;

  /// Color identificador
  final Color colorTag;

  /// Estado de RSVP
  final RsvpStatus? rsvpStatus;

  /// Si hay conflicto
  final bool hasConflict;

  /// Nombre del evento con el que hay conflicto (opcional)
  final String? conflictWith;

  /// Callback cuando se toca el card
  final VoidCallback? onTap;

  const CompactEventCard({
    super.key,
    required this.title,
    required this.time,
    this.location,
    this.notes,
    this.colorTag = AppColors.primary,
    this.rsvpStatus,
    this.hasConflict = false,
    this.conflictWith,
    this.onTap,
    this.onResolve,
  });

  /// Callback to resolve conflict (open resolver)
  final VoidCallback? onResolve;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border(
              left: BorderSide(
                color: hasConflict ? AppColors.warning : colorTag,
                width: 4,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título y menú
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colorTag,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(title, style: AppTextStyles.titleMedium),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Hora
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Text(time, style: AppTextStyles.bodySmall),
                  ],
                ),

                // Ubicación
                if (location != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(location!, style: AppTextStyles.bodySmall),
                      ),
                    ],
                  ),
                ],

                // Notas
                if (notes != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.notes_outlined,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          notes!,
                          style: AppTextStyles.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                // Conflicto
                if (hasConflict) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        size: 16,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          conflictWith != null
                              ? 'Conflicts with "${conflictWith}"'
                              : 'Schedule conflict detected',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: onResolve ?? () {},
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 24),
                        ),
                        child: const Text('Resolve'),
                      ),
                    ],
                  ),
                ],

                // RSVP
                if (rsvpStatus != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        rsvpStatus == RsvpStatus.notGoing
                            ? Icons.cancel_outlined
                            : Icons.check_circle_outline,
                        size: 14,
                        color: rsvpStatus == RsvpStatus.going
                            ? AppColors.rsvpGoing
                            : rsvpStatus == RsvpStatus.notGoing
                            ? AppColors.rsvpNotGoing
                            : AppColors.textTertiary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'You responded ${rsvpConfigs[rsvpStatus]!.label}${hasConflict ? ' (Conflict)' : ''}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: rsvpStatus == RsvpStatus.going
                              ? AppColors.rsvpGoing
                              : rsvpStatus == RsvpStatus.notGoing
                              ? AppColors.rsvpNotGoing
                              : AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(80, 24),
                        ),
                        child: const Text('Change Response'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
