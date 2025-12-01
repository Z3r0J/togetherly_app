import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/widgets.dart';
import '../viewmodels/auth_view_model.dart';
import 'edit_profile_view.dart';
import 'login_view.dart';

/// Profile & Settings screen — built reusing existing widgets
class ProfileSettingsView extends StatelessWidget {
  const ProfileSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final user = auth.currentUser;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Page header with back button
              const PageHeader(title: 'Profile & Settings'),

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
                        borderColor: Colors.white,
                      ),
                      // Edit badge
                      Positioned(
                        right: 0,
                        bottom: 6,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.edit,
                            size: 18,
                            color: AppColors.textOnPrimary,
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
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Edit profile pill
                  AppButton(
                    text: 'Edit Profile',
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
                          const SnackBar(
                            content: Text('Profile updated successfully'),
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
                title: 'Account',
                children: [
                  _buildOptionTile(
                    Icons.lock_outline,
                    'Change Password',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildOptionTile(
                    Icons.mail_outline,
                    'Email Preferences',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildOptionTile(Icons.language, 'Language', onTap: () {}),
                  _buildDivider(),
                  _buildOptionTile(Icons.schedule, 'Time Zone', onTap: () {}),
                ],
              ),

              const SizedBox(height: 12),

              // Collapsible sections (simplified as cards with chevron to match mock)
              _buildSectionCard(
                title: 'Notifications',
                children: [_buildChevronOnly()],
              ),
              const SizedBox(height: 12),
              _buildSectionCard(
                title: 'Calendar',
                children: [_buildChevronOnly()],
              ),
              const SizedBox(height: 12),
              _buildSectionCard(
                title: 'Privacy',
                children: [_buildChevronOnly()],
              ),
              const SizedBox(height: 12),
              _buildSectionCard(
                title: 'About',
                children: [_buildChevronOnly()],
              ),
              const SizedBox(height: 12),

              // Ver Tutorial/Onboarding
              _buildSectionCard(
                title: 'Tutorial',
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    leading: const Icon(
                      Icons.help_outline,
                      color: AppColors.primary,
                    ),
                    title: const Text('Ver Tutorial de Bienvenida'),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('hasSeenOnboarding');

                      if (!context.mounted) return;

                      // Reiniciar la app navegando a la raíz
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('/', (route) => false);
                    },
                  ),
                ],
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
                          'Danger Zone',
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
                              title: const Text('Confirm Log Out'),
                              content: const Text(
                                'Are you sure you want to log out?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('Log Out'),
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
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        child: Text(
                          'Log Out',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Delete account (text button red)
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Delete Account',
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

  Widget _buildOptionTile(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      leading: Icon(icon, color: AppColors.textTertiary),
      title: Text(title, style: AppTextStyles.bodyLarge),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 18,
        color: AppColors.textTertiary,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
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
    trailing: const Icon(Icons.expand_more),
  );
}
