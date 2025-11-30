import 'package:flutter/material.dart';
import '../services/event_service.dart';

class CircleEventViewModel extends ChangeNotifier {
  final EventService _service;

  CircleEventViewModel({EventService? service})
      : _service = service ?? EventService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> create(Map<String, dynamic> payload) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.createCircleEvent(payload);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
