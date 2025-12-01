import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/unified_calendar_models.dart';
import '../models/circle_event_models.dart';
import '../models/location_models.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../viewmodels/event_detail_view_model.dart';
import '../widgets/rsvp_widgets.dart';
import '../l10n/app_localizations.dart';

class EventDetailTabsView extends StatefulWidget {
  final UnifiedEvent event;

  const EventDetailTabsView({super.key, required this.event});

  @override
  State<EventDetailTabsView> createState() => _EventDetailTabsViewState();
}

class _EventDetailTabsViewState extends State<EventDetailTabsView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late final bool _isCircleEvent;

  @override
  void initState() {
    super.initState();
    _isCircleEvent = widget.event is CircleUnifiedEvent;
    _tabController = TabController(length: _isCircleEvent ? 3 : 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventDetailViewModel>().load(widget.event);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EventDetailViewModel>();
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy', 'es_ES');
    final timeFormat = DateFormat('h:mm a');
    final circleDetail = vm.circleEvent;
    final permissions = circleDetail?.permissions;

    if (vm.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (vm.error != null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Event Details'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  vm.error!.message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => vm.load(widget.event),
                  child: Text(
                    AppLocalizations.instance.tr('common.button.retry'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final unifiedEvent = widget.event;
    final personalDetail = vm.personalEvent;
    final baseLocation = unifiedEvent is CircleUnifiedEvent
        ? unifiedEvent.location
        : (unifiedEvent is PersonalUnifiedEvent ? unifiedEvent.location : null);
    final location =
        circleDetail?.location ?? personalDetail?.location ?? baseLocation;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                circleDetail?.title ??
                    personalDetail?.title ??
                    unifiedEvent.title,
                style: AppTextStyles.headlineSmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_isCircleEvent && unifiedEvent is CircleUnifiedEvent) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  unifiedEvent.circleName,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        centerTitle: false,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            offset: const Offset(0, 45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) async {
              switch (value) {
                case 'edit':
                  _handleEditEvent();
                  break;
                case 'lock':
                  await _handleLockTimePoll();
                  break;
                case 'finalize':
                  await _handleFinalizeEvent();
                  break;
                case 'delete':
                  await _handleDeleteEvent();
                  break;
                case 'edit_personal':
                  _handleEditPersonalEvent();
                  break;
                case 'cancel_personal':
                  _handleCancelPersonalEvent();
                  break;
                case 'delete_personal':
                  await _handleDeletePersonalEvent();
                  break;
              }
            },
            itemBuilder: (context) {
              if (_isCircleEvent && permissions != null) {
                // Circle event menu
                final eventStatus = (unifiedEvent as CircleUnifiedEvent).status;

                return [
                  if (permissions.canEdit)
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20),
                          SizedBox(width: 12),
                          Text('Edit Event'),
                        ],
                      ),
                    ),
                  if (permissions.canLock && eventStatus != 'locked')
                    const PopupMenuItem(
                      value: 'lock',
                      child: Row(
                        children: [
                          Icon(Icons.lock_outline, size: 20),
                          SizedBox(width: 12),
                          Text('Lock Time Poll'),
                        ],
                      ),
                    ),
                  if (permissions.canLock && eventStatus == 'locked')
                    const PopupMenuItem(
                      value: 'finalize',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline, size: 20),
                          SizedBox(width: 12),
                          Text('Finalize Event'),
                        ],
                      ),
                    ),
                  if (permissions.canDelete)
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Delete',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                ];
              } else {
                // Personal event menu
                return [
                  const PopupMenuItem(
                    value: 'edit_personal',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 20),
                        SizedBox(width: 12),
                        Text('Edit Event'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'cancel_personal',
                    child: Row(
                      children: [
                        Icon(
                          Icons.cancel_outlined,
                          size: 20,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Cancel Event',
                          style: TextStyle(color: AppColors.warning),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete_personal',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Delete',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ];
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header con información básica
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  circleDetail?.title ??
                      personalDetail?.title ??
                      unifiedEvent.title,
                  style: AppTextStyles.headlineMedium,
                ),
                const SizedBox(height: 8),
                if ((personalDetail != null && personalDetail.cancelled) ||
                    (unifiedEvent is PersonalUnifiedEvent &&
                        unifiedEvent.cancelled))
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Cancelled',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateFormat.format(
                        (circleDetail?.startsAt ??
                                personalDetail?.startTime ??
                                unifiedEvent.startTime)
                            .toLocal(),
                      ),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_outlined,
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${timeFormat.format((circleDetail?.startsAt ?? personalDetail?.startTime ?? unifiedEvent.startTime).toLocal())} - ${timeFormat.format((circleDetail?.endsAt ?? personalDetail?.endTime ?? unifiedEvent.endTime).toLocal())}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (location != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          location.name,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Tabs
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: _isCircleEvent
                  ? const [
                      Tab(text: 'RSVP'),
                      Tab(text: 'Time Poll'),
                      Tab(text: 'Map'),
                    ]
                  : const [Tab(text: 'Details'), Tab(text: 'Map')],
            ),
          ),
          // Contenido de tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _isCircleEvent
                  ? [
                      _buildRsvpTab(
                        circleDetail,
                        unifiedEvent as CircleUnifiedEvent,
                      ),
                      _buildTimePollTab(
                        circleDetail,
                        unifiedEvent as CircleUnifiedEvent,
                      ),
                      _buildMapTab(location),
                    ]
                  : [
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDescription(
                                personalDetail?.notes ??
                                    circleDetail?.description,
                              ),
                            ],
                          ),
                        ),
                      ),
                      _buildMapTab(location),
                    ],
            ),
          ),
        ],
      ),
      floatingActionButton: null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildDescription(String? text) {
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Description', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 12),
        Text(text, style: AppTextStyles.bodyMedium),
      ],
    );
  }

  Widget _buildRsvpTab(CircleEventDetail? detail, CircleUnifiedEvent fallback) {
    final attendees = detail?.rsvps ?? [];
    final conflict = fallback.hasConflict;
    final eventId = detail?.id ?? fallback.id;
    final currentStatus = fallback.rsvpStatus;
    final vm = context.read<EventDetailViewModel>();
    final going = attendees.where((a) => a.status == RsvpStatus.going).toList();
    final maybe = attendees.where((a) => a.status == RsvpStatus.maybe).toList();
    final notGoing = attendees
        .where((a) => a.status == RsvpStatus.notGoing)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your RSVP', style: AppTextStyles.headlineSmall),
                const SizedBox(height: 12),
                if (conflict) ...[
                  _buildConflictCallout(fallback),
                  const SizedBox(height: 16),
                ],
                Text(
                  'Confirm your attendance',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildRsvpButton(
                      label: 'Going',
                      icon: Icons.check_circle_rounded,
                      color: const Color(0xFF2ECC71),
                      selected: currentStatus == RsvpStatus.going,
                      onTap: vm.isActionLoading
                          ? null
                          : () => vm.updateRsvp(eventId, RsvpStatus.going),
                    ),
                    const SizedBox(width: 8),
                    _buildRsvpButton(
                      label: 'Maybe',
                      icon: Icons.help_outline_rounded,
                      color: const Color(0xFFF2C94C),
                      selected: currentStatus == RsvpStatus.maybe,
                      onTap: vm.isActionLoading
                          ? null
                          : () => vm.updateRsvp(eventId, RsvpStatus.maybe),
                    ),
                    const SizedBox(width: 8),
                    _buildRsvpButton(
                      label: 'Not Going',
                      icon: Icons.cancel_rounded,
                      color: const Color(0xFFEB5757),
                      selected: currentStatus == RsvpStatus.notGoing,
                      onTap: vm.isActionLoading
                          ? null
                          : () => vm.updateRsvp(eventId, RsvpStatus.notGoing),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Who\'s Coming?', style: AppTextStyles.headlineSmall),
                const SizedBox(height: 12),
                if (attendees.isEmpty)
                  Text(
                    'No RSVPs yet',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  )
                else ...[
                  _buildAttendanceGroup(
                    'Going',
                    going,
                    const Color(0xFF2ECC71),
                  ),
                  const SizedBox(height: 12),
                  _buildAttendanceGroup(
                    'Maybe',
                    maybe,
                    const Color(0xFFF2C94C),
                  ),
                  const SizedBox(height: 12),
                  _buildAttendanceGroup(
                    'Not Going',
                    notGoing,
                    const Color(0xFFEB5757),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePollTab(
    CircleEventDetail? detail,
    CircleUnifiedEvent fallback,
  ) {
    final options = detail?.eventTimes ?? [];
    final eventId = detail?.id ?? fallback.id;
    final vm = context.read<EventDetailViewModel>();

    if (options.isEmpty) {
      return Center(
        child: Text(
          'No time options',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final maxVotes = options
        .map((o) => o.voteCount)
        .fold<int>(0, (prev, v) => v > prev ? v : prev);
    final totalVotes = options.fold<int>(0, (sum, o) => sum + o.voteCount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Time Poll', style: AppTextStyles.headlineSmall),
                Text(
                  totalVotes > 0 ? '$totalVotes votos' : 'Aún sin votos',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: options
                  .map(
                    (o) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _buildTimeOption(
                        o.startTime,
                        o.endTime,
                        o.voteCount,
                        maxVotes: maxVotes == 0 ? 1 : maxVotes,
                        onVote: eventId.isEmpty || vm.isActionLoading
                            ? null
                            : () => vm.voteTimeOption(eventId, o.id),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: eventId.isEmpty || vm.isActionLoading
                    ? null
                    : () => _showVoteSheet(context, options, eventId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Vote or Change Vote',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapTab(LocationModel? location) {
    if (location == null) {
      return Center(
        child: Text(
          'Sin ubicación',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final hasCoords = location.latitude != null && location.longitude != null;

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: hasCoords
                ? GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(location.latitude!, location.longitude!),
                      zoom: 14,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('event_location'),
                        position: LatLng(
                          location.latitude!,
                          location.longitude!,
                        ),
                        infoWindow: InfoWindow(title: location.name),
                      ),
                    },
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                  )
                : Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Text(location.name, style: AppTextStyles.bodyMedium),
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _shareLocation(location),
                  icon: Icon(Icons.share_outlined),
                  label: Text('Compartir'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openExternalMap(location),
                  icon: Icon(Icons.directions_outlined),
                  label: Text('Directions'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeOption(
    DateTime start,
    DateTime end,
    int votes, {
    required int maxVotes,
    VoidCallback? onVote,
  }) {
    final timeFormat = DateFormat('h:mm a');
    final progress = votes <= 0 || maxVotes <= 0 ? 0.05 : votes / maxVotes;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                timeFormat.format(start),
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$votes ${votes == 1 ? "vote" : "votes"}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress.clamp(0.05, 1.0),
              minHeight: 10,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.outline.withOpacity(0.5),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onVote,
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                padding: EdgeInsets.zero,
              ),
              child: Text(
                'Vote',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showVoteSheet(
    BuildContext context,
    List<CircleEventTimeOption> options,
    String eventId,
  ) async {
    final vm = context.read<EventDetailViewModel>();

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final timeFormat = DateFormat('h:mm a');
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Choose a time', style: AppTextStyles.titleMedium),
                const SizedBox(height: 8),
                ...options.map(
                  (o) => ListTile(
                    title: Text(
                      timeFormat.format(o.startTime),
                      style: AppTextStyles.bodyLarge,
                    ),
                    subtitle: Text(
                      '${o.voteCount} ${o.voteCount == 1 ? "vote" : "votes"}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onTap: vm.isActionLoading
                        ? null
                        : () {
                            Navigator.of(ctx).pop();
                            vm.voteTimeOption(eventId, o.id);
                          },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _buildConflictCallout(CircleUnifiedEvent fallback) {
    final conflictTitle = fallback.conflictsWith.isNotEmpty
        ? fallback.conflictsWith.first.title
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conflict Detected',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  conflictTitle != null
                      ? 'You have a conflict with “$conflictTitle”.'
                      : 'You have another event at this time.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRsvpButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool selected,
    required VoidCallback? onTap,
  }) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: selected ? Colors.white : color),
        label: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: selected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: selected ? color : color.withOpacity(0.12),
          foregroundColor: color,
          elevation: selected ? 0 : 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: color.withOpacity(0.4)),
        ),
      ),
    );
  }

  Widget _buildAttendanceGroup(
    String label,
    List<CircleEventRsvp> people,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              '$label (${people.length})',
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (people.isEmpty)
          Text(
            'No one here yet',
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: people
                .map(
                  (p) => _buildAvatarChip(
                    p.username ?? p.email ?? 'Member',
                    color,
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildAvatarChip(String name, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: color.withOpacity(0.25),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            name.split(' ').first,
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openExternalMap(LocationModel location) async {
    final hasCoords = location.latitude != null && location.longitude != null;
    final uri = hasCoords
        ? Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}',
          )
        : Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location.name)}',
          );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No se pudo abrir mapas')));
      }
    }
  }

  Future<void> _shareLocation(LocationModel location) async {
    final hasCoords = location.latitude != null && location.longitude != null;
    final link = hasCoords
        ? 'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}'
        : location.name;
    await Share.share(link, subject: location.name);
  }

  void _handleEditEvent() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Editar evento próximamente'),
        backgroundColor: AppColors.info,
      ),
    );
    // TODO: Navigate to edit event screen
  }

  Future<void> _handleLockTimePoll() async {
    final vm = context.read<EventDetailViewModel>();
    final circleDetail = vm.circleEvent;

    if (circleDetail == null || circleDetail.eventTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay opciones de tiempo para bloquear'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Find the option with most votes
    final sortedOptions = List<CircleEventTimeOption>.from(
      circleDetail.eventTimes,
    )..sort((a, b) => b.voteCount.compareTo(a.voteCount));
    final winningOption = sortedOptions.first;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bloquear votación'),
        content: Text(
          '¿Deseas bloquear la votación con la opción más votada?\n\n'
          '${DateFormat('EEEE, MMMM d', 'es_ES').format(winningOption.startTime)}\n'
          '${DateFormat('h:mm a').format(winningOption.startTime)} - '
          '${DateFormat('h:mm a').format(winningOption.endTime)}\n\n'
          'Votos: ${winningOption.voteCount}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: Text('Bloquear'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await vm.lockTimePoll(widget.event.id, winningOption.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? '¡Votación bloqueada exitosamente!'
                  : 'Error al bloquear votación',
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleFinalizeEvent() async {
    final vm = context.read<EventDetailViewModel>();
    final circleDetail = vm.circleEvent;

    if (circleDetail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se pudo cargar el detalle del evento'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Finalizar evento'),
        content: Text(
          '¿Deseas finalizar el evento y establecer el horario definitivo?\n\n'
          'El horario bloqueado se convertirá en el horario final del evento.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: Text('Finalizar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await vm.finalizeEvent(widget.event.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? '¡Evento finalizado exitosamente!'
                  : 'Error al finalizar evento',
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar evento'),
        content: Text(
          '¿Estás seguro de que deseas eliminar este evento? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final vm = context.read<EventDetailViewModel>();
      final success = await vm.deleteEvent(widget.event.id);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Evento eliminado exitosamente'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true); // Return true to refresh calendar
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(vm.error?.message ?? 'Error al eliminar evento'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _handleEditPersonalEvent() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Editar evento personal próximamente'),
        backgroundColor: AppColors.info,
      ),
    );
    // TODO: Navigate to edit personal event screen
  }

  void _handleCancelPersonalEvent() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cancelar evento personal próximamente'),
        backgroundColor: AppColors.info,
      ),
    );
    // TODO: Implement cancel personal event
  }

  Future<void> _handleDeletePersonalEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar evento'),
        content: Text(
          '¿Estás seguro de que deseas eliminar este evento personal?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Eliminar evento personal próximamente'),
          backgroundColor: AppColors.info,
        ),
      );
      // TODO: Implement delete personal event
    }
  }
}
