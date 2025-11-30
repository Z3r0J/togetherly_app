import 'location_models.dart';

class PersonalEvent {
  final String id;
  final String userId;
  final String title;
  final DateTime date;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool allDay;
  final LocationModel? location;
  final String? notes;
  final String? color;
  final int? reminderMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;

  PersonalEvent({
    required this.id,
    required this.userId,
    required this.title,
    required this.date,
    this.startTime,
    this.endTime,
    required this.allDay,
    this.location,
    this.notes,
    this.color,
    this.reminderMinutes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PersonalEvent.fromJson(Map<String, dynamic> json) {
    return PersonalEvent(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String).toLocal(),
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String).toLocal()
          : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String).toLocal()
          : null,
      allDay: json['allDay'] as bool? ?? false,
      location: json['location'] != null
          ? LocationModel.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      notes: json['notes'] as String?,
      color: json['color'] as String?,
      reminderMinutes: json['reminderMinutes'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'date': date.toIso8601String(),
      if (startTime != null) 'startTime': startTime!.toIso8601String(),
      if (endTime != null) 'endTime': endTime!.toIso8601String(),
      'allDay': allDay,
      if (location != null) 'location': location!.toJson(),
      if (notes != null) 'notes': notes,
      if (color != null) 'color': color,
      if (reminderMinutes != null) 'reminderMinutes': reminderMinutes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class CreatePersonalEventRequest {
  final String title;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final bool allDay;
  final LocationModel? location;
  final String? notes;
  final String? color;
  final int? reminderMinutes;

  CreatePersonalEventRequest({
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.allDay = false,
    this.location,
    this.notes,
    this.color,
    this.reminderMinutes,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      // Send as UTC to keep the same wall-clock time after server parses/stores
      'date': date.toUtc().toIso8601String(),
      'startTime': startTime.toUtc().toIso8601String(),
      'endTime': endTime.toUtc().toIso8601String(),
      'allDay': allDay,
      if (location != null) 'location': location!.toJson(),
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      if (color != null) 'color': color,
      if (reminderMinutes != null) 'reminderMinutes': reminderMinutes,
    };
  }
}

class PersonalEventResponse {
  final bool success;
  final PersonalEvent data;
  final String timestamp;

  PersonalEventResponse({
    required this.success,
    required this.data,
    required this.timestamp,
  });

  factory PersonalEventResponse.fromJson(Map<String, dynamic> json) {
    return PersonalEventResponse(
      success: json['success'] as bool,
      data: PersonalEvent.fromJson(json['data'] as Map<String, dynamic>),
      timestamp: json['timestamp'] as String,
    );
  }
}
