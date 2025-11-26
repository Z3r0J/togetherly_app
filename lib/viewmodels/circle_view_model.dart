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
  CircleDetail? _currentCircleDetail;
  String? _errorMessage;

  // Getters
  CircleState get state => _state;
  List<Circle> get circles => _circles;
  CircleDetail? get currentCircleDetail => _currentCircleDetail;
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

  // Create a new circle
  Future<bool> createCircle({
    required String name,
    required String description,
    required String color,
    required String privacy,
  }) async {
    try {
      print('🔵 [CircleViewModel] createCircle called');
      print('   Parameters:');
      print('   - name: $name');
      print('   - description: $description');
      print('   - color: $color');
      print('   - privacy: $privacy');

      _setState(CircleState.loading);
      _errorMessage = null;

      final request = CreateCircleRequest(
        name: name,
        description: description,
        color: color,
        privacy: privacy,
      );

      print('📤 [CircleViewModel] Sending request to CircleService...');
      final createResponse = await _circleService.createCircle(request);
      print('📥 [CircleViewModel] Response received from CircleService');
      print('   - success: ${createResponse.success}');
      print('   - timestamp: ${createResponse.timestamp}');

      if (createResponse.success) {
        print('✅ [CircleViewModel] Circle created successfully');
        print('   - Circle ID: ${createResponse.data.id}');
        print('   - Circle name: ${createResponse.data.name}');
        // Add the new circle to the list
        _circles.add(createResponse.data);
        _setState(CircleState.loaded);
        return true;
      } else {
        print('❌ [CircleViewModel] Circle creation failed (success=false)');
        _errorMessage = AppLocalizations.instance.tr(
          'circle.message.create_failed',
        );
        _setState(CircleState.error);
        return false;
      }
    } catch (e) {
      print('❌ [CircleViewModel] Exception caught during createCircle:');
      print('   - Exception type: ${e.runtimeType}');
      print('   - Exception message: $e');
      _errorMessage = _getErrorMessage(e);
      _setState(CircleState.error);
      return false;
    }
  }

  // Fetch circle details by ID
  Future<void> fetchCircleDetail(String circleId) async {
    try {
      _setState(CircleState.loading);
      _errorMessage = null;

      final circleDetailResponse = await _circleService.getCircleDetail(
        circleId,
      );

      if (circleDetailResponse.success) {
        _currentCircleDetail = circleDetailResponse.data;
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

  // Clear current circle detail
  void clearCircleDetail() {
    _currentCircleDetail = null;
    notifyListeners();
  }

  // Update circle
  Future<bool> updateCircle({
    required String circleId,
    required String name,
    required String description,
    required String color,
    required String privacy,
  }) async {
    try {
      print('🔵 [CircleViewModel] updateCircle called');
      print('   - Circle ID: $circleId');
      print('   - Name: $name');
      print('   - Description: $description');
      print('   - Color: $color');
      print('   - Privacy: $privacy');

      final request = UpdateCircleRequest(
        name: name,
        description: description,
        color: color,
        privacy: privacy,
      );

      print('📤 [CircleViewModel] Sending updateCircle request...');
      final updateResponse = await _circleService.updateCircle(
        circleId,
        request,
      );

      if (updateResponse.success) {
        print('✅ [CircleViewModel] Circle updated successfully!');
        // Refresh circle detail to get updated data
        await fetchCircleDetail(circleId);
        return true;
      } else {
        print(
          '❌ [CircleViewModel] updateCircle failed: ${updateResponse.error}',
        );
        _errorMessage = AppLocalizations.instance.tr(
          'circle.message.update_failed',
        );
        _setState(CircleState.error);
        return false;
      }
    } catch (e) {
      print('❌ [CircleViewModel] Exception caught during updateCircle:');
      print('   - Exception message: $e');
      _errorMessage = _getErrorMessage(e);
      _setState(CircleState.error);
      return false;
    }
  }

  // Delete circle
  Future<bool> deleteCircle(String circleId) async {
    try {
      print('🔵 [CircleViewModel] deleteCircle called');
      print('   - Circle ID: $circleId');

      print('📤 [CircleViewModel] Sending deleteCircle request...');
      final deleteResponse = await _circleService.deleteCircle(circleId);

      if (deleteResponse.success) {
        print('✅ [CircleViewModel] Circle deleted successfully!');
        // Refresh circles list
        await fetchCircles();
        _currentCircleDetail = null;
        return true;
      } else {
        print(
          '❌ [CircleViewModel] deleteCircle failed: ${deleteResponse.error}',
        );
        _errorMessage = AppLocalizations.instance.tr(
          'circle.message.delete_failed',
        );
        _setState(CircleState.error);
        return false;
      }
    } catch (e) {
      print('❌ [CircleViewModel] Exception caught during deleteCircle:');
      print('   - Exception message: $e');
      _errorMessage = _getErrorMessage(e);
      _setState(CircleState.error);
      return false;
    }
  }
}
