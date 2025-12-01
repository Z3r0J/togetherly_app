import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/widgets.dart';
import '../viewmodels/notification_view_model.dart';
import '../models/notification_models.dart';
import '../models/unified_calendar_models.dart';
import '../services/event_service.dart';
import 'event_detail_tabs_view.dart';
import 'resolve_conflict_view.dart';
import 'join_circle_view.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  String _selectedFilter = 'Todos';
  final List<String> _filters = ['Todos', 'Eventos', 'Círculos', 'RSVP'];

  @override
  void initState() {
    super.initState();
    // Load notifications on first render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationViewModel>().loadNotifications();
    });
  }

  void _filterNotifications(String filter) {
    setState(() {
      _selectedFilter = filter;
    });

    // Map UI filter to backend category
    String? category;
    switch (filter) {
      case 'Eventos':
        category = 'events';
        break;
      case 'Círculos':
        category = 'circles';
        break;
      case 'RSVP':
        category = 'rsvps';
        break;
      default:
        category = null; // 'Todos' means no category filter
    }

    context.read<NotificationViewModel>().loadNotifications(category: category);
  }

  void _handleMarkAllRead(BuildContext context) {
    context.read<NotificationViewModel>().markAllAsRead();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Todas las notificaciones marcadas como leídas'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _dismissNotification(BuildContext context, String notificationId) {
    context.read<NotificationViewModel>().dismissNotification(notificationId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notificación descartada'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Helper to map backend notification type to UI NotificationType
  NotificationType _mapNotificationType(String backendType) {
    switch (backendType) {
      case 'reminder':
        return NotificationType.reminder;
      case 'conflict':
        return NotificationType.conflict;
      case 'rsvp_update':
        return NotificationType.rsvpUpdate;
      case 'invitation':
        return NotificationType.invitation;
      case 'circle_invitation':
        return NotificationType.circleInvitation;
      default:
        return NotificationType.reminder; // fallback
    }
  }

  // Helper to format time ago
  String _formatTimeAgo(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 60) {
      return 'hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'hace ${difference.inHours}h';
    } else {
      return 'hace ${difference.inDays}d';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationViewModel>(
      builder: (context, viewModel, child) {
        final notifications = viewModel.notifications;
        final isLoading = viewModel.isLoading;
        final error = viewModel.error;

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            title: Text('Notificaciones', style: AppTextStyles.headlineMedium),
            actions: [
              TextButton(
                onPressed: () => _handleMarkAllRead(context),
                child: Text(
                  'Marcar todo como leído',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Filtros
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  children: _filters.map((filter) {
                    final isSelected = filter == _selectedFilter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => _filterNotifications(filter),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              filter,
                              style: AppTextStyles.labelMedium.copyWith(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                            if (isSelected)
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                height: 3,
                                width: 30,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(1.5),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Divider(height: 1),

              // Loading state
              if (isLoading && notifications.isEmpty)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                )
              // Error state
              else if (error != null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          error.message,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          text: 'Reintentar',
                          type: AppButtonType.primary,
                          onPressed: () {
                            viewModel.loadNotifications();
                          },
                        ),
                      ],
                    ),
                  ),
                )
              // Empty state
              else if (notifications.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 64,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Sin notificaciones',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              // Notifications list
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildNotificationCard(
                          context: context,
                          notification: notification,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationCard({
    required BuildContext context,
    required AppNotification notification,
  }) {
    final type = _mapNotificationType(notification.type);
    final config = notificationConfigs[type]!;
    final timeAgo = _formatTimeAgo(notification.createdAt);

    // Extract actions from notification
    final actionButtons = notification.actionButtons;
    final primaryAction = actionButtons.isNotEmpty ? actionButtons[0] : null;
    final secondaryAction = actionButtons.length > 1 ? actionButtons[1] : null;

    return Container(
      decoration: BoxDecoration(
        color: notification.isRead ? AppColors.surface : AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: config.color, width: 4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con ícono, mensaje y tiempo
            Row(
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

                // Mensaje y tiempo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: notification.isRead
                              ? FontWeight.normal
                              : FontWeight.w600,
                        ),
                      ),
                      if (notification.body.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          notification.body,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        timeAgo,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Acciones (solo si no está leída)
            if (!notification.isRead &&
                (primaryAction != null || secondaryAction != null)) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (primaryAction != null) ...[
                    Expanded(
                      child: AppButton(
                        text: primaryAction.label,
                        type: _getButtonType(type),
                        fullWidth: true,
                        onPressed: () {
                          _handleNotificationAction(
                            context,
                            notification,
                            primaryAction.action,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (secondaryAction != null)
                    Expanded(
                      child: AppButton(
                        text: secondaryAction.label,
                        type: AppButtonType.outline,
                        fullWidth: true,
                        onPressed: () {
                          if (secondaryAction.action == 'dismiss') {
                            _dismissNotification(context, notification.id);
                          } else {
                            _handleNotificationAction(
                              context,
                              notification,
                              secondaryAction.action,
                            );
                          }
                        },
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  AppButtonType _getButtonType(NotificationType type) {
    switch (type) {
      case NotificationType.reminder:
      case NotificationType.invitation:
        return AppButtonType.primary;
      case NotificationType.conflict:
        return AppButtonType.secondary;
      case NotificationType.rsvpUpdate:
        return AppButtonType.primary;
      case NotificationType.circleInvitation:
        return AppButtonType.primary;
    }
  }

  Future<void> _handleNotificationAction(
    BuildContext context,
    AppNotification notification,
    String action,
  ) async {
    final viewModel = context.read<NotificationViewModel>();

    switch (action) {
      case 'view_event':
        await _handleViewEvent(context, notification);
        break;
      case 'set_rsvp':
        await _handleSetRsvp(context, notification);
        break;
      case 'resolve_conflict':
        await _handleResolveConflict(context, notification);
        break;
      case 'accept_invitation':
        await _handleAcceptInvitation(context, notification);
        break;
      case 'decline_invitation':
        await _handleDeclineInvitation(context, notification);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Acción no implementada: $action'),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
          ),
        );
    }

    // Mark as handled
    await viewModel.handleAction(notification.id, action);
  }

  Future<void> _handleViewEvent(
    BuildContext context,
    AppNotification notification,
  ) async {
    final eventId = notification.metadata.eventId;
    if (eventId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se encontró el ID del evento'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      // Load event details
      final eventService = EventService();
      final event = await eventService.getCircleEventDetail(eventId);

      if (mounted) {
        // Navigate to event details
        final unifiedEvent = CircleUnifiedEvent(
          id: event.id,
          title: event.title,
          startTime: event.startsAt ?? DateTime.now(),
          endTime: event.endsAt ?? DateTime.now(),
          allDay: event.allDay,
          conflictsWith: [],
          circleId: event.circleId,
          circleName: '',
          circleColor: event.color,
          location: event.location,
          status: event.status,
          rsvpStatus: null,
          attendeeCount: event.rsvps.length,
          canChangeRsvp: true,
          isCreator: false,
        );

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailTabsView(event: unifiedEvent),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar el evento: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleSetRsvp(
    BuildContext context,
    AppNotification notification,
  ) async {
    final eventId = notification.metadata.eventId;
    if (eventId == null) return;

    // Show RSVP options dialog
    final rsvpStatus = await showDialog<RsvpStatus>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tu respuesta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle, color: AppColors.success),
              title: const Text('Asistiré'),
              onTap: () => Navigator.pop(context, RsvpStatus.going),
            ),
            ListTile(
              leading: const Icon(Icons.help_outline, color: AppColors.warning),
              title: const Text('Tal vez'),
              onTap: () => Navigator.pop(context, RsvpStatus.maybe),
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: AppColors.error),
              title: const Text('No asistiré'),
              onTap: () => Navigator.pop(context, RsvpStatus.notGoing),
            ),
          ],
        ),
      ),
    );

    if (rsvpStatus != null && mounted) {
      try {
        final eventService = EventService();
        await eventService.updateRsvp(eventId, rsvpStatus);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡RSVP actualizado exitosamente!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar RSVP: $e'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleResolveConflict(
    BuildContext context,
    AppNotification notification,
  ) async {
    final eventId = notification.metadata.eventId;
    if (eventId == null) return;

    try {
      // Load the conflicting events
      final eventService = EventService();
      final event = await eventService.getCircleEventDetail(eventId);

      if (mounted) {
        final unifiedEvent = CircleUnifiedEvent(
          id: event.id,
          title: event.title,
          startTime: event.startsAt ?? DateTime.now(),
          endTime: event.endsAt ?? DateTime.now(),
          allDay: event.allDay,
          conflictsWith: [],
          circleId: event.circleId,
          circleName: '',
          circleColor: event.color,
          location: event.location,
          status: event.status,
          rsvpStatus: null,
          attendeeCount: event.rsvps.length,
          canChangeRsvp: true,
          isCreator: false,
        );

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResolveConflictView(
              event: unifiedEvent,
              conflicts: unifiedEvent.conflictsWith,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar conflicto: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleAcceptInvitation(
    BuildContext context,
    AppNotification notification,
  ) async {
    final shareToken = notification.metadata.shareToken;

    if (shareToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se encontró el enlace de invitación'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      // Navigate to JoinCircleView with the shareToken
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => JoinCircleView(shareToken: shareToken),
        ),
      );

      // If successfully joined, refresh notifications
      if (result == true && mounted) {
        context.read<NotificationViewModel>().refresh();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleDeclineInvitation(
    BuildContext context,
    AppNotification notification,
  ) async {
    // For now, just dismiss the notification
    await context.read<NotificationViewModel>().dismissNotification(
      notification.id,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invitación rechazada'),
          backgroundColor: AppColors.info,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
