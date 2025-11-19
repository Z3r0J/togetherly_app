import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../viewmodels/auth_view_model.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/email_verification_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isStrongPassword(String password) {
    // At least 8 characters, 1 uppercase, 1 lowercase, 1 number, 1 special character
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password) &&
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
  }

  void _validateAndRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validate name
    if (name.isEmpty) {
      _showErrorDialog('Por favor, ingresa tu nombre');
      return;
    }

    // Validate email
    if (email.isEmpty) {
      _showErrorDialog('Por favor, ingresa tu correo electrónico');
      return;
    }

    if (!_isValidEmail(email)) {
      _showErrorDialog('Por favor, ingresa un correo electrónico válido');
      return;
    }

    // Validate password
    if (password.isEmpty) {
      _showErrorDialog('Por favor, ingresa una contraseña');
      return;
    }

    if (!_isStrongPassword(password)) {
      _showErrorDialog(
        'La contraseña debe tener al menos 8 caracteres, incluir mayúsculas, minúsculas, números y caracteres especiales',
      );
      return;
    }

    // Proceed with registration
    setState(() {
      _isLoading = true;
    });

    final authViewModel = context.read<AuthViewModel>();
    final success = await authViewModel.register(name, email, password);

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      // Show email verification dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => EmailVerificationDialog(email: email),
      );
    } else if (mounted) {
      // Show error message
      final errorMessage = authViewModel.errorMessage ?? 'Error al registrarse';
      _showErrorDialog(errorMessage);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleLogin() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Logo and title
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people,
                    size: 40,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Togetherly',
                    style: AppTextStyles.displayLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 32,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              // Heading
              Text(
                'Vamos a registrarte',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Display Name field
              Text(
                'Nombre para mostrar',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _nameController,
                hintText: 'Ingresa tu nombre',
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 20),
              // Email field
              Text(
                'Correo electrónico',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _emailController,
                hintText: 'Ingresa tu correo electrónico',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              // Password field
              Text(
                'Contraseña',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _passwordController,
                hintText: 'Crea una contraseña segura',
                obscureText: _obscurePassword,
                onSubmitted: (_) => _validateAndRegister(),
                suffixIcon: _obscurePassword ? Icons.visibility_off : Icons.visibility,
                onSuffixIconPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Mínimo 8 caracteres con mayúsculas, minúsculas, números y símbolos',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              // Register button
              AppButton(
                text: 'Crear cuenta',
                onPressed: _isLoading ? null : _validateAndRegister,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),
              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¿Ya tienes una cuenta? ',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: _handleLogin,
                    child: Text(
                      'Iniciar sesión',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
