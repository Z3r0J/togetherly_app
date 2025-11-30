import 'package:flutter/material.dart';
import '../models/personal_event_models.dart';
import '../models/location_models.dart';
import '../services/personal_event_service.dart';

class PersonalEventViewModel extends ChangeNotifier {
  final PersonalEventService _service;

  PersonalEventViewModel({PersonalEventService? service})
      : _service = service ?? PersonalEventService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> create({
    required String title,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    required bool allDay,
    LocationModel? location,
    String? notes,
    int? reminderMinutes,
    required String color,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final request = CreatePersonalEventRequest(
        title: title,
        date: date,
        startTime: startTime,
        endTime: endTime,
        location: location,
        notes: notes,
        allDay: allDay,
        reminderMinutes: reminderMinutes,
        color: color,
      );

      await _service.createPersonalEvent(request);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
