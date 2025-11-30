import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/unified_calendar_models.dart';

class ResolveConflictView extends StatelessWidget {
  final UnifiedEvent event;
  final List<UnifiedEventConflict> conflicts;

  const ResolveConflictView({
    super.key,
    required this.event,
    required this.conflicts,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Drag Bar
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Resolve Schedule Conflict',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'You have ${conflicts.length} overlapping event${conflicts.length == 1 ? '' : 's'}:',
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),

              const SizedBox(height: 25),

              // Current event (the one we're resolving)
              Builder(
                builder: (context) {
                  // Compute location string safely using casts
                  String locationStr = '';
                  if (event is PersonalUnifiedEvent) {
                    final e = event as PersonalUnifiedEvent;
                    locationStr = e.location?.name ?? '';
                  } else if (event is CircleUnifiedEvent) {
                    final e = event as CircleUnifiedEvent;
                    locationStr = e.circleName;
                  }

                  return _eventCard(
                    title: event.title,
                    type: event is PersonalUnifiedEvent
                        ? 'Personal Event'
                        : 'Circle Event',
                    icon: event is PersonalUnifiedEvent
                        ? Icons.calendar_today
                        : Icons.group,
                    date: _formatRange(event.startTime, event.endTime),
                    location: locationStr,
                    actions: [_redButton('Cancel This Event')],
                    sideColor: Colors.grey,
                  );
                },
              ),

              const SizedBox(height: 16),

              // First conflicting event
              if (conflicts.isNotEmpty)
                _eventCard(
                  title: conflicts.first.title,
                  type: conflicts.first.type == UnifiedEventType.personal
                      ? 'Personal Event'
                      : 'Circle Event',
                  icon: conflicts.first.type == UnifiedEventType.personal
                      ? Icons.calendar_today
                      : Icons.group,
                  date: _formatRange(
                    conflicts.first.startTime,
                    conflicts.first.endTime,
                  ),
                  location: '',
                  rsvpTag: null,
                  rsvpColor: null,
                  actions: [
                    _outlineButton('Change to Maybe'),
                    const SizedBox(width: 10),
                    _blueButton('Change to Going'),
                  ],
                  sideColor: Colors.blue,
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('No conflicting events found.'),
                ),

              const SizedBox(height: 25),

              // Keep both
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade400),
                    color: Colors.white,
                  ),
                  child: const Text(
                    "Keep Both As-Is",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // View both in calendar
              Center(
                child: Text(
                  "View Both in Calendar",
                  style: TextStyle(fontSize: 16, color: Colors.blue.shade700),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRange(DateTime start, DateTime end) {
    final timeFormat = DateFormat('h:mm a');
    return '${timeFormat.format(start.toLocal())} - ${timeFormat.format(end.toLocal())}';
  }

  Widget _eventCard({
    required String title,
    required String type,
    required IconData icon,
    required String date,
    required String location,
    String? rsvpTag,
    Color? rsvpColor,
    required List<Widget> actions,
    required Color sideColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 120,
            decoration: BoxDecoration(
              color: sideColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 22, color: Colors.grey[700]),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(type, style: const TextStyle(color: Colors.black45)),
                const SizedBox(height: 10),

                if (rsvpTag != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: rsvpColor!.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      rsvpTag,
                      style: TextStyle(
                        color: rsvpColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                if (rsvpTag != null) const SizedBox(height: 10),

                Row(
                  children: [
                    const Icon(Icons.access_time, size: 18),
                    const SizedBox(width: 8),
                    Text(date),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(location),
                  ],
                ),

                const SizedBox(height: 16),
                Row(children: actions),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _redButton(String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _blueButton(String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF596CFF), Color(0xFF3A58FF)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _outlineButton(String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
