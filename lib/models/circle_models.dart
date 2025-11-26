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
  final List<dynamic> events; // TODO: Create Event model
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
      events: json['events'] ?? [],
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
