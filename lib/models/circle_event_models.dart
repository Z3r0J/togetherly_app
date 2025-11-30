import 'location_models.dart';
import '../widgets/rsvp_widgets.dart';

class CircleEventTimeOption {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final int voteCount;

  CircleEventTimeOption({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.voteCount,
  });

  factory CircleEventTimeOption.fromJson(Map<String, dynamic> json) {
    final startRaw = json['startTime'];
    final endRaw = json['endTime'];
    return CircleEventTimeOption(
      id: json['id'] ?? '',
      startTime: startRaw != null
          ? DateTime.parse(startRaw as String).toLocal()
          : DateTime.now(),
      endTime: endRaw != null
          ? DateTime.parse(endRaw as String).toLocal()
          : DateTime.now(),
      voteCount: json['voteCount'] is int
          ? json['voteCount'] as int
          : int.tryParse(json['voteCount']?.toString() ?? '0') ?? 0,
    );
  }
}

class CircleEventRsvp {
  final String id;
  final String userId;
  final String? username;
  final String? email;
  final RsvpStatus status;

  CircleEventRsvp({
    required this.id,
    required this.userId,
    this.username,
    this.email,
    required this.status,
  });

  factory CircleEventRsvp.fromJson(Map<String, dynamic> json) {
    return CircleEventRsvp(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] as String?,
      email: json['email'] as String?,
      status: _statusFromString(json['status'] as String?),
    );
  }
}

class CircleEventPermissions {
  final bool canEdit;
  final bool canDelete;
  final bool canLock;

  CircleEventPermissions({
    required this.canEdit,
    required this.canDelete,
    required this.canLock,
  });

  factory CircleEventPermissions.fromJson(Map<String, dynamic> json) {
    return CircleEventPermissions(
      canEdit: json['canEdit'] as bool? ?? false,
      canDelete: json['canDelete'] as bool? ?? false,
      canLock: json['canLock'] as bool? ?? false,
    );
  }
}

class CircleEventDetail {
  final String id;
  final String circleId;
  final String title;
  final String? description;
  final String? notes;
  final LocationModel? location;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final bool allDay;
  final String? color;
  final int? reminderMinutes;
  final String status;
  final List<CircleEventTimeOption> eventTimes;
  final List<CircleEventRsvp> rsvps;
  final CircleEventPermissions permissions;

  CircleEventDetail({
    required this.id,
    required this.circleId,
    required this.title,
    this.description,
    this.notes,
    this.location,
    this.startsAt,
    this.endsAt,
    this.allDay = false,
    this.color,
    this.reminderMinutes,
    this.status = 'draft',
    this.eventTimes = const [],
    this.rsvps = const [],
    required this.permissions,
  });

  factory CircleEventDetail.fromJson(Map<String, dynamic> json) {
    return CircleEventDetail(
      id: json['id'] ?? '',
      circleId: json['circleId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      location: json['location'] != null
          ? LocationModel.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      startsAt: json['startsAt'] != null
          ? DateTime.parse(json['startsAt'] as String).toLocal()
          : null,
      endsAt: json['endsAt'] != null
          ? DateTime.parse(json['endsAt'] as String).toLocal()
          : null,
      allDay: json['allDay'] as bool? ?? false,
      color: json['color'] as String?,
      reminderMinutes: json['reminderMinutes'] as int?,
      status: json['status'] as String? ?? 'draft',
      eventTimes:
          (json['eventTimes'] as List<dynamic>?)
              ?.map(
                (e) =>
                    CircleEventTimeOption.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      rsvps:
          (json['rsvps'] as List<dynamic>?)
              ?.map((r) => CircleEventRsvp.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      permissions: CircleEventPermissions.fromJson(
        json['permissions'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

RsvpStatus _statusFromString(String? value) {
  switch (value) {
    case 'going':
    case 'RsvpStatus.going':
      return RsvpStatus.going;
    case 'maybe':
    case 'RsvpStatus.maybe':
      return RsvpStatus.maybe;
    case 'notGoing':
    case 'not_going':
    case 'RsvpStatus.notGoing':
      return RsvpStatus.notGoing;
    default:
      return RsvpStatus.none;
  }
}
