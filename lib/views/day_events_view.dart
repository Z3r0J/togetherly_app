import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../widgets/widgets.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../viewmodels/unified_calendar_view_model.dart';
import '../models/unified_calendar_models.dart';
import 'create_event_view.dart';
import 'event_detail_tabs_view.dart';

/// Vista que muestra los eventos de un día específico.
/// Reutiliza `CompactEventCard`, `EventCard`, `ConflictBanner` y `AppButton`.
class DayEventsView extends StatefulWidget {
  final DateTime? initialDate;

  const DayEventsView({super.key, this.initialDate});

  @override
  State<DayEventsView> createState() => _DayEventsViewState();
}

class _DayEventsViewState extends State<DayEventsView> {
  late DateTime _localSelectedDate;

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
      );
      viewModel.loadCalendar(startDate: firstDay, endDate: lastDay);
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

        // Get all events for the month
        final allEvents = viewModel.calendarData?.events ?? [];

        // Group events by day
        final eventsByDay = <DateTime, List<UnifiedEvent>>{};
        for (var event in allEvents) {
          final dayKey = DateTime(
            event.startTime.year,
            event.startTime.month,
            event.startTime.day,
          );
          eventsByDay.putIfAbsent(dayKey, () => []).add(event);
        }

        // Get all days in the month (using local selected date)
        final lastDayOfMonth = DateTime(
          _localSelectedDate.year,
          _localSelectedDate.month + 1,
          0,
        );
        final daysInMonth = <DateTime>[];
        for (int day = 1; day <= lastDayOfMonth.day; day++) {
          daysInMonth.add(
            DateTime(_localSelectedDate.year, _localSelectedDate.month, day),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: Column(
              children: [
                // Encabezado mes
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => _changeMonth(-1),
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            monthFormat.format(_localSelectedDate),
                            style: AppTextStyles.titleLarge,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _changeMonth(1),
                        icon: const Icon(Icons.chevron_right),
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

                        // Add Event pill
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CreateEventView(),
                              ),
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(
                                        0.06,
                                      ),
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
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

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
                        // Events list by day
                        else
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: daysInMonth.length,
                              itemBuilder: (context, index) {
                                final day = daysInMonth[index];
                                final eventsForDay = eventsByDay[day] ?? [];
                                final dateFormat = DateFormat(
                                  'EEEE, MMMM d',
                                  'es_ES',
                                );

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Day header
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 8,
                                        bottom: 12,
                                      ),
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
                                        padding: const EdgeInsets.only(
                                          bottom: 24,
                                        ),
                                        child: Text(
                                          'Sin eventos',
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                        ),
                                      )
                                    else
                                      ...eventsForDay.map((event) {
                                        Widget eventWidget;
                                        if (event is PersonalUnifiedEvent) {
                                          eventWidget = _buildPersonalEventCard(
                                            event,
                                          );
                                        } else if (event
                                            is CircleUnifiedEvent) {
                                          eventWidget = _buildCircleEventCard(
                                            event,
                                          );
                                        } else {
                                          eventWidget = const SizedBox.shrink();
                                        }

                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          child: eventWidget,
                                        );
                                      }).toList(),

                                    const SizedBox(height: 12),
                                  ],
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
          ),
        );
      },
    );
  }

  Widget _buildPersonalEventCard(PersonalUnifiedEvent event) {
    final timeFormat = DateFormat('h:mm a');
    final startTime = timeFormat.format(event.startTime);
    final endTime = timeFormat.format(event.endTime);
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
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EventDetailTabsView(event: event),
          ),
        );
      },
    );
  }

  Widget _buildCircleEventCard(CircleUnifiedEvent event) {
    final timeFormat = DateFormat('h:mm a');
    final startTime = timeFormat.format(event.startTime);
    final endTime = timeFormat.format(event.endTime);
    final circleColor = event.circleColor != null
        ? Color(int.parse(event.circleColor!.replaceFirst('#', '0xFF')))
        : AppColors.primary;

    // For events with location, use EventCard
    if (event.location != null) {
      return Column(
        children: [
          EventCard(
            title: event.title,
            date: DateFormat('EEEE, MMMM d', 'es_ES').format(event.startTime),
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
          ),
          if (event.hasConflict) ...[
            const SizedBox(height: 8),
            _buildConflictBanner(),
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EventDetailTabsView(event: event),
              ),
            );
          },
        ),
        if (event.hasConflict) ...[
          const SizedBox(height: 8),
          _buildConflictBanner(),
        ],
      ],
    );
  }

  Widget _buildConflictBanner() {
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
              'Event conflicts with another in your calendar',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.warning,
              ),
            ),
          ),
          TextButton(
            onPressed: () {},
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
}
