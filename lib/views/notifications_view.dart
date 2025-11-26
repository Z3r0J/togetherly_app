import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/widgets.dart';
import '../viewmodels/notification_view_model.dart';
import '../models/notification_models.dart';

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

            // Acciones
            if (primaryAction != null || secondaryAction != null) ...[
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

  void _handleNotificationAction(
    BuildContext context,
    AppNotification notification,
    String action,
  ) {
    // Handle the action with the backend
    context.read<NotificationViewModel>().handleAction(notification.id, action);

    // Show feedback
    String message = '';
    Color color = AppColors.info;

    switch (action) {
      case 'view_event':
        message = 'Navegando a detalles del evento...';
        color = AppColors.info;
        // TODO: Navigate to event detail using notification.metadata.eventId
        break;
      case 'set_rsvp':
        message = 'Abriendo selector de RSVP...';
        color = AppColors.info;
        break;
      case 'resolve_conflict':
        message = 'Abriendo resolución de conflicto...';
        color = AppColors.warning;
        break;
      case 'accept_invitation':
        message = '¡Invitación de círculo aceptada!';
        color = AppColors.success;
        break;
      case 'decline_invitation':
        message = 'Invitación de círculo rechazada.';
        color = AppColors.error;
        break;
      default:
        message = 'Acción ejecutada: $action';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
