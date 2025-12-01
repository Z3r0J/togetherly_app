import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:togetherly_app/views/event_detail_tabs_view.dart';
import '../widgets/widgets.dart';
import '../models/unified_calendar_models.dart';
import '../viewmodels/auth_view_model.dart';
import '../viewmodels/circle_view_model.dart';
import '../viewmodels/unified_calendar_view_model.dart';
import '../viewmodels/event_detail_view_model.dart';
import 'create_event_view.dart';
import '../l10n/app_localizations.dart';
import 'notifications_view.dart';
import 'login_view.dart';
import 'my_circles_view.dart';
import 'circle_detail_view.dart';
import 'create_circle_view.dart';
import 'day_events_view.dart';
import 'profile_settings_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late final AppLocalizations l10n;
  bool _isFABOpen = false;
  String _localFilter = 'all'; // Local filter state for dashboard only

  @override
  void initState() {
    super.initState();
    l10n = AppLocalizations.instance;
    // Fetch circles and calendar on dashboard load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CircleViewModel>().fetchCircles();
      context.read<UnifiedCalendarViewModel>().loadCurrentMonth();
    });
  }

  Future<void> _refreshData() async {
    await Future.wait([
      context.read<CircleViewModel>().fetchCircles(),
      context.read<UnifiedCalendarViewModel>().loadCurrentMonth(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con saludo y notificación
                _buildHeader(),

                const SizedBox(height: 24),

                // Sección "Mis Círculos"
                _buildCirclesSection(),

                const SizedBox(height: 32),

                // Sección "Próximos Eventos"
                _buildUpcomingEventsSection(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildSpeedDialFAB(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.tr('dashboard.greeting'),
                  style: AppTextStyles.headlineMedium,
                ),
                Consumer<AuthViewModel>(
                  builder: (context, authViewModel, _) {
                    final userName =
                        authViewModel.currentUser?.name ?? 'Usuario';
                    return Text(
                      userName,
                      style: AppTextStyles.headlineMedium,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  l10n
                      .tr('dashboard.date')
                      .replaceAll(
                        '{date}',
                        DateFormat(
                          'd \'de\' MMMM',
                          'es_ES',
                        ).format(DateTime.now()),
                      ),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Avatar del usuario y botón de notificaciones
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                color: AppColors.textPrimary,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsView(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                offset: const Offset(0, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) async {
                  if (value == 'logout') {
                    await _handleLogout();
                  } else if (value == 'profile' || value == 'settings') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfileSettingsView(),
                      ),
                    );
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline),
                        const SizedBox(width: 8),
                        Text(l10n.tr('dashboard.menu.profile')),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'settings',
                    child: Row(
                      children: [
                        const Icon(Icons.settings_outlined),
                        const SizedBox(width: 8),
                        Text(l10n.tr('dashboard.menu.settings')),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        const Icon(Icons.logout, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          l10n.tr('dashboard.menu.logout'),
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
                child: Consumer<AuthViewModel>(
                  builder: (context, authViewModel, _) {
                    final userName =
                        authViewModel.currentUser?.name ?? 'Usuario';
                    return UserAvatar(
                      name: userName,
                      size: 56,
                      backgroundColor: AppColors.primary,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCirclesSection() {
    return Consumer<CircleViewModel>(
      builder: (context, circleViewModel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título y "See All"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.tr('dashboard.section.circles'),
                    style: AppTextStyles.headlineSmall,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyCirclesView(),
                        ),
                      );
                    },
                    child: Text(
                      l10n.tr('dashboard.link.view_all'),
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Circles horizontales with loading/error states
            _buildCirclesContent(circleViewModel),
          ],
        );
      },
    );
  }

  Widget _buildCirclesContent(CircleViewModel circleViewModel) {
    if (circleViewModel.isLoading) {
      return const SizedBox(
        height: 165,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (circleViewModel.state == CircleState.error) {
      return SizedBox(
        height: 165,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                circleViewModel.errorMessage ??
                    l10n.tr('dashboard.error.loading_circles'),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => circleViewModel.fetchCircles(),
                child: Text(l10n.tr('dashboard.action.retry')),
              ),
            ],
          ),
        ),
      );
    }

    if (!circleViewModel.hasCircles) {
      return SizedBox(
        height: 165,
        child: Center(
          child: Text(
            l10n.tr('dashboard.empty.no_circles'),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 165,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: circleViewModel.circles.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final circle = circleViewModel.circles[index];
          return _buildCircleCardItem(
            id: circle.id,
            name: circle.name,
            memberCount: circle.memberCountInt,
            eventTitle: null,
            eventDate: null,
            color: AppColors.getCircleColor(circle.color),
          );
        },
      ),
    );
  }

  Widget _buildCircleCardItem({
    required String id,
    required String name,
    required int memberCount,
    String? eventTitle,
    String? eventDate,
    required Color color,
  }) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header con color y nombre
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: AppTextStyles.headlineSmall.copyWith(fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$memberCount ${l10n.tr('dashboard.label.members')}',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),

          // Próximo evento
          if (eventTitle != null && eventDate != null) ...[
            Text(
              l10n.tr('dashboard.section.upcoming_event'),
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textTertiary,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              eventTitle,
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              eventDate,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
          ] else ...[
            Text(
              l10n.tr('dashboard.empty.no_events'),
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Botón Ver Círculo
          AppButton(
            text: l10n.tr('dashboard.link.view_circle'),
            type: AppButtonType.text,
            size: AppButtonSize.small,
            fullWidth: true,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CircleDetailView(
                    circleId: id,
                    circleName: name,
                    circleColor: color,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventsSection() {
    return Consumer<UnifiedCalendarViewModel>(
      builder: (context, viewModel, child) {
        // Sort events descending by startTime (nearest first, then older)
        final allEvents = viewModel.calendarData?.events ?? [];
        allEvents.sort((a, b) => b.startTime.compareTo(a.startTime));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título con botón Ver Todo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.tr('dashboard.section.events'),
                    style: AppTextStyles.headlineSmall,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider(
                            create: (_) => UnifiedCalendarViewModel(),
                            child: const DayEventsView(),
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Ver Todo',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Filtros
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildFilterChip('Todos', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Personal', 'personal'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Confirmado', 'going'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Tal vez', 'maybe'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Lista de eventos (filtrados localmente)
            Builder(
              builder: (context) {
                final filteredEvents = _filterEvents(allEvents, _localFilter);

                if (viewModel.isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (viewModel.error != null) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'Error al cargar eventos',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  );
                } else if (filteredEvents.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'No hay eventos para este filtro',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(children: _buildEventsList(filteredEvents)),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  List<UnifiedEvent> _filterEvents(List<UnifiedEvent> events, String filter) {
    switch (filter) {
      case 'personal':
        return events.where((e) => e is PersonalUnifiedEvent).toList();
      case 'going':
        return events.where((e) {
          if (e is CircleUnifiedEvent) {
            return e.rsvpStatus == RsvpStatus.going;
          }
          return false;
        }).toList();
      case 'maybe':
        return events.where((e) {
          if (e is CircleUnifiedEvent) {
            return e.rsvpStatus == RsvpStatus.maybe;
          }
          return false;
        }).toList();
      case 'all':
      default:
        return events;
    }
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _localFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _localFilter = value;
          });
        }
      },
      backgroundColor: AppColors.background,
      selectedColor: AppColors.primary,
      labelStyle: AppTextStyles.labelMedium.copyWith(
        color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
      ),
    );
  }

  List<Widget> _buildEventsList(List<dynamic> events) {
    // Sort by start time DESC (nearest upcoming first) and take only first 3
    final sorted = [...events]
      ..sort((a, b) => b.startTime.toLocal().compareTo(a.startTime.toLocal()));
    final limitedEvents = sorted.take(3).toList();
    final List<Widget> widgets = [];

    for (int i = 0; i < limitedEvents.length; i++) {
      final event = limitedEvents[i];

      if (event is PersonalUnifiedEvent) {
        widgets.add(_buildPersonalEventItem(event));
      } else if (event is CircleUnifiedEvent) {
        widgets.add(_buildCircleEventItem(event));
      }

      if (i < limitedEvents.length - 1) {
        widgets.add(const SizedBox(height: 16));
      }
    }

    return widgets;
  }

  Widget _buildPersonalEventItem(PersonalUnifiedEvent event) {
    final dateTime = event.startTime.toLocal();
    final monthFormat = DateFormat('MMM', 'es_ES');
    final dayFormat = DateFormat('d');

    return _buildEventItem(
      title: event.title,
      date: monthFormat.format(dateTime).toUpperCase(),
      dateNumber: dayFormat.format(dateTime),
      circle: 'PERSONAL',
      circleColor: event.color != null
          ? AppColors.hexToColor(event.color!)
          : AppColors.primary,
      time:
          '${DateFormat('h:mm a').format(dateTime)}${event.location != null ? ' @ ${event.location!.name}' : ''}',
      rsvpStatus: null,
      attendeeCount: null,
      hasConflict: event.hasConflict,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(
              create: (_) => EventDetailViewModel(),
              child: EventDetailTabsView(event: event),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCircleEventItem(CircleUnifiedEvent event) {
    final dateTime = event.startTime.toLocal();
    final monthFormat = DateFormat('MMM', 'es_ES');
    final dayFormat = DateFormat('d');

    return _buildEventItem(
      title: event.title,
      date: monthFormat.format(dateTime).toUpperCase(),
      dateNumber: dayFormat.format(dateTime),
      circle: event.circleName.toUpperCase(),
      circleColor: event.circleColor != null
          ? AppColors.hexToColor(event.circleColor!)
          : AppColors.circleBlue,
      time:
          '${DateFormat('h:mm a').format(dateTime)}${event.location != null ? ' @ ${event.location!.name}' : ''}',
      rsvpStatus: event.rsvpStatus,
      attendeeCount: event.attendeeCount,
      hasConflict: event.hasConflict,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(
              create: (_) => EventDetailViewModel(),
              child: EventDetailTabsView(event: event),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventItem({
    required String title,
    required String date,
    required String dateNumber,
    required String circle,
    required Color circleColor,
    required String time,
    RsvpStatus? rsvpStatus,
    int? attendeeCount,
    bool hasConflict = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fecha
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    date,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    dateNumber,
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Contenido del evento
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Círculo/Categoría
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: circleColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        circle,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: circleColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Título
                  Text(
                    title,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Hora y lugar
                  Text(
                    time,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // RSVP y asistentes (solo para eventos de círculo)
                  if (rsvpStatus != null && attendeeCount != null)
                    Row(
                      children: [
                        RsvpBadge(status: rsvpStatus),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.people_outline,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$attendeeCount',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                  // Indicator de conflicto
                  if (hasConflict)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 16,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Conflicto',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final authViewModel = context.read<AuthViewModel>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.tr('dashboard.dialog.logout_title')),
        content: Text(l10n.tr('dashboard.dialog.logout_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.tr('common.button.cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.tr('dashboard.menu.logout')),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await authViewModel.logout();

      if (!mounted) return;

      // Navigate to login and clear navigation stack
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginView()),
        (route) => false,
      );
    }
  }

  Widget _buildSpeedDialFAB() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isFABOpen) ...[
          // Create Event Option
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'Crear Evento',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 12),
              FloatingActionButton(
                heroTag: 'create_event',
                mini: true,
                backgroundColor: AppColors.primary,
                onPressed: () async {
                  setState(() => _isFABOpen = false);
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateEventView()),
                  );
                  if (result == true && mounted) {
                    await context
                        .read<UnifiedCalendarViewModel>()
                        .loadCurrentMonth();
                    await context.read<CircleViewModel>().fetchCircles();
                  }
                },
                child: const Icon(Icons.event, color: AppColors.textOnPrimary),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Create Circle Option
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'Create Circle',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 12),
              FloatingActionButton(
                heroTag: 'create_circle',
                mini: true,
                backgroundColor: AppColors.primary,
                onPressed: () {
                  setState(() => _isFABOpen = false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateCircleView()),
                  );
                },
                child: const Icon(
                  Icons.group_add,
                  color: AppColors.textOnPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Main FAB
        FloatingActionButton(
          heroTag: 'main_fab',
          onPressed: () {
            setState(() => _isFABOpen = !_isFABOpen);
          },
          backgroundColor: AppColors.primary,
          child: AnimatedRotation(
            turns: _isFABOpen ? 0.125 : 0, // 45 degrees when open
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.add, color: AppColors.textOnPrimary),
          ),
        ),
      ],
    );
  }
}
