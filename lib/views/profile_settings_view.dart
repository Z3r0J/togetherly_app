import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/widgets.dart';
import '../viewmodels/auth_view_model.dart';
import '../viewmodels/theme_viewmodel.dart';
import '../viewmodels/locale_viewmodel.dart';
import '../l10n/app_localizations.dart';
import 'edit_profile_view.dart';
import 'login_view.dart';

/// Profile & Settings screen — built reusing existing widgets
class ProfileSettingsView extends StatelessWidget {
  const ProfileSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.instance;
    final auth = context.watch<AuthViewModel>();
    final user = auth.currentUser;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Page header with back button
              PageHeader(title: l10n.tr('profile.title')),

              const SizedBox(height: 18),

              // Avatar + user info (from current auth)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      UserAvatar(
                        name: user?.name ?? 'User',
                        imageUrl: user?.avatarUrl,
                        size: 120,
                        showBorder: true,
                        borderColor: Theme.of(context).colorScheme.surface,
                      ),
                      // Edit badge
                      Positioned(
                        right: 0,
                        bottom: 6,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).shadowColor.withOpacity(0.12),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.edit,
                            size: 18,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? 'User',
                    style: AppTextStyles.headlineSmall.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    user?.email ?? '',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Edit profile pill
                  AppButton(
                    text: l10n.tr('profile.edit.title'),
                    type: AppButtonType.secondary,
                    fullWidth: true,
                    onPressed: () async {
                      final updated = await Navigator.push<bool?>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileView(),
                        ),
                      );

                      if (updated == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.tr('common.snackbar.profile_updated'),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Account card (rounded container with list tiles)
              _buildSectionCard(
                context,
                title: l10n.tr('profile.section.account'),
                children: [
                  _buildOptionTile(
                    context,
                    Icons.lock_outline,
                    l10n.tr('profile.option.change_password'),
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildOptionTile(
                    context,
                    Icons.mail_outline,
                    l10n.tr('profile.option.email_preferences'),
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildOptionTile(
                    context,
                    Icons.language,
                    l10n.tr('profile.option.language'),
                    onTap: () => _showLanguageDialog(context),
                  ),
                  _buildDivider(),
                  _buildOptionTile(
                    context,
                    Icons.brightness_6,
                    l10n.tr('profile.option.theme'),
                    onTap: () => _showThemeDialog(context),
                  ),
                  _buildDivider(),
                  _buildOptionTile(
                    context,
                    Icons.schedule,
                    l10n.tr('profile.option.time_zone'),
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Collapsible sections (simplified as cards with chevron to match mock)
              _buildSectionCard(
                context,
                title: l10n.tr('profile.section.notifications'),
                children: [_buildChevronOnly()],
              ),
              const SizedBox(height: 12),
              _buildSectionCard(
                context,
                title: l10n.tr('profile.section.calendar'),
                children: [_buildChevronOnly()],
              ),
              const SizedBox(height: 12),
              _buildSectionCard(
                context,
                title: l10n.tr('profile.section.privacy'),
                children: [_buildChevronOnly()],
              ),
              const SizedBox(height: 12),
              _buildSectionCard(
                context,
                title: l10n.tr('profile.section.about'),
                children: [_buildChevronOnly()],
              ),

              const SizedBox(height: 18),

              // Danger zone
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: AppColors.error.withOpacity(0.06),
                  border: Border.all(color: AppColors.error.withOpacity(0.25)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.tr('profile.section.danger_zone'),
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Log Out (outlined purple pill)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                          // Confirm then logout using AuthViewModel
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(
                                l10n.tr('dashboard.dialog.logout_title'),
                              ),
                              content: Text(
                                l10n.tr('dashboard.dialog.logout_message'),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text(l10n.tr('common.button.cancel')),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: Text(
                                    l10n.tr('profile.option.log_out'),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            final authVm = context.read<AuthViewModel>();
                            await authVm.logout();

                            if (!context.mounted) return;

                            // Clear navigation stack and go to login
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const LoginView(),
                              ),
                              (r) => false,
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        child: Text(
                          l10n.tr('profile.option.log_out'),
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Delete account (text button red)
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        l10n.tr('profile.option.delete_account'),
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() => const Divider(height: 1);

  Widget _buildOptionTile(
    BuildContext context,
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
      ),
      title: Text(title, style: AppTextStyles.bodyLarge),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 18,
        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
      ),
      onTap: onTap,
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Text(title, style: AppTextStyles.titleMedium),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildChevronOnly() => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
    title: const SizedBox.shrink(),
    trailing: Icon(Icons.expand_more),
  );

  void _showThemeDialog(BuildContext context) {
    final l10n = AppLocalizations.instance;
    final themeViewModel = context.read<ThemeViewModel>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.tr('profile.option.theme')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.tr('common.theme.system')),
              onTap: () {
                themeViewModel.setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(l10n.tr('common.theme.light')),
              onTap: () {
                themeViewModel.setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(l10n.tr('common.theme.dark')),
              onTap: () {
                themeViewModel.setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.instance;
    final localeViewModel = context.read<LocaleViewModel>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.tr('profile.option.language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.tr('common.language.system')),
              onTap: () {
                localeViewModel.setLocale(null);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Español'),
              onTap: () {
                localeViewModel.setLocale(const Locale('es'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('English'),
              onTap: () {
                localeViewModel.setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
