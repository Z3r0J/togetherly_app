import 'location_models.dart';
import '../widgets/rsvp_widgets.dart' show RsvpStatus;

enum UnifiedEventType { personal, circle }

extension RsvpStatusExtension on RsvpStatus {
  String get value {
    switch (this) {
      case RsvpStatus.going:
        return 'going';
      case RsvpStatus.maybe:
        return 'maybe';
      case RsvpStatus.notGoing:
        return 'not going';
      case RsvpStatus.none:
        return 'none';
    }
  }

  static RsvpStatus? fromString(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'going':
        return RsvpStatus.going;
      case 'maybe':
        return RsvpStatus.maybe;
      case 'not going':
        return RsvpStatus.notGoing;
      default:
        return null;
    }
  }
}

class UnifiedEventConflict {
  final String id;
  final String title;
  final UnifiedEventType type;
  final DateTime startTime;
  final DateTime endTime;

  UnifiedEventConflict({
    required this.id,
    required this.title,
    required this.type,
    required this.startTime,
    required this.endTime,
  });

  factory UnifiedEventConflict.fromJson(Map<String, dynamic> json) {
    return UnifiedEventConflict(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] == 'personal'
          ? UnifiedEventType.personal
          : UnifiedEventType.circle,
      startTime: DateTime.parse(json['startTime'] as String).toLocal(),
      endTime: DateTime.parse(json['endTime'] as String).toLocal(),
    );
  }
}

abstract class UnifiedEvent {
  final String id;
  final UnifiedEventType type;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final bool allDay;
  final List<UnifiedEventConflict> conflictsWith;

  UnifiedEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.allDay,
    required this.conflictsWith,
  });

  bool get hasConflict => conflictsWith.isNotEmpty;
}

class PersonalUnifiedEvent extends UnifiedEvent {
  final LocationModel? location;
  final String? color;
  final String? notes;
  final int? reminderMinutes;
  final bool cancelled;

  PersonalUnifiedEvent({
    required super.id,
    required super.title,
    required super.startTime,
    required super.endTime,
    required super.allDay,
    required super.conflictsWith,
    this.location,
    this.color,
    this.notes,
    this.reminderMinutes,
    this.cancelled = false,
  }) : super(type: UnifiedEventType.personal);

  factory PersonalUnifiedEvent.fromJson(Map<String, dynamic> json) {
    return PersonalUnifiedEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      startTime: DateTime.parse(json['startTime'] as String).toLocal(),
      endTime: DateTime.parse(json['endTime'] as String).toLocal(),
      allDay: json['allDay'] as bool? ?? false,
      location: json['location'] != null
          ? LocationModel.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      color: json['color'] as String?,
      notes: json['notes'] as String?,
      reminderMinutes: json['reminderMinutes'] as int?,
      cancelled: json['cancelled'] as bool? ?? false,
      conflictsWith: (json['conflictsWith'] as List<dynamic>? ?? [])
          .map((c) => UnifiedEventConflict.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CircleUnifiedEvent extends UnifiedEvent {
  final String circleId;
  final String circleName;
  final String? circleColor;
  final LocationModel? location;
  final String status;
  final RsvpStatus? rsvpStatus;
  final int attendeeCount;
  final bool canChangeRsvp;
  final bool isCreator;

  CircleUnifiedEvent({
    required super.id,
    required super.title,
    required super.startTime,
    required super.endTime,
    required super.allDay,
    required super.conflictsWith,
    required this.circleId,
    required this.circleName,
    this.circleColor,
    this.location,
    required this.status,
    this.rsvpStatus,
    required this.attendeeCount,
    required this.canChangeRsvp,
    required this.isCreator,
  }) : super(type: UnifiedEventType.circle);

  factory CircleUnifiedEvent.fromJson(Map<String, dynamic> json) {
    return CircleUnifiedEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      circleId: json['circleId'] as String,
      circleName: json['circleName'] as String,
      circleColor: json['circleColor'] as String?,
      startTime: DateTime.parse(json['startTime'] as String).toLocal(),
      endTime: DateTime.parse(json['endTime'] as String).toLocal(),
      allDay: json['allDay'] as bool? ?? false,
      location: json['location'] != null
          ? LocationModel.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      status: json['status'] as String,
      rsvpStatus: RsvpStatusExtension.fromString(json['rsvpStatus'] as String?),
      attendeeCount: json['attendeeCount'] as int,
      canChangeRsvp: json['canChangeRsvp'] as bool,
      isCreator: json['isCreator'] as bool,
      conflictsWith: (json['conflictsWith'] as List<dynamic>? ?? [])
          .map((c) => UnifiedEventConflict.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}

class UnifiedCalendarSummary {
  final int totalEvents;
  final int personalEvents;
  final int circleEvents;
  final int goingCount;
  final int maybeCount;
  final int notGoingCount;
  final int conflictsCount;

  UnifiedCalendarSummary({
    required this.totalEvents,
    required this.personalEvents,
    required this.circleEvents,
    required this.goingCount,
    required this.maybeCount,
    required this.notGoingCount,
    required this.conflictsCount,
  });

  factory UnifiedCalendarSummary.fromJson(Map<String, dynamic> json) {
    return UnifiedCalendarSummary(
      totalEvents: json['totalEvents'] as int,
      personalEvents: json['personalEvents'] as int,
      circleEvents: json['circleEvents'] as int,
      goingCount: json['goingCount'] as int,
      maybeCount: json['maybeCount'] as int,
      notGoingCount: json['notGoingCount'] as int,
      conflictsCount: json['conflictsCount'] as int,
    );
  }
}

class UnifiedCalendarResponse {
  final List<UnifiedEvent> events;
  final UnifiedCalendarSummary summary;

  UnifiedCalendarResponse({required this.events, required this.summary});

  factory UnifiedCalendarResponse.fromJson(Map<String, dynamic> json) {
    final List<UnifiedEvent> events = (json['events'] as List<dynamic>).map((
      e,
    ) {
      final eventMap = e as Map<String, dynamic>;
      if (eventMap['type'] == 'personal') {
        return PersonalUnifiedEvent.fromJson(eventMap);
      } else {
        return CircleUnifiedEvent.fromJson(eventMap);
      }
    }).toList();

    return UnifiedCalendarResponse(
      events: events,
      summary: UnifiedCalendarSummary.fromJson(
        json['summary'] as Map<String, dynamic>,
      ),
    );
  }
}
