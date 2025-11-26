import 'package:flutter/material.dart';
import '../models/auth_models.dart';
import '../models/magic_link_models.dart';
import '../models/register_models.dart';
import '../models/api_error.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
  magicLinkSent,
  awaitingEmailConfirmation,
}

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthState _state = AuthState.initial;
  User? _currentUser;
  String? _errorMessage;

  AuthState get state => _state;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == AuthState.loading;
  bool get isAuthenticated => _state == AuthState.authenticated;

  // Login method - retorna (success, errorMessage)
  Future<(bool, String?)> login(String email, String password) async {
    try {
      // NO llamar _setState para loading - el view maneja su propio loading
      _errorMessage = null;

      final loginRequest = LoginRequest(email: email, password: password);

      final loginResponse = await _authService.login(loginRequest);

      if (loginResponse.success) {
        // Fetch user data after successful login
        _currentUser = await _authService.getUserData();
        _setState(AuthState.authenticated);
        return (true, null);
      } else {
        // NO llamar _setState ni notifyListeners - evita rebuild
        _state = AuthState.unauthenticated;
        final errorMsg = 'Login failed. Please try again.';
        print('🔴 AuthViewModel - Login failed: $errorMsg');
        return (false, errorMsg);
      }
    } catch (e) {
      // NO llamar _setState ni notifyListeners - evita rebuild
      _state = AuthState.unauthenticated;
      final errorMsg = _getErrorMessage(e);
      print('🔴 AuthViewModel - Login error caught: $errorMsg');
      print('🔴 AuthViewModel - Original error: $e');
      return (false, errorMsg);
    }
  }

  // Check if user is already logged in
  Future<void> checkAuthStatus() async {
    try {
      _setState(AuthState.loading);

      final isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn) {
        // Try to fetch user data
        _currentUser = await _authService.getUserData();
        _setState(AuthState.authenticated);
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      // If fetching user data fails, clear tokens and set unauthenticated
      await _authService.clearTokens();
      _setState(AuthState.unauthenticated);
    }
  }

  // Logout method
  Future<void> logout() async {
    try {
      await _authService.logout();
      _currentUser = null;
      _setState(AuthState.unauthenticated);
    } catch (e) {
      _errorMessage = 'Logout failed: ${e.toString()}';
      _setState(AuthState.error);
    }
  }

  // Refresh user data
  Future<void> refreshUserData() async {
    try {
      _currentUser = await _authService.getUserData();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to refresh user data: ${e.toString()}';
      notifyListeners();
    }
  }

  // Update local currentUser fields (mock update)
  Future<bool> updateProfile({String? name, String? email, String? avatarUrl}) async {
    try {
      if (_currentUser == null) return false;

      // In a real app this would call AuthService update endpoint.
      _currentUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        email: email ?? _currentUser!.email,
        avatarUrl: avatarUrl ?? _currentUser!.avatarUrl,
      );

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Send magic link to email
  Future<bool> sendMagicLink(String email) async {
    try {
      _setState(AuthState.loading);
      _errorMessage = null;

      final request = MagicLinkRequest(email: email);
      final response = await _authService.sendMagicLink(request);

      if (response.success) {
        _setState(AuthState.magicLinkSent);
        return true;
      } else {
        _errorMessage = 'No se pudo enviar el enlace mágico';
        _setState(AuthState.error);
        return false;
      }
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _setState(AuthState.error);
      return false;
    }
  }

  // Handle deep link authentication (when user clicks magic link)
  Future<bool> handleDeepLinkAuth(
    String accessToken,
    String refreshToken,
  ) async {
    try {
      _setState(AuthState.loading);
      _errorMessage = null;

      // Save tokens from deep link
      await _authService.saveMagicLinkTokens(accessToken, refreshToken);

      // Fetch user data using the new tokens
      _currentUser = await _authService.getUserData();

      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      await _authService.clearTokens();
      _setState(AuthState.error);
      return false;
    }
  }

  // Register new user
  Future<bool> register(String name, String email, String password) async {
    try {
      _setState(AuthState.loading);
      _errorMessage = null;

      final request = RegisterRequest(
        name: name,
        email: email,
        password: password,
      );
      final response = await _authService.register(request);

      if (response.success) {
        _setState(AuthState.awaitingEmailConfirmation);
        return true;
      } else {
        _errorMessage = 'No se pudo completar el registro';
        _setState(AuthState.error);
        return false;
      }
    } catch (e) {
      _errorMessage = _getRegisterErrorMessage(e);
      _setState(AuthState.error);
      return false;
    }
  }

  // Handle email verification deep link (when user clicks verification link)
  Future<bool> handleEmailVerification(
    String accessToken,
    String refreshToken,
  ) async {
    try {
      _setState(AuthState.loading);
      _errorMessage = null;

      // Save tokens from verification deep link
      await _authService.saveVerificationTokens(accessToken, refreshToken);

      // Fetch user data using the new tokens
      _currentUser = await _authService.getUserData();

      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      await _authService.clearTokens();
      _setState(AuthState.error);
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Helper method to set state
  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  // Helper method to get error message
  String _getErrorMessage(dynamic error) {
    final l10n = AppLocalizations.instance;

    // Si es un ApiError del backend, usar su errorCode para traducir
    if (error is ApiError) {
      // Para errores de validación, intentar mostrar el primer detalle
      if (error.errorCode == 'VALIDATION_FAILED' && error.details != null) {
        final details = error.details!;
        // Obtener el primer campo con error
        for (var entry in details.entries) {
          if (entry.value is List && (entry.value as List).isNotEmpty) {
            return (entry.value as List).first.toString();
          }
        }
      }
      return l10n.trError(error.errorCode);
    }

    // Fallback para errores que no son ApiError
    final errorString = error.toString();

    if (errorString.contains('SocketException') ||
        errorString.contains('Failed host lookup')) {
      return l10n.networkError;
    } else if (errorString.contains('TimeoutException')) {
      return l10n.timeoutError;
    } else {
      return l10n.unknownError;
    }
  }

  // Helper method to get register error message
  String _getRegisterErrorMessage(dynamic error) {
    final l10n = AppLocalizations.instance;

    // Si es un ApiError del backend, usar su errorCode para traducir
    if (error is ApiError) {
      // Para errores de validación, intentar mostrar el primer detalle
      if (error.errorCode == 'VALIDATION_FAILED' && error.details != null) {
        final details = error.details!;
        // Obtener el primer campo con error
        for (var entry in details.entries) {
          if (entry.value is List && (entry.value as List).isNotEmpty) {
            return (entry.value as List).first.toString();
          }
        }
      }
      return l10n.trError(error.errorCode);
    }

    // Fallback para errores que no son ApiError
    final errorString = error.toString();

    if (errorString.contains('SocketException') ||
        errorString.contains('Failed host lookup')) {
      return l10n.networkError;
    } else if (errorString.contains('TimeoutException')) {
      return l10n.timeoutError;
    } else {
      return l10n.unknownError;
    }
  }
}
