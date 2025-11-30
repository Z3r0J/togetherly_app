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

class EventDetailTabsView extends StatefulWidget {
  final UnifiedEvent event;

  const EventDetailTabsView({
    super.key,
    required this.event,
  });

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

    if (vm.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (vm.error != null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Event Details'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  vm.error!.message,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => vm.load(widget.event),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final unifiedEvent = widget.event;
    final circleDetail = vm.circleEvent;
    final personalDetail = vm.personalEvent;
    final baseLocation = unifiedEvent is CircleUnifiedEvent
        ? unifiedEvent.location
        : (unifiedEvent is PersonalUnifiedEvent
            ? unifiedEvent.location
            : null);
    final location = circleDetail?.location ?? personalDetail?.location ?? baseLocation;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Event Details',
          style: AppTextStyles.headlineSmall,
        ),
        centerTitle: false,
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: AppColors.textSecondary,
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
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_outlined,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${timeFormat.format((circleDetail?.startsAt ?? personalDetail?.startTime ?? unifiedEvent.startTime).toLocal())} - ${timeFormat.format((circleDetail?.endsAt ?? personalDetail?.endTime ?? unifiedEvent.endTime).toLocal())}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (location != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          location.name,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
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
                bottom: BorderSide(color: AppColors.border),
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
                  : const [
                      Tab(text: 'Details'),
                      Tab(text: 'Map'),
                    ],
            ),
          ),
          // Contenido de tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _isCircleEvent
                  ? [
                      _buildRsvpTab(circleDetail, unifiedEvent as CircleUnifiedEvent),
                      _buildTimePollTab(circleDetail),
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
                                personalDetail?.notes ?? circleDetail?.description,
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
    );
  }

  Widget _buildDescription(String? text) {
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: AppTextStyles.headlineSmall,
        ),
        const SizedBox(height: 12),
        Text(
          text,
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildRsvpTab(
    CircleEventDetail? detail,
    CircleUnifiedEvent fallback,
  ) {
    final attendees = detail?.rsvps ?? [];
    final conflict = fallback.hasConflict;
    final eventId = detail?.id ?? fallback.id;
    final vm = context.read<EventDetailViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your RSVP',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: 16),
          if (conflict) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Conflict Detected',
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You have another event at this time.',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Who's Coming section
          Text(
            'Who\'s Coming',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: vm.isActionLoading
                      ? null
                      : () => vm.updateRsvp(eventId, RsvpStatus.going),
                  child: const Text('Going'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: vm.isActionLoading
                      ? null
                      : () => vm.updateRsvp(eventId, RsvpStatus.maybe),
                  child: const Text('Maybe'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: vm.isActionLoading
                      ? null
                      : () => vm.updateRsvp(eventId, RsvpStatus.notGoing),
                  child: const Text('Not going'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (attendees.isEmpty)
            Text(
              'No RSVPs yet',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else
            Column(
              children: attendees
                  .map(
                    (a) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildAttendeeRow(
                        a.username ?? a.email ?? 'Miembro',
                        a.status,
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildTimePollTab(CircleEventDetail? detail) {
    final options = detail?.eventTimes ?? [];
    final eventId = detail?.id;
    final vm = context.read<EventDetailViewModel>();

    if (options.isEmpty) {
      return Center(
        child: Text(
          'No time options',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Time Poll',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: 12),
          Column(
            children: options
                .map(
                  (o) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildTimeOption(
                      o.startTime,
                      o.endTime,
                      o.voteCount,
                      onVote: eventId == null || vm.isActionLoading
                          ? null
                          : () => vm.voteTimeOption(eventId, o.id),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMapTab(LocationModel? location) {
    if (location == null) {
      return Center(
        child: Text(
          'Sin ubicación',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
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
                        position: LatLng(location.latitude!, location.longitude!),
                        infoWindow: InfoWindow(title: location.name),
                      ),
                    },
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                  )
                : Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      location.name,
                      style: AppTextStyles.bodyMedium,
                    ),
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
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Compartir'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openExternalMap(location),
                  icon: const Icon(Icons.directions_outlined),
                  label: const Text('Directions'),
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
    VoidCallback? onVote,
  }) {
    final timeFormat = DateFormat('h:mm a');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${timeFormat.format(start)} - ${timeFormat.format(end)}',
            style: AppTextStyles.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: onVote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: Text(
                  'Vote',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  const Icon(
                    Icons.how_to_vote_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$votes votos',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendeeRow(String name, RsvpStatus status) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.primary.withOpacity(0.15),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: AppTextStyles.bodyMedium,
          ),
        ),
        RsvpBadge(status: status),
      ],
    );
  }

  Future<void> _openExternalMap(LocationModel location) async {
    final hasCoords = location.latitude != null && location.longitude != null;
    final uri = hasCoords
        ? Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}')
        : Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location.name)}');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir mapas')),
        );
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
}
