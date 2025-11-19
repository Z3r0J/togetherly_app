import 'package:flutter/foundation.dart';
import '../models/circle_models.dart';
import '../models/api_error.dart';
import '../services/circle_service.dart';
import '../l10n/app_localizations.dart';

enum CircleState { initial, loading, loaded, error }

class CircleViewModel extends ChangeNotifier {
  final CircleService _circleService = CircleService();

  // State management
  CircleState _state = CircleState.initial;
  List<Circle> _circles = [];
  String? _errorMessage;

  // Getters
  CircleState get state => _state;
  List<Circle> get circles => _circles;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == CircleState.loading;
  bool get hasCircles => _circles.isNotEmpty;

  // Private helper to update state and notify listeners
  void _setState(CircleState newState) {
    _state = newState;
    notifyListeners();
  }

  // Fetch circles from API
  Future<void> fetchCircles() async {
    try {
      _setState(CircleState.loading);
      _errorMessage = null;

      final circlesResponse = await _circleService.getCircles();

      if (circlesResponse.success) {
        _circles = circlesResponse.data.circles;
        _setState(CircleState.loaded);
      } else {
        _errorMessage = AppLocalizations.instance.tr(
          'circle.message.load_failed',
        );
        _setState(CircleState.error);
      }
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _setState(CircleState.error);
    }
  }

  // Helper to format error messages
  String _getErrorMessage(dynamic error) {
    final l10n = AppLocalizations.instance;

    if (error is ApiError) {
      // Try to get localized error message using trError
      return l10n.trError(error.errorCode);
    }

    // Fallback for generic errors
    if (error.toString().contains('Session expired')) {
      return l10n.tr('circle.message.session_expired');
    } else if (error.toString().contains('No access token')) {
      return l10n.tr('circle.message.auth_required');
    }

    return l10n.networkError;
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
