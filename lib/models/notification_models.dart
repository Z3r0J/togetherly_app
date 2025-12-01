import 'dart:io';

// Device Token Registration
class DeviceTokenRequest {
  final String token;
  final String platform;
  final String? deviceName;

  DeviceTokenRequest({
    required this.token,
    required this.platform,
    this.deviceName,
  });

  Map<String, dynamic> toJson() => {
    'token': token,
    'platform': platform,
    if (deviceName != null) 'deviceName': deviceName,
  };

  static String getPlatform() {
    return Platform.isIOS ? 'ios' : 'android';
  }
}

class DeviceTokenResponse {
  final String message;
  final DeviceToken? data;

  DeviceTokenResponse({required this.message, this.data});

  factory DeviceTokenResponse.fromJson(Map<String, dynamic> json) {
    return DeviceTokenResponse(
      message: json['message'] as String,
      data: json['data'] != null
          ? DeviceToken.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class DeviceToken {
  final String id;
  final String userId;
  final String token;
  final String platform;
  final String? deviceName;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastUsedAt;

  DeviceToken({
    required this.id,
    required this.userId,
    required this.token,
    required this.platform,
    this.deviceName,
    required this.isActive,
    required this.createdAt,
    this.lastUsedAt,
  });

  factory DeviceToken.fromJson(Map<String, dynamic> json) {
    return DeviceToken(
      id: json['id'] as String,
      userId: json['userId'] as String,
      token: json['token'] as String,
      platform: json['platform'] as String,
      deviceName: json['deviceName'] as String?,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUsedAt: json['lastUsedAt'] != null
          ? DateTime.parse(json['lastUsedAt'] as String)
          : null,
    );
  }
}

// Notification Model
class AppNotification {
  final String id;
  final String type;
  final String category;
  final String title;
  final String body;
  final String priority;
  final String iconType;
  final String iconColor;
  final List<NotificationActionButton> actionButtons;
  final NotificationMetadata metadata;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? dismissedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.category,
    required this.title,
    required this.body,
    required this.priority,
    required this.iconType,
    required this.iconColor,
    required this.actionButtons,
    required this.metadata,
    required this.isRead,
    this.readAt,
    this.dismissedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      type: json['type'] as String,
      category: json['category'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      priority: json['priority'] as String,
      iconType: json['iconType'] as String,
      iconColor: json['iconColor'] as String,
      actionButtons:
          (json['actionButtons'] as List<dynamic>?)
              ?.map(
                (e) => NotificationActionButton.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      metadata: NotificationMetadata.fromJson(
        json['metadata'] as Map<String, dynamic>? ?? {},
      ),
      isRead: json['isRead'] as bool,
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
      dismissedAt: json['dismissedAt'] != null
          ? DateTime.parse(json['dismissedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class NotificationActionButton {
  final String label;
  final String action;
  final String style;

  NotificationActionButton({
    required this.label,
    required this.action,
    required this.style,
  });

  factory NotificationActionButton.fromJson(Map<String, dynamic> json) {
    return NotificationActionButton(
      label: json['label'] as String,
      action: json['action'] as String,
      style: json['style'] as String,
    );
  }
}

class NotificationMetadata {
  final String? eventId;
  final String? circleId;
  final String? userId;
  final String? shareToken;

  NotificationMetadata({
    this.eventId,
    this.circleId,
    this.userId,
    this.shareToken,
  });

  factory NotificationMetadata.fromJson(Map<String, dynamic> json) {
    return NotificationMetadata(
      eventId: json['eventId'] as String?,
      circleId: json['circleId'] as String?,
      userId: json['userId'] as String?,
      shareToken: json['shareToken'] as String?,
    );
  }
}

class NotificationsResponse {
  final List<AppNotification> notifications;
  final int page;
  final int limit;
  final bool hasMore;

  NotificationsResponse({
    required this.notifications,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final pagination = data['pagination'] as Map<String, dynamic>;
    return NotificationsResponse(
      notifications: (data['notifications'] as List<dynamic>)
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: pagination['page'] as int,
      limit: pagination['limit'] as int,
      hasMore: pagination['hasMore'] as bool,
    );
  }
}

class UnreadCountResponse {
  final int total;
  final Map<String, int> byCategory;

  UnreadCountResponse({required this.total, required this.byCategory});

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return UnreadCountResponse(
      total: data['total'] as int,
      byCategory: Map<String, int>.from(data['byCategory'] as Map),
    );
  }
}
