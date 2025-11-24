import 'package:flutter/material.dart';
import '../models/personal_event_models.dart';
import '../models/location_models.dart';
import '../models/api_error.dart';
import '../services/personal_event_service.dart';

class PersonalEventViewModel extends ChangeNotifier {
  final PersonalEventService _personalEventService = PersonalEventService();

  bool _isLoading = false;
  ApiError? _error;

  bool get isLoading => _isLoading;
  ApiError? get error => _error;

  Future<bool> createPersonalEvent({
    required String title,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    required bool allDay,
    required Color selectedColor,
    required int reminderMinutes,
    LocationModel? location,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔵 [PersonalEventViewModel] Creating event...');

      final request = CreatePersonalEventRequest(
        title: title,
        date: date,
        startTime: startTime,
        endTime: endTime,
        allDay: allDay,
        location: location,
        notes: notes,
        color: '#${selectedColor.value.toRadixString(16).substring(2, 8)}',
        reminderMinutes: reminderMinutes,
      );

      final response = await _personalEventService.createPersonalEvent(request);

      print('✅ [PersonalEventViewModel] Event created: ${response.data.id}');

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiError catch (e) {
      print('❌ [PersonalEventViewModel] API Error: ${e.message}');
      _error = e;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('❌ [PersonalEventViewModel] Unexpected error: $e');
      _error = ApiError(
        errorCode: 'PERSONAL_EVENT_CREATE_FAILED',
        message: 'An unexpected error occurred: ${e.toString()}',
      );
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String getErrorMessage() {
    if (_error == null) return '';

    switch (_error!.errorCode) {
      case 'PERSONAL_EVENT_INVALID_TIME':
        return 'Start time must be before end time';
      case 'PERSONAL_EVENT_TIME_CONFLICT':
        return 'This time slot conflicts with another event';
      case 'AUTH_SESSION_EXPIRED':
        return 'Your session has expired. Please log in again.';
      case 'NETWORK_ERROR':
        return 'Network error. Please check your connection.';
      default:
        return _error!.message;
    }
  }

  bool shouldNavigateToLogin() {
    return _error?.errorCode == 'AUTH_SESSION_EXPIRED';
  }
}
