import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/unified_calendar_models.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCircleEvent = widget.event is CircleUnifiedEvent;
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy', 'es_ES');
    final timeFormat = DateFormat('h:mm a');

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
                  widget.event.title,
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
                      dateFormat.format(widget.event.startTime),
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
                      '${timeFormat.format(widget.event.startTime)} - ${timeFormat.format(widget.event.endTime)}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (widget.event.location != null) ...[
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
                          widget.event.location!.name,
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
          if (isCircleEvent)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.border),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'RSVP'),
                  Tab(text: 'Time Poll'),
                  Tab(text: 'Map'),
                ],
              ),
            ),
          // Contenido de tabs
          Expanded(
            child: isCircleEvent
                ? TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRsvpTab(widget.event as CircleUnifiedEvent),
                      _buildTimePollTab(widget.event as CircleUnifiedEvent),
                      _buildMapTab(),
                    ],
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.event.description != null)
                            Text(
                              'Description',
                              style: AppTextStyles.headlineSmall,
                            ),
                          if (widget.event.description != null)
                            const SizedBox(height: 12),
                          if (widget.event.description != null)
                            Text(
                              widget.event.description!,
                              style: AppTextStyles.bodyMedium,
                            ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRsvpTab(CircleUnifiedEvent event) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Your RSVP section
          Text(
            'Your RSVP',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: 16),
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
                  'You have another event at this time. Your RSVP status may have been automatically set to Not Going.',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: Text(
                          'Resolve Conflict',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        child: Text(
                          'Change RSVP',
                          style: AppTextStyles.labelMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Who's Coming section
          Text(
            'Who\'s Coming?',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: 16),
          // Going
          _buildRsvpGroup(
            'Going',
            '(1)',
            AppColors.primary,
            isExpanded: true,
          ),
          const SizedBox(height: 16),
          // Maybe
          _buildRsvpGroup(
            'Maybe',
            '(2)',
            AppColors.warning,
          ),
          const SizedBox(height: 16),
          // Not Going
          _buildRsvpGroup(
            'Not Going',
            '(1)',
            AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildRsvpGroup(
    String status,
    String count,
    Color color, {
    bool isExpanded = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$status $count',
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (isExpanded)
          Row(
            children: [
              _buildAvatarPlaceholder('A'),
              const SizedBox(width: 8),
              _buildAvatarPlaceholder('B'),
              const SizedBox(width: 8),
              _buildAvatarPlaceholder('+1'),
            ],
          ),
      ],
    );
  }

  Widget _buildAvatarPlaceholder(String initial) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTimePollTab(CircleUnifiedEvent event) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Time Poll',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildPollOption('10:00 AM', 3),
          const SizedBox(height: 12),
          _buildPollOption('11:00 AM', 5, isSelected: true),
          const SizedBox(height: 12),
          _buildPollOption('12:00 PM', 1),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text(
                'Vote or Change Vote',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textOnPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Time Confirmed: 11:00 AM\nYesterday by Alex',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPollOption(String time, int votes, {bool isSelected = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              time,
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$votes votes',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: votes / 10,
            minHeight: 8,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(
              isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: 300,
              color: AppColors.border,
              child: Center(
                child: Text(
                  'Map Placeholder',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (widget.event.location != null) ...[
            Text(
              widget.event.location!.name,
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Coordinates: ${widget.event.location!.latitude}, ${widget.event.location!.longitude}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('View Full Map'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.directions_outlined),
                    label: const Text('Get Directions'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
