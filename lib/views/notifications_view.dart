import 'package:flutter/material.dart';
import '../widgets/widgets.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  String _selectedFilter = 'Todos';
  final List<String> _filters = ['Todos', 'Eventos', 'Círculos', 'RSVP'];

  final List<Map<String, dynamic>> _allNotifications = [
    {
      'type': NotificationType.reminder,
      'message':
          'Recordatorio: La cena familiar es a las 7:00 PM en casa de mamá.',
      'timeAgo': 'hace 5m',
      'primaryAction': 'Ver Evento',
      'secondaryAction': 'Descartar',
    },
    {
      'type': NotificationType.conflict,
      'message':
          'Conflicto detectado: "Noche de juegos" choca con "Plazo de proyecto".',
      'timeAgo': 'hace 12m',
      'primaryAction': 'Resolver',
      'secondaryAction': 'Ver',
    },
    {
      'type': NotificationType.rsvpUpdate,
      'message':
          'Alex ha actualizado su RSVP para "Almuerzo de equipo" a Asistirá.',
      'timeAgo': 'hace 2h',
      'primaryAction': null,
      'secondaryAction': null,
    },
    {
      'type': NotificationType.invitation,
      'message':
          'Sarah te invitó a "Caminata de fin de semana" en el círculo "Aventureros" el 28 de oct.',
      'timeAgo': 'hace 1d',
      'primaryAction': 'Establecer RSVP',
      'secondaryAction': 'Ver',
    },
    {
      'type': NotificationType.circleInvitation,
      'message':
          'Michael te ha invitado a unirte al círculo "Club de Lectura".',
      'timeAgo': 'hace 3d',
      'primaryAction': 'Aceptar',
      'secondaryAction': 'Rechazar',
    },
  ];

  late List<Map<String, dynamic>> _filteredNotifications;

  @override
  void initState() {
    super.initState();
    _filteredNotifications = List.from(_allNotifications);
  }

  void _filterNotifications(String filter) {
    setState(() {
      _selectedFilter = filter;
      _filteredNotifications = List.from(_allNotifications);

      // Aquí se pueden agregar filtros específicos según el tipo
      // Por ahora se muestran todas
    });
  }

  void _handleMarkAllRead() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Todas las notificaciones marcadas como leídas'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _dismissNotification(int index) {
    setState(() {
      _filteredNotifications.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notificación descartada'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Notificaciones', style: AppTextStyles.headlineMedium),
        actions: [
          TextButton(
            onPressed: _handleMarkAllRead,
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

          // Lista de notificaciones
          if (_filteredNotifications.isEmpty)
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
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredNotifications.length,
                itemBuilder: (context, index) {
                  final notification = _filteredNotifications[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildNotificationCard(
                      notification: notification,
                      index: index,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required Map<String, dynamic> notification,
    required int index,
  }) {
    final type = notification['type'] as NotificationType;
    final message = notification['message'] as String;
    final timeAgo = notification['timeAgo'] as String;
    final primaryAction = notification['primaryAction'] as String?;
    final secondaryAction = notification['secondaryAction'] as String?;

    final config = notificationConfigs[type]!;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
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
                      Text(message, style: AppTextStyles.bodyMedium),
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
                        text: primaryAction,
                        type: _getButtonType(type),
                        fullWidth: true,
                        onPressed: () {
                          _handleNotificationAction(type, primaryAction);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (secondaryAction != null)
                    Expanded(
                      child: AppButton(
                        text: secondaryAction,
                        type: primaryAction == null
                            ? AppButtonType.outline
                            : AppButtonType.outline,
                        fullWidth: true,
                        onPressed: () {
                          if (secondaryAction == 'Descartar') {
                            _dismissNotification(index);
                          } else {
                            _handleNotificationAction(type, secondaryAction);
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

  void _handleNotificationAction(NotificationType type, String action) {
    String message = '';
    Color color = AppColors.info;

    switch (action) {
      case 'Ver Evento':
        message = 'Navegando a detalles del evento...';
        color = AppColors.info;
        break;
      case 'Establecer RSVP':
        message = 'Abriendo selector de RSVP...';
        color = AppColors.info;
        break;
      case 'Resolver':
        message = 'Abriendo resolución de conflicto...';
        color = AppColors.warning;
        break;
      case 'Aceptar':
        message = '¡Invitación de círculo aceptada!';
        color = AppColors.success;
        break;
      case 'Rechazar':
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
