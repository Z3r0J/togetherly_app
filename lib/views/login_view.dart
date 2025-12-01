import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/widgets.dart';
import '../widgets/magic_link_dialog.dart';
import '../viewmodels/auth_view_model.dart';
import '../l10n/app_localizations.dart';
import '../services/invitation_service.dart';
import 'dashboard_view.dart';
import 'register_view.dart';

class LoginView extends StatefulWidget {
  final Map<String, dynamic>? invitationContext;

  const LoginView({super.key, this.invitationContext});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  late final AppLocalizations l10n;

  @override
  void initState() {
    super.initState();
    l10n = AppLocalizations.instance;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasPendingInvitation = widget.invitationContext != null;
    final circleName = widget.invitationContext?['circleName'];
    final inviterName = widget.invitationContext?['inviterName'];

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Invitation banner if present
              if (hasPendingInvitation) ...[
                _buildInvitationBanner(circleName, inviterName),
                const SizedBox(height: 24),
              ],

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
                text: l10n.tr('auth.login.button.continue'),
                type: AppButtonType.primary,
                fullWidth: true,
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _handleLogin,
              ),

              const SizedBox(height: 16),

              const DividerWithText(text: 'o'),

              const SizedBox(height: 16),

              // Botón Magic Link
              AppButton(
                text: l10n.tr('auth.login.button.magic_link'),
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
          Icon(Icons.mail_outline, size: 48, color: AppColors.primary),
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
            'Inicia sesión para unirte',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
              l10n.tr('auth.login.title'),
              style: AppTextStyles.displaySmall.copyWith(fontSize: 32),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Tagline
        Text(
          l10n.tr('auth.login.subtitle'),
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
                  l10n.tr('auth.login.illustration_placeholder'),
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
      label: l10n.tr('auth.login.label.email'),
      hintText: l10n.tr('auth.login.hint.email'),
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      enabled: !_isLoading,
    );
  }

  Widget _buildPasswordField() {
    return AppTextField(
      label: l10n.tr('auth.login.label.password'),
      hintText: l10n.tr('auth.login.hint.password'),
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
          l10n.tr('auth.login.link.forgot_password'),
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
          l10n.tr('auth.login.link.no_account'),
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        GestureDetector(
          onTap: _isLoading ? null : _handleSignUp,
          child: Text(
            l10n.tr('auth.login.link.sign_up'),
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
      _showError(l10n.tr('auth.login.validation.email_required'));
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showError(l10n.tr('auth.login.validation.password_required'));
      return;
    }

    // Solo cambiamos el estado de loading una vez al inicio
    if (_isLoading) return; // Prevenir múltiples calls

    setState(() => _isLoading = true);

    final authViewModel = context.read<AuthViewModel>();

    final (success, errorMsg) = await authViewModel.login(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      bool navigated = false;
      try {
        // Check for pending invitation before navigating
        final invitationService = InvitationService();
        final invitationData = await invitationService.processPendingInvitation();

        if (invitationData != null) {
          // Successfully joined circle from invitation
          print(
            '✅ [LoginView] Processed pending invitation - Circle: ${invitationData.circleName}',
          );

          // Show success message
          _showSuccess('¡Te uniste a ${invitationData.circleName}!');

          // Navigate to dashboard (circles will be refreshed automatically)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardView()),
          );
          navigated = true;
        }
      } catch (e) {
        // Log and continue to dashboard even if invitation fails
        print('❌ [LoginView] Error processing pending invitation: $e');
      }

      if (!navigated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardView()),
        );
      }
    } else {
      // Mostrar error inmediatamente
      final error = errorMsg ?? l10n.tr('auth.login.error.generic');
      print('🔴 LoginView - Showing error: $error');
      _showError(error);
    }
  }

  Future<void> _handleMagicLink() async {
    // Show magic link dialog
    final authViewModel = context.read<AuthViewModel>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MagicLinkDialog(authViewModel: authViewModel),
    );
  }

  void _handleForgotPassword() {
    // Navegar a la pantalla de recuperación de contraseña
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.tr('auth.forgot_password.dialog_title')),
        content: Text(l10n.tr('auth.forgot_password.dialog_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.tr('common.button.cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccess(l10n.tr('auth.forgot_password.success'));
            },
            child: Text(l10n.tr('common.button.send')),
          ),
        ],
      ),
    );
  }

  void _handleSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            RegisterView(invitationContext: widget.invitationContext),
      ),
    );
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
}
