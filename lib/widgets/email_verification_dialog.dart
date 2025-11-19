import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../l10n/app_localizations.dart';

class EmailVerificationDialog extends StatelessWidget {
  final String email;

  const EmailVerificationDialog({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.email_outlined,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              AppLocalizations.instance.tr(
                'auth.email_verification.dialog_title',
              ),
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Message
            Text(
              AppLocalizations.instance.tr(
                'auth.email_verification.dialog_message',
              ),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              email,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.instance.tr(
                'auth.email_verification.dialog_instruction',
              ),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Close button
            AppButton(
              text: AppLocalizations.instance.tr('common.button.ok'),
              onPressed: () {
                // Close dialog and navigate back to login
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to login
              },
            ),
            const SizedBox(height: 12),
            // Info text
            Text(
              AppLocalizations.instance.tr(
                'auth.email_verification.info_expiry',
              ),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
