import 'package:flutter/material.dart';
import '../models/unified_calendar_models.dart';
import '../models/api_error.dart';
import '../services/calendar_service.dart';

class UnifiedCalendarViewModel extends ChangeNotifier {
  final CalendarService _calendarService = CalendarService();

  UnifiedCalendarResponse? _calendarData;
  bool _isLoading = false;
  ApiError? _error;
  String _currentFilter = 'all';
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime _selectedDate = DateTime.now();

  UnifiedCalendarResponse? get calendarData => _calendarData;
  bool get isLoading => _isLoading;
  ApiError? get error => _error;
  String get currentFilter => _currentFilter;
  DateTime get selectedDate => _selectedDate;

  // Get events for current month
  Future<void> loadCurrentMonth() async {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    await loadCalendar(startDate: firstDay, endDate: lastDay);
  }

  // Load calendar for specific date range
  Future<void> loadCalendar({
    DateTime? startDate,
    DateTime? endDate,
    String? filter,
  }) async {
    _isLoading = true;
    _error = null;
    _startDate = startDate;
    _endDate = endDate;
    if (filter != null) _currentFilter = filter;
    notifyListeners();

    try {
      print('🔵 [UnifiedCalendarViewModel] Loading calendar...');
      _calendarData = await _calendarService.getUnifiedCalendar(
        startDate: startDate,
        endDate: endDate,
        filter: _currentFilter,
      );
      print(
        '✅ [UnifiedCalendarViewModel] Calendar loaded: ${_calendarData?.events.length} events',
      );
      _error = null;
    } on ApiError catch (e) {
      print('❌ [UnifiedCalendarViewModel] API Error: ${e.message}');
      _error = e;
      _calendarData = null;
    } catch (e) {
      print('❌ [UnifiedCalendarViewModel] Unexpected error: $e');
      _error = ApiError(
        errorCode: 'CALENDAR_LOAD_FAILED',
        message: e.toString(),
      );
      _calendarData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Change filter
  Future<void> setFilter(String filter) async {
    if (_currentFilter != filter) {
      await loadCalendar(
        startDate: _startDate,
        endDate: _endDate,
        filter: filter,
      );
    }
  }

  // Navigate to specific date
  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // Navigate to previous month
  Future<void> previousMonth() async {
    final newDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
    _selectedDate = newDate;
    notifyListeners();

    final firstDay = DateTime(newDate.year, newDate.month, 1);
    final lastDay = DateTime(newDate.year, newDate.month + 1, 0, 23, 59, 59);
    await loadCalendar(startDate: firstDay, endDate: lastDay);
  }

  // Navigate to next month
  Future<void> nextMonth() async {
    final newDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
    _selectedDate = newDate;
    notifyListeners();

    final firstDay = DateTime(newDate.year, newDate.month, 1);
    final lastDay = DateTime(newDate.year, newDate.month + 1, 0, 23, 59, 59);
    await loadCalendar(startDate: firstDay, endDate: lastDay);
  }

  // Get events for specific date
  List<UnifiedEvent> getEventsForDate(DateTime date) {
    if (_calendarData == null) return [];

    return _calendarData!.events.where((event) {
      final eventDate = event.startTime.toLocal();
      return eventDate.year == date.year &&
          eventDate.month == date.month &&
          eventDate.day == date.day;
    }).toList();
  }

  // Get events by type
  List<PersonalUnifiedEvent> get personalEvents {
    return _calendarData?.events.whereType<PersonalUnifiedEvent>().toList() ??
        [];
  }

  List<CircleUnifiedEvent> get circleEvents {
    return _calendarData?.events.whereType<CircleUnifiedEvent>().toList() ?? [];
  }

  // Get events with conflicts
  List<UnifiedEvent> get eventsWithConflicts {
    return _calendarData?.events
            .where((e) => e.conflictsWith.isNotEmpty)
            .toList() ??
        [];
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  bool shouldNavigateToLogin() {
    return _error?.errorCode == 'AUTH_SESSION_EXPIRED';
  }
}
