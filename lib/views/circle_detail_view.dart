import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/widgets.dart';
import '../widgets/rsvp_widgets.dart';
import '../models/circle_models.dart';
import '../models/unified_calendar_models.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../viewmodels/circle_view_model.dart';
import '../viewmodels/unified_calendar_view_model.dart';
import '../viewmodels/event_detail_view_model.dart';
import '../l10n/app_localizations.dart';
import 'invite_members_view.dart';
import 'create_event_view.dart';
import 'create_circle_view.dart';
import 'event_detail_tabs_view.dart';

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
              // Todos los miembros pueden invitar, no sólo owner/admin
              SizedBox(
                height: 36,
                child: AppButton(
                  text: '+ Invitar',
                  type: AppButtonType.primary,
                  size: AppButtonSize.small,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InviteMembersView(
                          circleId: widget.circleId,
                          circleName: widget.circleName,
                          circleColor: widget.circleColor,
                          shareToken: circleDetail.shareToken,
                        ),
                      ),
                    );
                  },
                ),
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
    final events = circleDetail.events as List<CircleDetailEvent>;

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
              // Todos los miembros pueden crear eventos, no sólo owner/admin
              SizedBox(
                height: 36,
                child: AppButton(
                  text: '+ Crear Evento',
                  type: AppButtonType.primary,
                  size: AppButtonSize.small,
                  onPressed: () async {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateEventView(
                          circleId: widget.circleId,
                          circleName: widget.circleName,
                          circleColor: widget.circleColor,
                        ),
                      ),
                    );
                    if (result == true && mounted) {
                      await context.read<CircleViewModel>().fetchCircleDetail(
                        widget.circleId,
                      );
                      await context
                          .read<UnifiedCalendarViewModel>()
                          .loadCurrentMonth();
                    }
                  },
                ),
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
                  child: _buildEventCard(event),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildEventCard(CircleDetailEvent event) {
    final firstOption = event.eventTimes.isNotEmpty
        ? event.eventTimes.first
        : null;
    final start = event.startsAt ?? firstOption?.startTime;
    final end = event.endsAt ?? firstOption?.endTime;
    final dateText = start != null ? _formatDate(start) : 'Fecha por definir';
    final timeText = event.allDay
        ? 'Todo el día'
        : (start != null && end != null)
        ? '${_formatTime(start)} - ${_formatTime(end)}'
        : 'Horario por definir';
    final rsvpText =
        '${event.goingCount} Going · ${event.maybeCount} Maybe · ${event.notGoingCount} Not going';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: AppTextStyles.headlineSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildStatusChip(event.status),
                  _buildRsvpChip(event.rsvpStatus),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(dateText, style: AppTextStyles.bodySmall),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(timeText, style: AppTextStyles.bodySmall),
            ],
          ),
          if (event.location != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    event.location!.name,
                    style: AppTextStyles.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  rsvpText,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  final startSafe = start ?? DateTime.now();
                  final endSafe =
                      end ??
                      (start != null
                          ? start.add(const Duration(hours: 1))
                          : startSafe.add(const Duration(hours: 1)));
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider(
                        create: (_) => EventDetailViewModel(),
                        child: EventDetailTabsView(
                          event: CircleUnifiedEvent(
                            id: event.id,
                            title: event.title,
                            circleId: event.circleId,
                            circleName: widget.circleName,
                            circleColor:
                                '#${widget.circleColor.value.toRadixString(16).substring(2)}',
                            startTime: startSafe,
                            endTime: endSafe,
                            allDay: event.allDay,
                            conflictsWith: const [],
                            status: event.status,
                            rsvpStatus: RsvpStatusExtension.fromString(
                              event.rsvpStatus,
                            ),
                            attendeeCount:
                                event.goingCount +
                                event.maybeCount +
                                event.notGoingCount,
                            canChangeRsvp: true,
                            isCreator: false,
                            location: event.location,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('Ver detalles'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bg = AppColors.background;
    Color fg = AppColors.textPrimary;
    switch (status.toLowerCase()) {
      case 'finalized':
      case 'locked':
        bg = AppColors.success.withOpacity(0.15);
        fg = AppColors.success;
        break;
      case 'draft':
      default:
        bg = AppColors.warning.withOpacity(0.15);
        fg = AppColors.warning;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildRsvpChip(String? rsvp) {
    if (rsvp == null || rsvp.isEmpty) {
      return const SizedBox.shrink();
    }

    final status = RsvpStatusExtension.fromString(rsvp);
    Color bg = AppColors.background;
    Color fg = AppColors.textSecondary;
    String label = 'RSVP';

    switch (status) {
      case RsvpStatus.going:
        bg = AppColors.success.withOpacity(0.15);
        fg = AppColors.success;
        label = 'Voy';
        break;
      case RsvpStatus.maybe:
        bg = AppColors.warning.withOpacity(0.15);
        fg = AppColors.warning;
        label = 'Tal vez';
        break;
      case RsvpStatus.notGoing:
        bg = AppColors.error.withOpacity(0.15);
        fg = AppColors.error;
        label = 'No voy';
        break;
      case RsvpStatus.none:
        return const SizedBox.shrink();
      case null:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _formatDate(DateTime date) {
    final months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    final weekday = [
      'lunes',
      'martes',
      'miércoles',
      'jueves',
      'viernes',
      'sábado',
      'domingo',
    ][date.weekday - 1];
    return '$weekday, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Consumer<CircleViewModel>(
        builder: (context, circleViewModel, child) {
          final circleDetail = circleViewModel.currentCircleDetail;
          final canEdit = circleDetail?.canEdit ?? false;
          final canDelete = circleDetail?.canDelete ?? false;

          return Container(
            color: AppColors.background,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.edit,
                      color: canEdit ? AppColors.textPrimary : AppColors.border,
                    ),
                    title: Text(
                      'Editar Círculo',
                      style: TextStyle(
                        color: canEdit
                            ? AppColors.textPrimary
                            : AppColors.border,
                      ),
                    ),
                    enabled: canEdit,
                    onTap: canEdit
                        ? () {
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
                          }
                        : null,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.delete,
                      color: canDelete ? AppColors.error : AppColors.border,
                    ),
                    title: Text(
                      'Eliminar Círculo',
                      style: TextStyle(
                        color: canDelete ? AppColors.error : AppColors.border,
                      ),
                    ),
                    enabled: canDelete,
                    onTap: canDelete
                        ? () {
                            Navigator.pop(context);
                            _showDeleteConfirmation();
                          }
                        : null,
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
