import 'package:flutter/material.dart';
import '../widgets/widgets.dart';

class InviteMembersView extends StatefulWidget {
  final String circleName;
  final Color circleColor;

  const InviteMembersView({
    super.key,
    required this.circleName,
    required this.circleColor,
  });

  @override
  State<InviteMembersView> createState() => _InviteMembersViewState();
}

class _InviteMembersViewState extends State<InviteMembersView> {
  final _emailController = TextEditingController();
  final List<String> _pendingInvites = [
    'alex@email.com',
    'jordan@email.com',
  ];
  final List<String> _joinedMembers = [
    'alex@email.com',
  ];
  final List<String> _sentInvites = [];

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: widget.circleColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Invitar a ${widget.circleName}',
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Share Link Section
            _buildShareLinkSection(),

            const SizedBox(height: 32),

            // Email Invitation Section
            _buildEmailInvitationSection(),

            const SizedBox(height: 32),

            // Pending Invites Section
            if (_pendingInvites.isNotEmpty) ...[
              _buildPendingInvitesSection(),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildShareLinkSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Compartir Enlace',
          style: AppTextStyles.headlineSmall,
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Link icon and URL
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.link,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'https://togetherly.app/join/abc123',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Copy Link and Share buttons
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Copiar Enlace',
                      type: AppButtonType.secondary,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Enlace copiado al portapapeles'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'Compartir',
                      type: AppButtonType.primary,
                      icon: Icons.share,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Abriendo opciones de compartir...'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmailInvitationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'O Escribir Email',
          style: AppTextStyles.headlineSmall,
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Correos Electrónicos',
          hintText: 'Ingresa direcciones de email...',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        AppButton(
          text: 'Enviar Invitación',
          type: AppButtonType.primary,
          fullWidth: true,
          onPressed: _handleSendInvite,
        ),
      ],
    );
  }

  Widget _buildPendingInvitesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Invitaciones Pendientes',
          style: AppTextStyles.headlineSmall,
        ),
        const SizedBox(height: 16),
        ..._pendingInvites.asMap().entries.map((entry) {
          final email = entry.value;
          final index = entry.key;
          final isLastItem = index == _pendingInvites.length - 1;

          return Padding(
            padding: EdgeInsets.only(bottom: isLastItem ? 0 : 12),
            child: _buildInviteItem(
              email: email,
              status: _joinedMembers.contains(email) ? 'Joined' : 'Pending',
              statusColor: _joinedMembers.contains(email)
                  ? AppColors.success
                  : AppColors.warning,
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildInviteItem({
    required String email,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            email,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          Row(
            children: [
              if (status == 'Joined')
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 18,
                )
              else
                Container(),
              const SizedBox(width: 6),
              Text(
                status == 'Joined' ? 'Unido ✓' : 'Pendiente',
                style: AppTextStyles.labelSmall.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleSendInvite() {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un email'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un email válido'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      if (!_pendingInvites.contains(email)) {
        _pendingInvites.add(email);
        _sentInvites.add(email);
      }
      _emailController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invitación enviada a $email'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
