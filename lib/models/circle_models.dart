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
