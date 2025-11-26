import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/widgets.dart';
import '../viewmodels/circle_view_model.dart';

class InviteMembersView extends StatefulWidget {
  final String circleId;
  final String circleName;
  final Color circleColor;

  const InviteMembersView({
    super.key,
    required this.circleId,
    required this.circleName,
    required this.circleColor,
  });

  @override
  State<InviteMembersView> createState() => _InviteMembersViewState();
}

class _InviteMembersViewState extends State<InviteMembersView> {
  final _emailController = TextEditingController();
  final List<String> _sentInvites = [];
  bool _isLoading = false;

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

            // Sent Invites Section
            if (_sentInvites.isNotEmpty) ...[
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
        Text('Compartir Enlace', style: AppTextStyles.headlineSmall),
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
                      'https://togetherly.app/join/${widget.circleId}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
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
                      onPressed: _handleCopyLink,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'Compartir',
                      type: AppButtonType.primary,
                      icon: Icons.share,
                      onPressed: _handleShareLink,
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
        Text('O Escribir Email', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Correos Electrónicos',
          hintText: 'Ingresa direcciones de email...',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        AppButton(
          text: _isLoading ? 'Enviando...' : 'Enviar Invitación',
          type: AppButtonType.primary,
          fullWidth: true,
          onPressed: _isLoading ? null : _handleSendInvite,
        ),
      ],
    );
  }

  Widget _buildPendingInvitesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Invitaciones Enviadas', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 16),
        ..._sentInvites.asMap().entries.map((entry) {
          final email = entry.value;
          final index = entry.key;
          final isLastItem = index == _sentInvites.length - 1;

          return Padding(
            padding: EdgeInsets.only(bottom: isLastItem ? 0 : 12),
            child: _buildInviteItem(
              email: email,
              status: 'Pending',
              statusColor: AppColors.warning,
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

  Future<void> _handleSendInvite() async {
    final email = _emailController.text.trim();

    // Validate email
    if (email.isEmpty) {
      _showSnackBar('Por favor ingresa un email', AppColors.error);
      return;
    }

    if (!_isValidEmail(email)) {
      _showSnackBar('Por favor ingresa un email válido', AppColors.error);
      return;
    }

    if (_sentInvites.contains(email)) {
      _showSnackBar(
        'Ya enviaste una invitación a este email',
        AppColors.warning,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final circleViewModel = context.read<CircleViewModel>();
      final response = await circleViewModel.sendInvitation(widget.circleId, [
        email,
      ]);

      if (response != null) {
        // Check for success and failures
        if (response.data.success.isNotEmpty) {
          setState(() {
            _sentInvites.addAll(response.data.success);
            _emailController.clear();
          });

          _showSnackBar(
            'Invitación enviada a ${response.data.success.join(", ")}',
            AppColors.success,
          );
        }

        if (response.data.failed.isNotEmpty) {
          final failures = response.data.failed;
          for (var failure in failures) {
            _showSnackBar(
              '${failure['email']}: ${failure['reason']}',
              AppColors.error,
            );
          }
        }
      } else {
        _showSnackBar('Error al enviar invitación', AppColors.error);
      }
    } catch (e) {
      _showSnackBar('Error al enviar invitación: $e', AppColors.error);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleCopyLink() {
    final link = 'https://togetherly.app/join/${widget.circleId}';
    Clipboard.setData(ClipboardData(text: link));
    _showSnackBar('Enlace copiado al portapapeles', AppColors.success);
  }

  void _handleShareLink() {
    // TODO: Implement share functionality using share_plus package
    _showSnackBar('Abriendo opciones de compartir...', AppColors.primary);
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
