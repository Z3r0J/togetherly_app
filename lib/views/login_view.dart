import 'package:flutter/material.dart';
import '../widgets/widgets.dart';
import '../main.dart';

/// Pantalla de Login de Togetherly
///
/// Implementa la interfaz de login con email/password
/// y opción de magic link
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Logo y título
              _buildHeader(),

              const SizedBox(height: 32),

              // Ilustración
              _buildIllustration(),

              const SizedBox(height: 48),

              // Campos de formulario
              _buildEmailField(),

              const SizedBox(height: 16),

              _buildPasswordField(),

              const SizedBox(height: 8),

              _buildForgotPassword(),

              const SizedBox(height: 24),

              // Botón principal
              AppButton(
                text: 'Continue with Email',
                type: AppButtonType.primary,
                fullWidth: true,
                isLoading: _isLoading,
                onPressed: _handleLogin,
              ),

              const SizedBox(height: 16),

              const DividerWithText(text: 'or'),

              const SizedBox(height: 16),

              // Botón Magic Link
              AppButton(
                text: 'Send me a Magic Link',
                type: AppButtonType.outline,
                fullWidth: true,
                onPressed: _handleMagicLink,
              ),

              const SizedBox(height: 24),

              // Link a Sign Up
              _buildSignUpLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups, size: 40, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(
              'Togetherly',
              style: AppTextStyles.displaySmall.copyWith(fontSize: 32),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Tagline
        Text(
          'Plan life together',
          style: AppTextStyles.titleLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildIllustration() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFF9E1CF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Image.asset(
        'assets/images/calendar_illustration.png',
        height: 200,
        errorBuilder: (context, error, stackTrace) {
          // Placeholder en caso de que no exista la imagen
          return Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 80,
                  color: AppColors.primary.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'Plan together',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmailField() {
    return AppTextField(
      label: 'Email',
      hintText: 'Enter your email address',
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      enabled: !_isLoading,
    );
  }

  Widget _buildPasswordField() {
    return AppTextField(
      label: 'Password',
      hintText: 'Enter your password',
      controller: _passwordController,
      obscureText: _obscurePassword,
      enabled: !_isLoading,
      suffixIcon: _obscurePassword ? Icons.visibility_off : Icons.visibility,
      onSuffixIconPressed: () {
        setState(() => _obscurePassword = !_obscurePassword);
      },
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _isLoading ? null : _handleForgotPassword,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        child: Text(
          'Forgot Password?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account? ',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        GestureDetector(
          onTap: _isLoading ? null : _handleSignUp,
          child: Text(
            'Sign up',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    // Validación básica
    if (_emailController.text.isEmpty) {
      _showError('Please enter your email');
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showError('Please enter your password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Aquí iría la llamada al servicio de autenticación
      await Future.delayed(const Duration(seconds: 2)); // Simulación

      if (!mounted) return;

      // Navegar a la pantalla principal
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      _showError('Invalid email or password');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleMagicLink() async {
    if (_emailController.text.isEmpty) {
      _showError('Please enter your email');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Aquí iría la llamada al servicio de magic link
      await Future.delayed(const Duration(seconds: 2)); // Simulación

      if (!mounted) return;

      _showSuccess('Magic link sent! Check your email.');
    } catch (e) {
      _showError('Failed to send magic link');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleForgotPassword() {
    // Navegar a la pantalla de recuperación de contraseña
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: const Text(
          'Enter your email address and we\'ll send you a link to reset your password.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccess('Password reset link sent!');
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _handleSignUp() {
    // Navegar a la pantalla de registro
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => const SignUpView()),
    // );

    _showInfo('Navigate to Sign Up screen');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
