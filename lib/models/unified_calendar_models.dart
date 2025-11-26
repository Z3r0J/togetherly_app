import 'location_models.dart';
import '../widgets/rsvp_widgets.dart';

// Re-export RsvpStatus from widgets

// Base class for unified events
abstract class UnifiedEvent {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String? description;
  final LocationModel? location;
  final bool hasConflict;

  UnifiedEvent({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.description,
    this.location,
    this.hasConflict = false,
  });
}

// Personal event
class PersonalUnifiedEvent extends UnifiedEvent {
  final String? color;

  PersonalUnifiedEvent({
    required String id,
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    String? description,
    LocationModel? location,
    this.color,
    bool hasConflict = false,
  }) : super(
    id: id,
    title: title,
    startTime: startTime,
    endTime: endTime,
    description: description,
    location: location,
    hasConflict: hasConflict,
  );
}

// Circle event
class CircleUnifiedEvent extends UnifiedEvent {
  final String circleId;
  final String circleName;
  final String? circleColor;
  final RsvpStatus rsvpStatus;
  final int attendeeCount;

  CircleUnifiedEvent({
    required String id,
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    required this.circleId,
    required this.circleName,
    String? description,
    LocationModel? location,
    this.circleColor,
    this.rsvpStatus = RsvpStatus.none,
    this.attendeeCount = 0,
    bool hasConflict = false,
  }) : super(
    id: id,
    title: title,
    startTime: startTime,
    endTime: endTime,
    description: description,
    location: location,
    hasConflict: hasConflict,
  );
}

// Calendar data structure
class CalendarData {
  final List<UnifiedEvent> events;
  final DateTime currentMonth;

  CalendarData({
    required this.events,
    required this.currentMonth,
  });

  factory CalendarData.fromJson(Map<String, dynamic> json) {
    return CalendarData(
      events: (json['events'] as List<dynamic>?)
              ?.map((e) => _eventFromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      currentMonth: json['currentMonth'] != null
          ? DateTime.parse(json['currentMonth'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'events': events.map((e) {
        if (e is CircleUnifiedEvent) {
          return {
            'type': 'circle',
            'id': e.id,
            'title': e.title,
            'startTime': e.startTime.toIso8601String(),
            'endTime': e.endTime.toIso8601String(),
            'description': e.description,
            'circleId': e.circleId,
            'circleName': e.circleName,
            'circleColor': e.circleColor,
            'rsvpStatus': e.rsvpStatus.toString(),
            'attendeeCount': e.attendeeCount,
            'location': e.location?.toJson(),
            'hasConflict': e.hasConflict,
          };
        } else if (e is PersonalUnifiedEvent) {
          return {
            'type': 'personal',
            'id': e.id,
            'title': e.title,
            'startTime': e.startTime.toIso8601String(),
            'endTime': e.endTime.toIso8601String(),
            'description': e.description,
            'color': e.color,
            'location': e.location?.toJson(),
            'hasConflict': e.hasConflict,
          };
        }
        return {};
      }).toList(),
      'currentMonth': currentMonth.toIso8601String(),
    };
  }
}

UnifiedEvent _eventFromJson(Map<String, dynamic> json) {
  final type = json['type'] as String?;

  if (type == 'circle') {
    return CircleUnifiedEvent(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : DateTime.now(),
      description: json['description'] as String?,
      circleId: json['circleId'] as String? ?? '',
      circleName: json['circleName'] as String? ?? '',
      circleColor: json['circleColor'] as String?,
      rsvpStatus: _rsvpStatusFromString(json['rsvpStatus'] as String?),
      attendeeCount: json['attendeeCount'] as int? ?? 0,
      location: json['location'] != null
          ? LocationModel.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      hasConflict: json['hasConflict'] as bool? ?? false,
    );
  }

  return PersonalUnifiedEvent(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    startTime: json['startTime'] != null
        ? DateTime.parse(json['startTime'] as String)
        : DateTime.now(),
    endTime: json['endTime'] != null
        ? DateTime.parse(json['endTime'] as String)
        : DateTime.now(),
    description: json['description'] as String?,
    color: json['color'] as String?,
    location: json['location'] != null
        ? LocationModel.fromJson(json['location'] as Map<String, dynamic>)
        : null,
    hasConflict: json['hasConflict'] as bool? ?? false,
  );
}

RsvpStatus _rsvpStatusFromString(String? status) {
  switch (status) {
    case 'RsvpStatus.going':
      return RsvpStatus.going;
    case 'RsvpStatus.maybe':
      return RsvpStatus.maybe;
    case 'RsvpStatus.notGoing':
      return RsvpStatus.notGoing;
    default:
      return RsvpStatus.none;
  }
}
