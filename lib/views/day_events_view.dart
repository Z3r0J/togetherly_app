import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../widgets/widgets.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../viewmodels/unified_calendar_view_model.dart';
import '../models/unified_calendar_models.dart';
import '../viewmodels/event_detail_view_model.dart';
import 'create_event_view.dart';
import 'event_detail_tabs_view.dart';
import '../widgets/resolve_conflict_dialog.dart';

/// Vista que muestra los eventos de un día específico o en formato calendario.
/// Reutiliza `CompactEventCard`, `EventCard`, `ConflictBanner` y `AppButton`.
class DayEventsView extends StatefulWidget {
  final DateTime? initialDate;

  const DayEventsView({super.key, this.initialDate});

  @override
  State<DayEventsView> createState() => _DayEventsViewState();
}

class _DayEventsViewState extends State<DayEventsView> {
  late DateTime _localSelectedDate;
  bool _isCalendarView =
      true; // Toggle entre lista y calendario - default: calendar
  bool _isYearlyView = false; // Toggle para vista anual

  @override
  void initState() {
    super.initState();
    _localSelectedDate = widget.initialDate ?? DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<UnifiedCalendarViewModel>();
      // Load the month for the local selected date without changing viewModel's selectedDate
      final firstDay = DateTime(
        _localSelectedDate.year,
        _localSelectedDate.month,
        1,
      );
      final lastDay = DateTime(
        _localSelectedDate.year,
        _localSelectedDate.month + 1,
        0,
        23,
        59,
        59,
      );
      viewModel.loadCalendar(startDate: firstDay, endDate: lastDay);
    });
  }

  void _openResolveDialog(UnifiedEvent event) {
    final conflict = event.conflictsWith.isNotEmpty
        ? event.conflictsWith.first
        : null;
    final timeFormat = DateFormat('h:mm a');
    String formatRange(DateTime s, DateTime e) =>
        '${timeFormat.format(s.toLocal())} - ${timeFormat.format(e.toLocal())}';

    String personalEventId = '';
    String circleEventId = '';
    String personalTitle = '';
    String circleTitle = '';
    String personalDate = '';
    String circleDate = '';
    String personalLocation = '';
    String circleLocation = '';
    String rsvpStatus = '';

    if (event is PersonalUnifiedEvent) {
      personalEventId = event.id;
      personalTitle = event.title;
      personalDate = formatRange(event.startTime, event.endTime);
      personalLocation = event.location?.name ?? '';
    } else if (event is CircleUnifiedEvent) {
      circleEventId = event.id;
      circleTitle = event.title;
      circleDate = formatRange(event.startTime, event.endTime);
      circleLocation = event.location?.name ?? '';
      rsvpStatus = event.rsvpStatus?.value ?? '';
    }

    if (conflict != null) {
      if (conflict.type == UnifiedEventType.personal) {
        personalEventId = conflict.id;
        personalTitle = conflict.title;
        personalDate = formatRange(conflict.startTime, conflict.endTime);
      } else {
        circleEventId = conflict.id;
        circleTitle = conflict.title;
        circleDate = formatRange(conflict.startTime, conflict.endTime);
      }
    }

    showDialog<bool>(
      context: context,
      builder: (dialogContext) => ResolveConflictDialog(
        personalEventId: personalEventId,
        circleEventId: circleEventId,
        personalTitle: personalTitle,
        circleTitle: circleTitle,
        personalDate: personalDate,
        circleDate: circleDate,
        personalLocation: personalLocation,
        circleLocation: circleLocation,
        rsvpStatus: rsvpStatus,
      ),
    ).then((result) {
      // If the dialog resolved the conflict (returns true), reload the
      // currently visible calendar month so all lists update.
      if (result == true && mounted) {
        final viewModel = context.read<UnifiedCalendarViewModel>();
        final firstDay = DateTime(
          _localSelectedDate.year,
          _localSelectedDate.month,
          1,
        );
        final lastDay = DateTime(
          _localSelectedDate.year,
          _localSelectedDate.month + 1,
          0,
        );
        viewModel.loadCalendar(startDate: firstDay, endDate: lastDay);
      }
    });
  }

  void _changeMonth(int monthOffset) {
    setState(() {
      _localSelectedDate = DateTime(
        _localSelectedDate.year,
        _localSelectedDate.month + monthOffset,
        1,
      );
    });

    final viewModel = context.read<UnifiedCalendarViewModel>();
    final firstDay = DateTime(
      _localSelectedDate.year,
      _localSelectedDate.month,
      1,
    );
    final lastDay = DateTime(
      _localSelectedDate.year,
      _localSelectedDate.month + 1,
      0,
    );
    viewModel.loadCalendar(startDate: firstDay, endDate: lastDay);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UnifiedCalendarViewModel>(
      builder: (context, viewModel, child) {
        final monthFormat = DateFormat('MMMM yyyy', 'es_ES');
        final yearFormat = DateFormat('yyyy');

        // Get all events for the month
        final allEvents = viewModel.calendarData?.events ?? [];

        // Group events by day (use local time to avoid UTC shift)
        final eventsByDay = <DateTime, List<UnifiedEvent>>{};
        for (var event in allEvents) {
          final localStart = event.startTime.toLocal();
          final dayKey = DateTime(
            localStart.year,
            localStart.month,
            localStart.day,
          );
          eventsByDay.putIfAbsent(dayKey, () => []).add(event);
        }

        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: Column(
              children: [
                // Encabezado con botones - ÚNICO, dinámico según vista
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            _isYearlyView
                                ? yearFormat.format(_localSelectedDate)
                                : monthFormat.format(_localSelectedDate),
                            style: AppTextStyles.titleLarge,
                          ),
                        ),
                      ),
                      // Botón izquierdo: toggle calendario/lista - SOLO en vista mensual
                      if (!_isYearlyView)
                        IconButton(
                          onPressed: () {
                            setState(() => _isCalendarView = !_isCalendarView);
                          },
                          icon: Icon(
                            _isCalendarView
                                ? Icons.view_list_outlined
                                : Icons.calendar_month_outlined,
                          ),
                        ),
                      // Botón derecho: toggle vista anual/mensual (MISMO ICONO)
                      IconButton(
                        onPressed: () {
                          setState(() => _isYearlyView = !_isYearlyView);
                        },
                        icon: const Icon(Icons.grid_3x3_outlined),
                        tooltip: _isYearlyView
                            ? 'Vista mensual'
                            : 'Vista anual',
                      ),
                    ],
                  ),
                ),

                // Sheet-like container
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Drag handle
                        Container(
                          width: 40,
                          height: 6,
                          margin: const EdgeInsets.only(top: 16, bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        // Navegación mes - Solo en vista mensual
                        if (!_isYearlyView)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () => _changeMonth(-1),
                                  icon: const Icon(Icons.chevron_left),
                                  iconSize: 24,
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      monthFormat.format(_localSelectedDate),
                                      style: AppTextStyles.labelSmall,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _changeMonth(1),
                                  icon: const Icon(Icons.chevron_right),
                                  iconSize: 24,
                                ),
                              ],
                            ),
                          ),

                        // Loading state
                        if (viewModel.isLoading)
                          const Expanded(
                            child: Center(child: CircularProgressIndicator()),
                          )
                        // Error state
                        else if (viewModel.error != null)
                          Expanded(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      viewModel.error?.message ??
                                          'Error desconocido',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.error,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    AppButton(
                                      text: 'Reintentar',
                                      onPressed: () =>
                                          viewModel.loadCurrentMonth(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        // Vista anual
                        else if (_isYearlyView)
                          Expanded(
                            child: _buildYearlyView(
                              _localSelectedDate,
                              eventsByDay,
                            ),
                          )
                        // Add Event pill y vistas de mes/lista
                        else
                          Expanded(
                            child: Column(
                              children: [
                                // Add Event pill
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: GestureDetector(
                                    onTap: () async {
                                      final result = await Navigator.of(context)
                                          .push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const CreateEventView(),
                                            ),
                                          );
                                      if (result == true && mounted) {
                                        final viewModel = context
                                            .read<UnifiedCalendarViewModel>();
                                        final firstDay = DateTime(
                                          _localSelectedDate.year,
                                          _localSelectedDate.month,
                                          1,
                                        );
                                        final lastDay = DateTime(
                                          _localSelectedDate.year,
                                          _localSelectedDate.month + 1,
                                          0,
                                        );
                                        await viewModel.loadCalendar(
                                          startDate: firstDay,
                                          endDate: lastDay,
                                        );
                                      }
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight
                                            .withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withOpacity(0.06),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.add,
                                              color: AppColors.primary,
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Agregar Evento',
                                            style: AppTextStyles.labelLarge
                                                .copyWith(
                                                  color: AppColors.primary,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // Vista de calendario o lista
                                if (_isCalendarView)
                                  Expanded(
                                    child: _buildCalendarView(
                                      _localSelectedDate,
                                      eventsByDay,
                                    ),
                                  )
                                else
                                  Expanded(
                                    child: _buildListView(
                                      _localSelectedDate,
                                      eventsByDay,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Vista de calendario con grid - MENOS ZOOM, MÁS COMPACTO
  Widget _buildCalendarView(
    DateTime currentDate,
    Map<DateTime, List<UnifiedEvent>> eventsByDay,
  ) {
    final firstDay = DateTime(currentDate.year, currentDate.month, 1);
    final lastDay = DateTime(currentDate.year, currentDate.month + 1, 0);
    final daysInMonth = lastDay.day;
    final firstWeekday = firstDay.weekday;

    // Obtener eventos con indicadores y conteo
    final Map<int, List<Color>> dayEventColors = {};
    for (var entry in eventsByDay.entries) {
      if (entry.key.year == currentDate.year &&
          entry.key.month == currentDate.month) {
        final day = entry.key.day;
        if (entry.value.isNotEmpty) {
          // Recopilar todos los colores de eventos de este día
          final colors = <Color>[];
          for (var event in entry.value) {
            Color? eventColor;
            if (event is CircleUnifiedEvent && event.circleColor != null) {
              eventColor = Color(
                int.parse(event.circleColor!.replaceFirst('#', '0xFF')),
              );
            } else if (event is PersonalUnifiedEvent && event.color != null) {
              eventColor = Color(
                int.parse(event.color!.replaceFirst('#', '0xFF')),
              );
            } else {
              eventColor = AppColors.primary;
            }
            colors.add(eventColor);
          }
          dayEventColors[day] = colors;
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Encabezados de días de la semana
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _WeekdayLabel('Lu'),
              _WeekdayLabel('Ma'),
              _WeekdayLabel('Mi'),
              _WeekdayLabel('Ju'),
              _WeekdayLabel('Vi'),
              _WeekdayLabel('Sa'),
              _WeekdayLabel('Do'),
            ],
          ),
          const SizedBox(height: 4),
          // Grid de días
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 3,
              crossAxisSpacing: 3,
              childAspectRatio: 1.0,
            ),
            itemCount: 42, // 6 filas x 7 columnas
            itemBuilder: (context, index) {
              final dayNumber = index - firstWeekday + 2;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox.shrink();
              }

              final eventColors = dayEventColors[dayNumber] ?? [];
              final isToday =
                  DateTime.now().year == currentDate.year &&
                  DateTime.now().month == currentDate.month &&
                  DateTime.now().day == dayNumber;

              return _buildCalendarDay(
                day: dayNumber,
                eventColors: eventColors,
                isToday: isToday,
                onTap: () {
                  // Mostrar eventos del día seleccionado
                  final selectedDate = DateTime(
                    currentDate.year,
                    currentDate.month,
                    dayNumber,
                  );
                  if (eventsByDay.containsKey(selectedDate)) {
                    _showDayEventsModal(
                      selectedDate,
                      eventsByDay[selectedDate]!,
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // Vista de lista de eventos por día
  Widget _buildListView(
    DateTime currentDate,
    Map<DateTime, List<UnifiedEvent>> eventsByDay,
  ) {
    final lastDayOfMonth = DateTime(currentDate.year, currentDate.month + 1, 0);
    final daysInMonth = <DateTime>[];
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      daysInMonth.add(DateTime(currentDate.year, currentDate.month, day));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: daysInMonth.length,
      itemBuilder: (context, index) {
        final day = daysInMonth[index];
        final eventsForDay = eventsByDay[day] ?? [];
        final dateFormat = DateFormat('EEEE, MMMM d', 'es_ES');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day header
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${dateFormat.format(day)} • ${eventsForDay.length} ${eventsForDay.length == 1 ? "evento" : "eventos"}',
                      style: AppTextStyles.titleMedium,
                    ),
                  ),
                ],
              ),
            ),

            // Events for this day
            if (eventsForDay.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  'Sin eventos',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else
              ...eventsForDay.map((event) {
                Widget eventWidget;
                if (event is PersonalUnifiedEvent) {
                  eventWidget = _buildPersonalEventCard(event);
                } else if (event is CircleUnifiedEvent) {
                  eventWidget = _buildCircleEventCard(event);
                } else {
                  eventWidget = const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: eventWidget,
                );
              }).toList(),

            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  // Día del calendario - COMPACTO, menos zoom
  Widget _buildCalendarDay({
    required int day,
    required List<Color> eventColors,
    required bool isToday,
    required VoidCallback onTap,
  }) {
    final hasEvents = eventColors.isNotEmpty;
    final primaryColor = eventColors.isNotEmpty ? eventColors.first : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: hasEvents
              ? (primaryColor?.withOpacity(0.12) ??
                    AppColors.primary.withOpacity(0.12))
              : (isToday
                    ? AppColors.primary.withOpacity(0.08)
                    : AppColors.background),
          border: Border.all(
            color: hasEvents
                ? (primaryColor ?? AppColors.primary)
                : (isToday ? AppColors.primary : AppColors.border),
            width: hasEvents ? 2 : (isToday ? 1.5 : 0.5),
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: hasEvents
              ? [
                  BoxShadow(
                    color: (primaryColor ?? AppColors.primary).withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Número del día
            Center(
              child: Text(
                day.toString(),
                style: AppTextStyles.labelSmall.copyWith(
                  color: hasEvents
                      ? (primaryColor ?? AppColors.primary)
                      : (isToday ? AppColors.primary : AppColors.textPrimary),
                  fontWeight: hasEvents
                      ? FontWeight.w700
                      : (isToday ? FontWeight.w600 : FontWeight.w500),
                  fontSize: 14,
                ),
              ),
            ),

            // Indicadores de eventos - compactos
            if (hasEvents)
              Positioned(
                bottom: 3,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...eventColors.take(2).map((color) {
                      return Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 2,
                              offset: const Offset(0, 0.5),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    if (eventColors.length > 2)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Text(
                          '+${eventColors.length - 2}',
                          style: AppTextStyles.labelSmall.copyWith(
                            fontSize: 6,
                            fontWeight: FontWeight.w700,
                            color: primaryColor ?? AppColors.primary,
                          ),
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

  // Modal para mostrar eventos del día
  void _showDayEventsModal(DateTime day, List<UnifiedEvent> events) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final dateFormat = DateFormat('EEEE, MMMM d', 'es_ES');
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 6,
                margin: const EdgeInsets.only(top: 16, bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${dateFormat.format(day)} • ${events.length} ${events.length == 1 ? "evento" : "eventos"}',
                  style: AppTextStyles.titleLarge,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    if (event is PersonalUnifiedEvent) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildPersonalEventCard(event),
                      );
                    } else if (event is CircleUnifiedEvent) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildCircleEventCard(event),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPersonalEventCard(PersonalUnifiedEvent event) {
    final timeFormat = DateFormat('h:mm a');
    final startTime = timeFormat.format(event.startTime.toLocal());
    final endTime = timeFormat.format(event.endTime.toLocal());
    final color = event.color != null
        ? Color(int.parse(event.color!.replaceFirst('#', '0xFF')))
        : AppColors.primary;

    return CompactEventCard(
      title: event.title,
      time: '$startTime - $endTime',
      location: event.location?.name,
      colorTag: color,
      rsvpStatus: null,
      hasConflict: event.hasConflict,
      conflictWith: event.conflictsWith.isNotEmpty
          ? event.conflictsWith.first.title
          : null,
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

  Widget _buildCircleEventCard(CircleUnifiedEvent event) {
    final timeFormat = DateFormat('h:mm a');
    final startTime = timeFormat.format(event.startTime.toLocal());
    final endTime = timeFormat.format(event.endTime.toLocal());
    final circleColor = event.circleColor != null
        ? Color(int.parse(event.circleColor!.replaceFirst('#', '0xFF')))
        : AppColors.primary;

    // For events with location, use EventCard
    if (event.location != null) {
      return Column(
        children: [
          EventCard(
            title: event.title,
            date: DateFormat(
              'EEEE, MMMM d',
              'es_ES',
            ).format(event.startTime.toLocal()),
            time: '$startTime - $endTime',
            location: event.location?.name ?? 'Sin ubicación',
            rsvpStatus: event.rsvpStatus,
            attendeeCount: event.attendeeCount,
            circleLabel: event.circleName,
            circleColor: circleColor,
            hasConflict: event.hasConflict,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventDetailTabsView(event: event),
                ),
              );
            },
            onViewDetails: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventDetailTabsView(event: event),
                ),
              );
            },
            onResolve: () => _openResolveDialog(event),
          ),
          if (event.hasConflict) ...[
            const SizedBox(height: 8),
            _buildConflictBanner(event),
          ],
        ],
      );
    }

    // For simpler events, use CompactEventCard
    return Column(
      children: [
        CompactEventCard(
          title: event.title,
          time: '$startTime - $endTime',
          location: event.location?.name,
          colorTag: circleColor,
          rsvpStatus: event.rsvpStatus,
          hasConflict: event.hasConflict,
          conflictWith: event.conflictsWith.isNotEmpty
              ? event.conflictsWith.first.title
              : null,
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
          onResolve: () => _openResolveDialog(event),
        ),
        if (event.hasConflict) ...[
          const SizedBox(height: 8),
          _buildConflictBanner(event),
        ],
      ],
    );
  }

  Widget _buildConflictBanner(UnifiedEvent event) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              // Show the title of the first conflicting event if available
              event.conflictsWith.isNotEmpty
                  ? 'Conflicts with "${event.conflictsWith.first.title}"'
                  : 'Event conflicts with another in your calendar',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.warning,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // Open ResolveConflictDialog (modal) and pass event + first conflict safely
              final conflict = event.conflictsWith.isNotEmpty
                  ? event.conflictsWith.first
                  : null;
              final timeFormat = DateFormat('h:mm a');
              String formatRange(DateTime s, DateTime e) =>
                  '${timeFormat.format(s.toLocal())} - ${timeFormat.format(e.toLocal())}';

              // Prepare parameters for dialog
              String personalEventId = '';
              String circleEventId = '';
              String personalTitle = '';
              String circleTitle = '';
              String personalDate = '';
              String circleDate = '';
              String personalLocation = '';
              String circleLocation = '';
              String rsvpStatus = '';

              if (event is PersonalUnifiedEvent) {
                personalEventId = event.id;
                personalTitle = event.title;
                personalDate = formatRange(event.startTime, event.endTime);
                personalLocation = event.location?.name ?? '';
              } else if (event is CircleUnifiedEvent) {
                circleEventId = event.id;
                circleTitle = event.title;
                circleDate = formatRange(event.startTime, event.endTime);
                circleLocation = event.location?.name ?? '';
                rsvpStatus = event.rsvpStatus?.value ?? '';
              }

              if (conflict != null) {
                if (conflict.type == UnifiedEventType.personal) {
                  personalEventId = conflict.id;
                  personalTitle = conflict.title;
                  personalDate = formatRange(
                    conflict.startTime,
                    conflict.endTime,
                  );
                } else {
                  circleEventId = conflict.id;
                  circleTitle = conflict.title;
                  circleDate = formatRange(
                    conflict.startTime,
                    conflict.endTime,
                  );
                }
              }

              showDialog<bool>(
                context: context,
                builder: (dialogContext) => ResolveConflictDialog(
                  personalEventId: personalEventId,
                  circleEventId: circleEventId,
                  personalTitle: personalTitle,
                  circleTitle: circleTitle,
                  personalDate: personalDate,
                  circleDate: circleDate,
                  personalLocation: personalLocation,
                  circleLocation: circleLocation,
                  rsvpStatus: rsvpStatus,
                ),
              ).then((result) {
                // If the dialog resolved the conflict, reload the current
                // month so that every listing reflects the new response.
                if (result == true && mounted) {
                  final viewModel = context.read<UnifiedCalendarViewModel>();
                  final firstDay = DateTime(
                    _localSelectedDate.year,
                    _localSelectedDate.month,
                    1,
                  );
                  final lastDay = DateTime(
                    _localSelectedDate.year,
                    _localSelectedDate.month + 1,
                    0,
                  );
                  viewModel.loadCalendar(startDate: firstDay, endDate: lastDay);
                }
              });
            },
            child: Text(
              'Resolve',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Vista anual de los 12 meses del año - COMO SCREENSHOT (todos los días visibles)
  Widget _buildYearlyView(
    DateTime currentDate,
    Map<DateTime, List<UnifiedEvent>> eventsByDay,
  ) {
    final year = currentDate.year;
    final yearFormat = DateFormat('yyyy');
    final monthFormat = DateFormat('MMMM', 'es_ES');

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      child: Column(
        children: [
          // Año actual
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    setState(
                      () => _localSelectedDate = DateTime(year - 1, 1, 1),
                    );
                  },
                  icon: const Icon(Icons.chevron_left),
                  iconSize: 28,
                ),
                Text(
                  yearFormat.format(DateTime(year)),
                  style: AppTextStyles.titleLarge,
                ),
                IconButton(
                  onPressed: () {
                    setState(
                      () => _localSelectedDate = DateTime(year + 1, 1, 1),
                    );
                  },
                  icon: const Icon(Icons.chevron_right),
                  iconSize: 28,
                ),
              ],
            ),
          ),

          // Grid de 12 meses
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 0.85,
            ),
            itemCount: 12,
            itemBuilder: (context, monthIndex) {
              final month = monthIndex + 1;
              final monthDate = DateTime(year, month);
              final monthName = monthFormat.format(monthDate);
              final firstDay = DateTime(year, month, 1);
              final lastDay = DateTime(year, month + 1, 0);
              final daysInMonth = lastDay.day;
              final firstWeekday = firstDay.weekday;

              // Mapa de días con eventos para este mes
              final monthEventMap = <int, List<Color>>{};
              for (var entry in eventsByDay.entries) {
                if (entry.key.year == year && entry.key.month == month) {
                  final day = entry.key.day;
                  final colors = <Color>[];
                  for (var event in entry.value) {
                    Color? eventColor;
                    if (event is CircleUnifiedEvent &&
                        event.circleColor != null) {
                      eventColor = Color(
                        int.parse(event.circleColor!.replaceFirst('#', '0xFF')),
                      );
                    } else if (event is PersonalUnifiedEvent &&
                        event.color != null) {
                      eventColor = Color(
                        int.parse(event.color!.replaceFirst('#', '0xFF')),
                      );
                    } else {
                      eventColor = AppColors.primary;
                    }
                    colors.add(eventColor);
                  }
                  monthEventMap[day] = colors;
                }
              }

              return Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textPrimary.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Nombre del mes - Header mejorado
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.surface,
                            AppColors.surface.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(14),
                        ),
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.border,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Text(
                        monthName,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    // Mini calendario
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Column(
                          children: [
                            // Encabezados de días (compacto)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _MiniWeekdayLabel('L'),
                                _MiniWeekdayLabel('M'),
                                _MiniWeekdayLabel('X'),
                                _MiniWeekdayLabel('J'),
                                _MiniWeekdayLabel('V'),
                                _MiniWeekdayLabel('S'),
                                _MiniWeekdayLabel('D'),
                              ],
                            ),
                            const SizedBox(height: 3),
                            // Grid de días
                            Expanded(
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 7,
                                      mainAxisSpacing: 2,
                                      crossAxisSpacing: 2,
                                    ),
                                itemCount: 42,
                                itemBuilder: (context, index) {
                                  final dayNumber = index - firstWeekday + 2;

                                  if (dayNumber < 1 ||
                                      dayNumber > daysInMonth) {
                                    return const SizedBox.shrink();
                                  }

                                  final hasEvents = monthEventMap.containsKey(
                                    dayNumber,
                                  );
                                  final isToday =
                                      DateTime.now().year == year &&
                                      DateTime.now().month == month &&
                                      DateTime.now().day == dayNumber;

                                  return _buildMiniCalendarDay(
                                    day: dayNumber,
                                    hasEvents: hasEvents,
                                    eventColors: monthEventMap[dayNumber] ?? [],
                                    isToday: isToday,
                                    onTap: () {
                                      final selectedDate = DateTime(
                                        year,
                                        month,
                                        dayNumber,
                                      );
                                      if (eventsByDay.containsKey(
                                        selectedDate,
                                      )) {
                                        _showDayEventsModal(
                                          selectedDate,
                                          eventsByDay[selectedDate]!,
                                        );
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Día mini para vista anual - MUCHO MÁS COMPACTO
  Widget _buildMiniCalendarDay({
    required int day,
    required bool hasEvents,
    required List<Color> eventColors,
    required bool isToday,
    required VoidCallback onTap,
  }) {
    final primaryColor = eventColors.isNotEmpty ? eventColors.first : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: hasEvents
              ? (primaryColor?.withOpacity(0.18) ??
                    AppColors.primary.withOpacity(0.18))
              : (isToday
                    ? AppColors.primary.withOpacity(0.12)
                    : AppColors.background),
          border: Border.all(
            color: hasEvents
                ? primaryColor ?? AppColors.primary
                : (isToday
                      ? AppColors.primary
                      : AppColors.border.withOpacity(0.5)),
            width: hasEvents ? 1 : (isToday ? 1 : 0.3),
          ),
          borderRadius: BorderRadius.circular(6),
          boxShadow: hasEvents
              ? [
                  BoxShadow(
                    color: (primaryColor ?? AppColors.primary).withOpacity(
                      0.15,
                    ),
                    blurRadius: 2,
                    offset: const Offset(0, 0.5),
                  ),
                ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Número del día
            Text(
              day.toString(),
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 9,
                color: hasEvents
                    ? primaryColor
                    : (isToday ? AppColors.primary : AppColors.textPrimary),
                fontWeight: hasEvents
                    ? FontWeight.w700
                    : (isToday ? FontWeight.w600 : FontWeight.w500),
              ),
            ),

            // Indicadores de eventos (compacto pero visible)
            if (hasEvents && eventColors.isNotEmpty)
              Positioned(
                bottom: 1,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...eventColors.take(2).map((color) {
                      return Container(
                        width: 3,
                        height: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 0.5),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 1,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Widget para etiquetas de días de la semana
class _WeekdayLabel extends StatelessWidget {
  final String label;

  const _WeekdayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// Widget para etiquetas mini de días (vista anual)
class _MiniWeekdayLabel extends StatelessWidget {
  final String label;

  const _MiniWeekdayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 9,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
