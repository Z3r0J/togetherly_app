import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/widgets.dart';
import '../viewmodels/circle_view_model.dart';
import '../l10n/app_localizations.dart';
import 'invite_members_view.dart';
import 'create_event_view.dart';
import 'create_circle_view.dart';

class CircleDetailView extends StatefulWidget {
  final String circleId;
  final String circleName;
  final Color circleColor;

  const CircleDetailView({
    super.key,
    required this.circleId,
    required this.circleName,
    required this.circleColor,
  });

  @override
  State<CircleDetailView> createState() => _CircleDetailViewState();
}

class _CircleDetailViewState extends State<CircleDetailView> {
  late final AppLocalizations l10n;

  @override
  void initState() {
    super.initState();
    l10n = AppLocalizations.instance;
    // Fetch circle details on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CircleViewModel>().fetchCircleDetail(widget.circleId);
    });
  }

  @override
  void didUpdateWidget(covariant CircleDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refrescar cuando regresa de editar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CircleViewModel>().fetchCircleDetail(widget.circleId);
    });
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
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: widget.circleColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.circleName,
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            color: AppColors.textPrimary,
            onPressed: () {
              _showMoreOptions();
            },
          ),
        ],
      ),
      body: Consumer<CircleViewModel>(
        builder: (context, circleViewModel, child) {
          if (circleViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (circleViewModel.state == CircleState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    circleViewModel.errorMessage ??
                        l10n.tr('circle.message.load_failed'),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: l10n.tr('common.button.retry'),
                    type: AppButtonType.primary,
                    onPressed: () =>
                        circleViewModel.fetchCircleDetail(widget.circleId),
                  ),
                ],
              ),
            );
          }

          final circleDetail = circleViewModel.currentCircleDetail;
          if (circleDetail == null) {
            return Center(
              child: Text(
                l10n.tr('circle.error.CIRCLE_NOT_FOUND'),
                style: AppTextStyles.bodyMedium,
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sección de Miembros
                  _buildMembersSection(circleDetail),

                  const SizedBox(height: 4),

                  // Sección de Próximos Eventos
                  _buildUpcomingEventsSection(circleDetail),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMembersSection(circleDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado con título y botón Invitar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Miembros (${circleDetail.memberCount})',
                style: AppTextStyles.headlineSmall,
              ),
              if (circleDetail.canEdit)
                AppButton(
                  text: '+ Invitar',
                  type: AppButtonType.primary,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InviteMembersView(
                          circleId: widget.circleId,
                          circleName: widget.circleName,
                          circleColor: widget.circleColor,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Grid de avatares de miembros
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 8,
              childAspectRatio: 0.8,
            ),
            itemCount: circleDetail.members.length,
            itemBuilder: (context, index) {
              final member = circleDetail.members[index];
              return _buildMemberCard(member);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMemberCard(member) {
    final name = member.name;
    final role = member.role;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        UserAvatar(name: name, size: 64, backgroundColor: widget.circleColor),
        const SizedBox(height: 8),
        Flexible(
          child: Text(
            name.split(' ')[0],
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (role == 'owner')
          Flexible(
            child: Text(
              '(Propietario)',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textTertiary,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  Widget _buildUpcomingEventsSection(circleDetail) {
    final events = circleDetail.events;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado con título y botón Crear Evento
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Próximos Eventos', style: AppTextStyles.headlineSmall),
              if (circleDetail.canEdit)
                AppButton(
                  text: '+ Crear Evento',
                  type: AppButtonType.primary,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateEventView(
                          circleName: widget.circleName,
                          circleColor: widget.circleColor,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Lista de eventos
        if (events.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: Text(
                l10n.tr('dashboard.empty.no_events'),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: events.asMap().entries.map<Widget>((entry) {
                final event = entry.value;
                final isLastEvent = entry.key == events.length - 1;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLastEvent ? 0 : 16),
                  child: Text(
                    'Evento: $event',
                    style: AppTextStyles.bodyMedium,
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Consumer<CircleViewModel>(
        builder: (context, circleViewModel, child) {
          final circleDetail = circleViewModel.currentCircleDetail;

          return Container(
            color: AppColors.background,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Editar Círculo'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateCircleView.edit(
                            circleId: widget.circleId,
                            circleName: widget.circleName,
                            circleColor: widget.circleColor,
                            description: circleDetail?.description,
                            privacy: circleDetail?.privacy,
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete, color: AppColors.error),
                    title: const Text(
                      'Eliminar Círculo',
                      style: TextStyle(color: AppColors.error),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showDeleteConfirmation();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: const Text('Eliminar Círculo'),
        content: Text(
          '¿Estás seguro de que deseas eliminar este círculo? Esta acción no se puede deshacer.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _proceedWithDelete();
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _proceedWithDelete() async {
    print('🔵 [DELETE CIRCLE] Starting deletion from CircleDetailView');

    final circleViewModel = context.read<CircleViewModel>();
    final success = await circleViewModel.deleteCircle(widget.circleId);

    if (!mounted) return;

    if (success) {
      print('✅ [DELETE CIRCLE] Circle deleted successfully!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Círculo eliminado exitosamente!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          print('🔙 [DELETE CIRCLE] Navigating back to my circles');
          Navigator.pop(context);
        }
      });
    } else {
      print('❌ [DELETE CIRCLE] Circle deletion failed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            circleViewModel.errorMessage ??
                l10n.tr('circle.message.delete_failed'),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
