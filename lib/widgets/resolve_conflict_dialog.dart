import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/resolve_conflict_viewmodel.dart';

/// A modal dialog that presents two overlapping events and actions to resolve the conflict.
/// It reuses the visual layout from `ResolveConflictView` but is exposed as a dialog
/// and integrates with `ResolveConflictViewModel` (MVVM).
class ResolveConflictDialog extends StatelessWidget {
  final String personalEventId;
  final String circleEventId;
  final String personalTitle;
  final String circleTitle;
  final String personalDate;
  final String circleDate;
  final String personalLocation;
  final String circleLocation;
  final String rsvpStatus;

  const ResolveConflictDialog({
    super.key,
    required this.personalEventId,
    required this.circleEventId,
    required this.personalTitle,
    required this.circleTitle,
    required this.personalDate,
    required this.circleDate,
    required this.personalLocation,
    required this.circleLocation,
    required this.rsvpStatus,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ResolveConflictViewModel(),
      child: Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Resolve Schedule Conflict',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'You have 2 overlapping events:',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 20),

                // Personal event card
                _eventCard(
                  title: personalTitle,
                  type: 'Personal Event',
                  date: personalDate,
                  location: personalLocation,
                  sideColor: Colors.grey,
                  actionsBuilder: (vm) => [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: vm.isLoading
                            ? null
                            : () async {
                                final ok = await vm.resolveConflict(
                                  eventId: personalEventId,
                                  eventType: 'personal',
                                  action: 'cancel_personal',
                                );
                                Navigator.of(context).pop(ok);
                              },
                        child: const Text('Cancel This Event'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Circle event card
                _eventCard(
                  title: circleTitle,
                  type: 'Circle Event',
                  date: circleDate,
                  location: circleLocation,
                  sideColor: Colors.blue,
                  rsvpTag: 'Your RSVP: ',
                  rsvpValue: rsvpStatus,
                  actionsBuilder: (vm) => [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: vm.isLoading
                            ? null
                            : () async {
                                final ok = await vm.resolveConflict(
                                  eventId: circleEventId,
                                  eventType: 'circle',
                                  action: 'change_rsvp_maybe',
                                );
                                Navigator.of(context).pop(ok);
                              },
                        child: const Text('Change to Maybe'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: vm.isLoading
                            ? null
                            : () async {
                                final ok = await vm.resolveConflict(
                                  eventId: circleEventId,
                                  eventType: 'circle',
                                  action: 'change_rsvp_going',
                                );
                                Navigator.of(context).pop(ok);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3A58FF),
                        ),
                        child: const Text('Change to Going'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Center(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 20,
                      ),
                      child: Text('Keep Both As-Is'),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('View Both in Calendar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _eventCard({
    required String title,
    required String type,
    required String date,
    required String location,
    required Color sideColor,
    String? rsvpTag,
    String? rsvpValue,
    required List<Widget> Function(ResolveConflictViewModel vm) actionsBuilder,
  }) {
    return Consumer<ResolveConflictViewModel>(
      builder: (context, vm, _) {
        final actions = actionsBuilder(vm);
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(type, style: const TextStyle(color: Colors.black45)),
                    const SizedBox(height: 8),
                    if (rsvpTag != null)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(rsvpTag),
                                const SizedBox(width: 6),
                                Text(rsvpValue ?? ''),
                              ],
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16),
                        const SizedBox(width: 6),
                        Text(date),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16),
                        const SizedBox(width: 6),
                        Text(location),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(children: actions),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
