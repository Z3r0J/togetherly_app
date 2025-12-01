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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Theme.of(context).colorScheme.onSurface,
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
            icon: Icon(Icons.more_vert),
            color: Theme.of(context).colorScheme.onSurface,
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
                l10n
                    .tr('circle.detail.members_count')
                    .replaceAll('{count}', '${circleDetail.memberCount}'),
                style: AppTextStyles.headlineSmall,
              ),
              // Todos los miembros pueden invitar, no sólo owner/admin
              SizedBox(
                height: 36,
                child: AppButton(
                  text: l10n.tr('circle.invite.button.invite'),
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
              l10n.tr('circle.detail.owner'),
              style: AppTextStyles.labelSmall.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withOpacity(0.6),
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
              Text(
                l10n.tr('circle.detail.upcoming_events'),
                style: AppTextStyles.headlineSmall,
              ),
              // Todos los miembros pueden crear eventos, no sólo owner/admin
              SizedBox(
                height: 36,
                child: AppButton(
                  text: l10n.tr('circle.create.button.create_short'),
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
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    final dateText = start != null
        ? _formatDate(start)
        : l10n.tr('event.detail.date_tbd');
    final timeText = event.allDay
        ? l10n.tr('event.detail.all_day')
        : (start != null && end != null)
        ? '${_formatTime(start)} - ${_formatTime(end)}'
        : l10n.tr('event.detail.time_tbd');
    final rsvpText =
        '${event.goingCount} ${l10n.tr('event.detail.rsvp.going')} · ${event.maybeCount} ${l10n.tr('event.detail.rsvp.maybe')} · ${event.notGoingCount} ${l10n.tr('event.detail.rsvp.not_going')}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
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
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(dateText, style: AppTextStyles.bodySmall),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(timeText, style: AppTextStyles.bodySmall),
            ],
          ),
          if (event.location != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                child: Text(
                  rsvpText,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                child: Text(l10n.tr('event.detail.button.view_details')),
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
    String translatedStatus;

    switch (status.toLowerCase()) {
      case 'finalized':
        translatedStatus = l10n.tr('event.detail.status.finalized');
        bg = AppColors.success.withOpacity(0.15);
        fg = AppColors.success;
        break;
      case 'locked':
        translatedStatus = l10n.tr('event.detail.status.locked');
        bg = AppColors.success.withOpacity(0.15);
        fg = AppColors.success;
        break;
      case 'draft':
        translatedStatus = l10n.tr('event.detail.status.draft');
        bg = AppColors.warning.withOpacity(0.15);
        fg = AppColors.warning;
        break;
      default:
        translatedStatus = status.toUpperCase();
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
        translatedStatus,
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
        label = l10n.tr('event.detail.rsvp.going_label');
        break;
      case RsvpStatus.maybe:
        bg = AppColors.warning.withOpacity(0.15);
        fg = AppColors.warning;
        label = l10n.tr('event.detail.rsvp.maybe_label');
        break;
      case RsvpStatus.notGoing:
        bg = AppColors.error.withOpacity(0.15);
        fg = AppColors.error;
        label = l10n.tr('event.detail.rsvp.not_going_label');
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
      l10n.tr('calendar.months.january'),
      l10n.tr('calendar.months.february'),
      l10n.tr('calendar.months.march'),
      l10n.tr('calendar.months.april'),
      l10n.tr('calendar.months.may'),
      l10n.tr('calendar.months.june'),
      l10n.tr('calendar.months.july'),
      l10n.tr('calendar.months.august'),
      l10n.tr('calendar.months.september'),
      l10n.tr('calendar.months.october'),
      l10n.tr('calendar.months.november'),
      l10n.tr('calendar.months.december'),
    ];
    final weekday = [
      l10n.tr('calendar.weekday_names.monday'),
      l10n.tr('calendar.weekday_names.tuesday'),
      l10n.tr('calendar.weekday_names.wednesday'),
      l10n.tr('calendar.weekday_names.thursday'),
      l10n.tr('calendar.weekday_names.friday'),
      l10n.tr('calendar.weekday_names.saturday'),
      l10n.tr('calendar.weekday_names.sunday'),
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
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.edit,
                      color: canEdit
                          ? AppColors.textPrimary
                          : Theme.of(context).colorScheme.outline,
                    ),
                    title: Text(
                      l10n.tr('circle.detail.edit_circle'),
                      style: TextStyle(
                        color: canEdit
                            ? AppColors.textPrimary
                            : Theme.of(context).colorScheme.outline,
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
                      color: canDelete
                          ? AppColors.error
                          : Theme.of(context).colorScheme.outline,
                    ),
                    title: Text(
                      l10n.tr('circle.detail.delete_circle'),
                      style: TextStyle(
                        color: canDelete
                            ? AppColors.error
                            : Theme.of(context).colorScheme.outline,
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
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        title: Text(l10n.tr('circle.create.dialog.delete_title')),
        content: Text(
          l10n.tr('circle.detail.delete_confirmation'),
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.tr('circle.create.dialog.cancel'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _proceedWithDelete();
            },
            child: Text(
              l10n.tr('circle.create.dialog.delete'),
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
        SnackBar(
          content: Text(l10n.tr('circle.detail.delete_success')),
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
