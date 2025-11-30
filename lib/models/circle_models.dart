import 'location_models.dart';

class Circle {
  final String id;
  final String name;
  final String description;
  final String color;
  final String privacy;
  final String memberCount;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  Circle({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.privacy,
    required this.memberCount,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Circle.fromJson(Map<String, dynamic> json) {
    return Circle(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      color: json['color'] ?? 'purple',
      privacy: json['privacy'] ?? 'invite-only',
      memberCount: json['memberCount'] ?? '0',
      role: json['role'] ?? 'member',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'privacy': privacy,
      'memberCount': memberCount,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper to get member count as int
  int get memberCountInt => int.tryParse(memberCount) ?? 0;
}

class CirclesData {
  final List<Circle> circles;

  CirclesData({required this.circles});

  factory CirclesData.fromJson(Map<String, dynamic> json) {
    return CirclesData(
      circles:
          (json['circles'] as List<dynamic>?)
              ?.map((circle) => Circle.fromJson(circle as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'circles': circles.map((circle) => circle.toJson()).toList()};
  }
}

class CirclesResponse {
  final bool success;
  final CirclesData data;

  CirclesResponse({required this.success, required this.data});

  factory CirclesResponse.fromJson(Map<String, dynamic> json) {
    return CirclesResponse(
      success: json['success'] ?? false,
      data: CirclesData.fromJson(
        json['data'] as Map<String, dynamic>? ?? {'circles': []},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data.toJson()};
  }
}

class CreateCircleRequest {
  final String name;
  final String description;
  final String color;
  final String privacy;

  CreateCircleRequest({
    required this.name,
    required this.description,
    required this.color,
    required this.privacy,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'color': color,
      'privacy': privacy,
    };
  }
}

class CreateCircleResponse {
  final bool success;
  final Circle data;
  final String timestamp;

  CreateCircleResponse({
    required this.success,
    required this.data,
    required this.timestamp,
  });

  factory CreateCircleResponse.fromJson(Map<String, dynamic> json) {
    return CreateCircleResponse(
      success: json['success'] ?? false,
      data: Circle.fromJson(json['data'] as Map<String, dynamic>),
      timestamp: json['timestamp'] ?? '',
    );
  }
}

// Circle Member Model
class CircleMember {
  final String id;
  final String userId;
  final String role;
  final String name;
  final String email;
  final DateTime joinedAt;

  CircleMember({
    required this.id,
    required this.userId,
    required this.role,
    required this.name,
    required this.email,
    required this.joinedAt,
  });

  factory CircleMember.fromJson(Map<String, dynamic> json) {
    return CircleMember(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      role: json['role'] ?? 'member',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'])
          : DateTime.now(),
    );
  }
}

// Circle Detail Model (with members, events, permissions)
class CircleDetail {
  final String id;
  final String name;
  final String description;
  final String color;
  final String privacy;
  final String ownerId;
  final List<CircleMember> members;
  final List<CircleDetailEvent> events;
  final String userRole;
  final bool canEdit;
  final bool canDelete;
  final DateTime createdAt;
  final DateTime updatedAt;

  CircleDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.privacy,
    required this.ownerId,
    required this.members,
    required this.events,
    required this.userRole,
    required this.canEdit,
    required this.canDelete,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CircleDetail.fromJson(Map<String, dynamic> json) {
    return CircleDetail(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      color: json['color'] ?? 'purple',
      privacy: json['privacy'] ?? 'invite-only',
      ownerId: json['ownerId'] ?? '',
      members:
          (json['members'] as List<dynamic>?)
              ?.map(
                (member) =>
                    CircleMember.fromJson(member as Map<String, dynamic>),
              )
              .toList() ??
          [],
      events: (json['events'] as List<dynamic>? ?? [])
          .map(
            (e) => CircleDetailEvent.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      userRole: json['userRole'] ?? 'member',
      canEdit: json['canEdit'] ?? false,
      canDelete: json['canDelete'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  int get memberCount => members.length;
}

class CircleDetailEventTime {
  final String id;
  final DateTime startTime;
  final DateTime endTime;

  CircleDetailEventTime({
    required this.id,
    required this.startTime,
    required this.endTime,
  });

  factory CircleDetailEventTime.fromJson(Map<String, dynamic> json) {
    return CircleDetailEventTime(
      id: json['id'] ?? '',
      startTime: DateTime.parse(json['startTime'] as String).toLocal(),
      endTime: DateTime.parse(json['endTime'] as String).toLocal(),
    );
  }
}

class CircleDetailEvent {
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
  final String status;
  final int goingCount;
  final int maybeCount;
  final int notGoingCount;
  final String? rsvpStatus;
  final List<CircleDetailEventTime> eventTimes;

  CircleDetailEvent({
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
    required this.status,
    required this.goingCount,
    required this.maybeCount,
    required this.notGoingCount,
    this.rsvpStatus,
    this.eventTimes = const [],
  });

  factory CircleDetailEvent.fromJson(Map<String, dynamic> json) {
    return CircleDetailEvent(
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
      status: json['status'] as String? ?? 'draft',
      goingCount: json['goingCount'] as int? ?? 0,
      maybeCount: json['maybeCount'] as int? ?? 0,
      notGoingCount: json['notGoingCount'] as int? ?? 0,
      rsvpStatus: json['rsvpStatus'] as String?,
      eventTimes: (json['eventTimes'] as List<dynamic>? ?? [])
          .map(
            (et) => CircleDetailEventTime.fromJson(
              et as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}

// Circle Detail Response
class CircleDetailResponse {
  final bool success;
  final CircleDetail data;
  final String timestamp;

  CircleDetailResponse({
    required this.success,
    required this.data,
    required this.timestamp,
  });

  factory CircleDetailResponse.fromJson(Map<String, dynamic> json) {
    return CircleDetailResponse(
      success: json['success'] ?? false,
      data: CircleDetail.fromJson(json['data'] as Map<String, dynamic>),
      timestamp: json['timestamp'] ?? '',
    );
  }
}

// Update Circle Request
class UpdateCircleRequest {
  final String name;
  final String description;
  final String color;
  final String privacy;

  UpdateCircleRequest({
    required this.name,
    required this.description,
    required this.color,
    required this.privacy,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'color': color,
      'privacy': privacy,
    };
  }
}

class UpdateCircleResponse {
  final bool success;
  final String message;
  final String? error;
  final String timestamp;

  UpdateCircleResponse({
    required this.success,
    required this.message,
    this.error,
    required this.timestamp,
  });

  factory UpdateCircleResponse.fromJson(Map<String, dynamic> json) {
    return UpdateCircleResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      error: json['error'],
      timestamp: json['timestamp'] ?? '',
    );
  }
}

// Delete Circle Response
class DeleteCircleResponse {
  final bool success;
  final String message;
  final String? error;
  final String timestamp;

  DeleteCircleResponse({
    required this.success,
    required this.message,
    this.error,
    required this.timestamp,
  });

  factory DeleteCircleResponse.fromJson(Map<String, dynamic> json) {
    return DeleteCircleResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      error: json['error'],
      timestamp: json['timestamp'] ?? '',
    );
  }
}

// Circle Invitation Models

// Send Invitation Request
class SendInvitationRequest {
  final List<String> emails;
  final String type;

  SendInvitationRequest({required this.emails, this.type = 'email'});

  Map<String, dynamic> toJson() {
    return {'emails': emails, 'type': type};
  }
}

// Send Invitation Response
class SendInvitationData {
  final List<String> success;
  final List<Map<String, dynamic>> failed;

  SendInvitationData({required this.success, required this.failed});

  factory SendInvitationData.fromJson(Map<String, dynamic> json) {
    return SendInvitationData(
      success: List<String>.from(json['success'] ?? []),
      failed: List<Map<String, dynamic>>.from(json['failed'] ?? []),
    );
  }
}

class SendInvitationResponse {
  final bool success;
  final SendInvitationData data;
  final String timestamp;

  SendInvitationResponse({
    required this.success,
    required this.data,
    required this.timestamp,
  });

  factory SendInvitationResponse.fromJson(Map<String, dynamic> json) {
    return SendInvitationResponse(
      success: json['success'] ?? false,
      data: SendInvitationData.fromJson(json['data'] as Map<String, dynamic>),
      timestamp: json['timestamp'] ?? '',
    );
  }
}

// Invitation Details Models
class InvitationCircle {
  final String id;
  final String name;
  final String description;
  final String color;
  final String privacy;

  InvitationCircle({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.privacy,
  });

  factory InvitationCircle.fromJson(Map<String, dynamic> json) {
    return InvitationCircle(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      color: json['color'] ?? 'purple',
      privacy: json['privacy'] ?? 'invite-only',
    );
  }
}

class InvitationInviter {
  final String id;
  final String name;
  final String email;

  InvitationInviter({
    required this.id,
    required this.name,
    required this.email,
  });

  factory InvitationInviter.fromJson(Map<String, dynamic> json) {
    return InvitationInviter(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class InvitationDetails {
  final String invitationId;
  final String circleName;
  final String circleDescription;
  final String circleColor;
  final String inviterName;
  final String invitedEmail;
  final DateTime expiresAt;
  final String status;
  final int memberCount;
  final bool isExpired;
  final bool isRegistered;

  InvitationDetails({
    required this.invitationId,
    required this.circleName,
    required this.circleDescription,
    required this.circleColor,
    required this.inviterName,
    required this.invitedEmail,
    required this.expiresAt,
    required this.status,
    required this.memberCount,
    required this.isExpired,
    required this.isRegistered,
  });

  factory InvitationDetails.fromJson(Map<String, dynamic> json) {
    return InvitationDetails(
      invitationId: json['invitationId'] ?? '',
      circleName: json['circleName'] ?? '',
      circleDescription: json['circleDescription'] ?? '',
      circleColor: json['circleColor'] ?? '',
      inviterName: json['inviterName'] ?? '',
      invitedEmail: json['invitedEmail'] ?? '',
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : DateTime.now(),
      status: json['status'] ?? '',
      memberCount: json['memberCount'] ?? 0,
      isExpired: json['isExpired'] ?? false,
      isRegistered: json['isRegistered'] ?? false,
    );
  }
}

class InvitationDetailsResponse {
  final bool success;
  final InvitationDetails data;
  final String timestamp;

  InvitationDetailsResponse({
    required this.success,
    required this.data,
    required this.timestamp,
  });

  factory InvitationDetailsResponse.fromJson(Map<String, dynamic> json) {
    return InvitationDetailsResponse(
      success: json['success'] ?? false,
      data: InvitationDetails.fromJson(json['data'] as Map<String, dynamic>),
      timestamp: json['timestamp'] ?? '',
    );
  }
}

// Accept Invitation Response
class AcceptInvitationData {
  final String circleId;
  final String circleName;
  final String message;

  AcceptInvitationData({
    required this.circleId,
    required this.circleName,
    required this.message,
  });

  factory AcceptInvitationData.fromJson(Map<String, dynamic> json) {
    return AcceptInvitationData(
      circleId: json['circleId'] ?? '',
      circleName: json['circleName'] ?? '',
      message: json['message'] ?? '',
    );
  }
}

class AcceptInvitationResponse {
  final bool success;
  final AcceptInvitationData data;
  final String timestamp;

  AcceptInvitationResponse({
    required this.success,
    required this.data,
    required this.timestamp,
  });

  factory AcceptInvitationResponse.fromJson(Map<String, dynamic> json) {
    return AcceptInvitationResponse(
      success: json['success'] ?? false,
      data: AcceptInvitationData.fromJson(json['data'] as Map<String, dynamic>),
      timestamp: json['timestamp'] ?? '',
    );
  }
}
