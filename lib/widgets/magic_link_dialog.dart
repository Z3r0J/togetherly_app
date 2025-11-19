import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../viewmodels/auth_view_model.dart';

/// Modal dialog for requesting a magic link authentication email
class MagicLinkDialog extends StatefulWidget {
  const MagicLinkDialog({super.key});

  @override
  State<MagicLinkDialog> createState() => _MagicLinkDialogState();
}

class _MagicLinkDialogState extends State<MagicLinkDialog> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendMagicLink() async {
    final email = _emailController.text.trim();

    // Client-side email validation
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor ingresa tu email';
      });
      return;
    }

    // Basic email format validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        _errorMessage = 'Por favor ingresa un email válido';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authViewModel = context.read<AuthViewModel>();
    final success = await authViewModel.sendMagicLink(email);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // Show success dialog
      Navigator.of(context).pop(); // Close magic link dialog
      _showSuccessDialog();
    } else {
      // Show error message
      setState(() {
        _errorMessage =
            authViewModel.errorMessage ?? 'Error al enviar el enlace';
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.mark_email_read, color: AppColors.success, size: 28),
            SizedBox(width: 12),
            Text('¡Enlace Enviado!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hemos enviado un enlace mágico a tu correo electrónico.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.info,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Haz clic en el enlace del email para iniciar sesión automáticamente.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '💡 El enlace expirará en 15 minutos',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          AppButton(
            text: 'Entendido',
            type: AppButtonType.primary,
            fullWidth: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.link,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Enlace Mágico', style: AppTextStyles.headlineSmall),
                      Text(
                        'Inicia sesión sin contraseña',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Description
            Text(
              'Te enviaremos un enlace especial a tu email. Solo haz clic en él para iniciar sesión automáticamente.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 24),

            // Email input
            AppTextField(
              label: 'Email',
              hintText: 'tu@email.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              enabled: !_isLoading,
              prefixIcon: Icons.email_outlined,
              suffixIcon: _emailController.text.isNotEmpty ? Icons.clear : null,
              onSuffixIconPressed: () {
                setState(() {
                  _emailController.clear();
                  _errorMessage = null;
                });
              },
              onChanged: (value) {
                if (_errorMessage != null) {
                  setState(() {
                    _errorMessage = null;
                  });
                }
              },
            ),

            // Error message
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Send button
            AppButton(
              text: 'Enviar Enlace Mágico',
              type: AppButtonType.primary,
              fullWidth: true,
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _handleSendMagicLink,
              icon: Icons.send,
            ),

            const SizedBox(height: 12),

            // Cancel button
            AppButton(
              text: 'Cancelar',
              type: AppButtonType.text,
              fullWidth: true,
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
