import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_view_model.dart';
import '../views/login_view.dart';

/// Helper widget to check authentication status on app start
class AuthWrapper extends StatefulWidget {
  final Widget authenticatedChild;
  final Widget? unauthenticatedChild;

  const AuthWrapper({
    super.key,
    required this.authenticatedChild,
    this.unauthenticatedChild,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Check authentication status when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthViewModel>().checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        // Show loading screen while checking auth status
        if (authViewModel.state == AuthState.initial ||
            authViewModel.state == AuthState.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Show authenticated screen if user is logged in
        if (authViewModel.isAuthenticated) {
          return widget.authenticatedChild;
        }

        // Show login screen if not authenticated
        return widget.unauthenticatedChild ?? const LoginView();
      },
    );
  }
}

/// Extension to easily access AuthViewModel from context
extension AuthViewModelExtension on BuildContext {
  AuthViewModel get auth => read<AuthViewModel>();
  AuthViewModel get authWatch => watch<AuthViewModel>();
}
