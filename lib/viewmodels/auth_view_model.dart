import 'package:flutter/material.dart';
import '../models/auth_models.dart';
import '../models/magic_link_models.dart';
import '../models/register_models.dart';
import '../services/auth_service.dart';

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

  // Login method
  Future<bool> login(String email, String password) async {
    try {
      _setState(AuthState.loading);
      _errorMessage = null;

      final loginRequest = LoginRequest(email: email, password: password);

      final loginResponse = await _authService.login(loginRequest);

      if (loginResponse.success) {
        // Fetch user data after successful login
        _currentUser = await _authService.getUserData();
        _setState(AuthState.authenticated);
        return true;
      } else {
        _errorMessage = 'Login failed. Please try again.';
        _setState(AuthState.error);
        return false;
      }
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _setState(AuthState.error);
      return false;
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
    final errorString = error.toString();

    if (errorString.contains('SocketException') ||
        errorString.contains('Failed host lookup')) {
      return 'No se pudo conectar al servidor. Verifica tu conexión.';
    } else if (errorString.contains('401') ||
        errorString.contains('Unauthorized')) {
      return 'Credenciales inválidas. Por favor, intenta de nuevo.';
    } else if (errorString.contains('Session expired')) {
      return 'Tu sesión ha expirado. Por favor, inicia sesión de nuevo.';
    } else if (errorString.contains('TimeoutException')) {
      return 'La solicitud tardó demasiado. Por favor, intenta de nuevo.';
    } else {
      return 'Error al iniciar sesión. Por favor, intenta de nuevo.';
    }
  }

  // Helper method to get register error message
  String _getRegisterErrorMessage(dynamic error) {
    final errorString = error.toString();

    if (errorString.contains('SocketException') ||
        errorString.contains('Failed host lookup')) {
      return 'No se pudo conectar al servidor. Verifica tu conexión.';
    } else if (errorString.contains('User already exists') ||
        errorString.contains('Email already in use')) {
      return 'Este correo electrónico ya está registrado. Por favor, inicia sesión.';
    } else if (errorString.contains('400')) {
      return 'Datos inválidos. Por favor, verifica la información.';
    } else if (errorString.contains('TimeoutException')) {
      return 'La solicitud tardó demasiado. Por favor, intenta de nuevo.';
    } else {
      return 'Error al registrarse. Por favor, intenta de nuevo.';
    }
  }
}
