import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/widgets.dart';
import '../viewmodels/auth_view_model.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _avatarCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthViewModel>().currentUser;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _avatarCtrl = TextEditingController(text: user?.avatarUrl ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _avatarCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final authVm = context.read<AuthViewModel>();

    final ok = await authVm.updateProfile(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      avatarUrl: _avatarCtrl.text.trim().isEmpty ? null : _avatarCtrl.text.trim(),
    );

    setState(() => _isSaving = false);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update profile'), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthViewModel>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(title: 'Edit Profile'),
              const SizedBox(height: 16),

              Center(
                child: UserAvatar(
                  name: _nameCtrl.text.isNotEmpty ? _nameCtrl.text : (currentUser?.name ?? 'U'),
                  imageUrl: currentUser?.avatarUrl,
                  size: 110,
                  showBorder: true,
                  borderColor: Colors.white,
                ),
              ),

              const SizedBox(height: 18),

              AppTextField(label: 'Name', controller: _nameCtrl),
              const SizedBox(height: 12),
              AppTextField(label: 'Email', controller: _emailCtrl, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              AppTextField(label: 'Avatar URL', controller: _avatarCtrl, keyboardType: TextInputType.url),

              const SizedBox(height: 24),

              AppButton(
                text: 'Save',
                type: AppButtonType.primary,
                fullWidth: true,
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _save,
              ),

              const SizedBox(height: 12),
              AppButton(
                text: 'Cancel',
                type: AppButtonType.text,
                fullWidth: true,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
