import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../viewmodels/auth_view_model.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/email_verification_dialog.dart';
import '../services/invitation_service.dart';
import '../l10n/app_localizations.dart';
import 'login_view.dart';

class RegisterView extends StatefulWidget {
  final Map<String, dynamic>? invitationContext;

  const RegisterView({super.key, this.invitationContext});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  late final AppLocalizations l10n;

  @override
  void initState() {
    super.initState();
    l10n = AppLocalizations.instance;
    _prefillEmailFromInvitation();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _prefillEmailFromInvitation() async {
    // If there's invitation context with an invited email, pre-fill it
    final invitedEmail = widget.invitationContext?['invitedEmail'];
    if (invitedEmail != null && invitedEmail is String) {
      setState(() {
        _emailController.text = invitedEmail;
      });
      print(
        '📧 [RegisterView] Pre-filled email from invitation: $invitedEmail',
      );
    }
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
      _showErrorDialog(
        AppLocalizations.instance.tr('auth.register.validation.name_required'),
      );
      return;
    }

    // Validate email
    if (email.isEmpty) {
      _showErrorDialog(
        AppLocalizations.instance.tr('auth.register.validation.email_required'),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      _showErrorDialog(
        AppLocalizations.instance.tr('auth.register.validation.email_invalid'),
      );
      return;
    }

    // Validate password
    if (password.isEmpty) {
      _showErrorDialog(
        AppLocalizations.instance.tr(
          'auth.register.validation.password_required',
        ),
      );
      return;
    }

    if (!_isStrongPassword(password)) {
      _showErrorDialog(
        AppLocalizations.instance.tr('auth.register.validation.password_weak'),
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
      // Check for pending invitation
      final invitationService = InvitationService();
      final hasPendingInvitation = await invitationService
          .getPendingInvitation();

      if (hasPendingInvitation != null) {
        // User registered with invitation - show different message
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '¡Registro exitoso!',
                    style: AppTextStyles.headlineSmall,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hemos enviado un correo de verificación a:',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  email,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Después de verificar tu correo, podrás unirte al círculo.',
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              AppButton(
                text: 'Entendido',
                type: AppButtonType.primary,
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Return to login
                },
              ),
            ],
          ),
        );
      } else {
        // Normal registration - show email verification dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => EmailVerificationDialog(email: email),
        );
      }
    } else if (mounted) {
      // Show error message
      final errorMessage =
          authViewModel.errorMessage ??
          AppLocalizations.instance.tr('auth.register.error.generic');
      _showErrorDialog(errorMessage);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppLocalizations.instance.tr('common.error.title')),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.instance.tr('common.button.ok')),
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationBanner(String? circleName, String? inviterName) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.group_add, size: 48, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            '¡Has sido invitado!',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (circleName != null)
            Text(
              'Únete a "$circleName"',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          if (inviterName != null)
            Text(
              'Invitado por $inviterName',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 8),
          Text(
            'Regístrate con el email de la invitación',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleLogin() {
    // Navigate to login, passing invitation context if present
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            LoginView(invitationContext: widget.invitationContext),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPendingInvitation = widget.invitationContext != null;
    final circleName = widget.invitationContext?['circleName'];
    final inviterName = widget.invitationContext?['inviterName'];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Invitation banner if present
              if (hasPendingInvitation) ...[
                _buildInvitationBanner(circleName, inviterName),
                const SizedBox(height: 24),
              ],

              // Logo and title
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 40, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.instance.tr('auth.register.title'),
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
                AppLocalizations.instance.tr('auth.register.heading'),
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Display Name field
              Text(
                AppLocalizations.instance.tr('auth.register.label.name'),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _nameController,
                hintText: AppLocalizations.instance.tr(
                  'auth.register.hint.name',
                ),
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 20),
              // Email field
              Text(
                AppLocalizations.instance.tr('auth.register.label.email'),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _emailController,
                hintText: AppLocalizations.instance.tr(
                  'auth.register.hint.email',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              // Password field
              Text(
                AppLocalizations.instance.tr('auth.register.label.password'),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _passwordController,
                hintText: AppLocalizations.instance.tr(
                  'auth.register.hint.password',
                ),
                obscureText: _obscurePassword,
                onSubmitted: (_) => _validateAndRegister(),
                suffixIcon: _obscurePassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                onSuffixIconPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.instance.tr(
                  'auth.register.password_instruction',
                ),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              // Register button
              AppButton(
                text: AppLocalizations.instance.tr(
                  'auth.register.button.create',
                ),
                onPressed: _isLoading ? null : _validateAndRegister,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),
              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.instance.tr(
                      'auth.register.link.have_account',
                    ),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: _handleLogin,
                    child: Text(
                      AppLocalizations.instance.tr('auth.register.link.login'),
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
