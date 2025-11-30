import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/calendar_service.dart';
import '../services/auth_service.dart';

class ResolveConflictViewModel extends ChangeNotifier {
  final CalendarService api;
  bool isLoading = false;
  String? lastMessage;

  ResolveConflictViewModel({CalendarService? api}) : api = api ?? CalendarService();

  Future<String?> _getToken() async {
    final auth = AuthService();
    return await auth.getAccessToken();
  }

  Future<bool> resolveConflict({
    required String eventId,
    required String eventType,
    required String action,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final token = (await _getToken()) ?? '';
      final resp = await api.resolveConflict(
        token: token,
        eventId: eventId,
        eventType: eventType,
        action: action,
      );

      final success = resp.statusCode >= 200 && resp.statusCode < 300;
      final body = resp.body.isNotEmpty ? json.decode(resp.body) : null;
      lastMessage = body is Map && body['message'] != null
          ? body['message']
          : (success ? 'OK' : 'Error');

      return success;
    } catch (e) {
      lastMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
