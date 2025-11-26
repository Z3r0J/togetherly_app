import 'dart:convert';
import 'dart:developer' as developer;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/notification_models.dart';
import '../models/api_error.dart';
import 'auth_service.dart';

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  developer.log('🔔 Background message: ${message.notification?.title}');
}

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final AuthService _authService = AuthService();

  String? _currentToken;
  Function(RemoteMessage)? _onMessageTapped;

  // Initialize FCM
  Future<void> initialize({Function(RemoteMessage)? onMessageTapped}) async {
    developer.log('🔵 Initializing NotificationService...');
    _onMessageTapped = onMessageTapped;

    try {
      // Request permissions
      final settings = await _requestPermissions();
      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        developer.log('🔴 Notification permissions denied');
        return;
      }

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Setup background handler
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Get FCM token
      _currentToken = await _fcm.getToken();
      if (_currentToken != null) {
        developer.log(
          '✅ FCM Token obtained: ${_currentToken!.substring(0, 20)}...',
        );
        await registerDeviceToken(_currentToken!);
      }

      // Listen for token refresh
      _fcm.onTokenRefresh.listen((newToken) {
        developer.log('🔄 FCM Token refreshed');
        _currentToken = newToken;
        registerDeviceToken(newToken);
      });

      // Setup message handlers
      _setupMessageHandlers();

      developer.log('✅ NotificationService initialized successfully');
    } catch (e) {
      developer.log('🔴 Error initializing notifications: $e');
    }
  }

  // Request notification permissions
  Future<NotificationSettings> _requestPermissions() async {
    return await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          final message = RemoteMessage(data: jsonDecode(details.payload!));
          _onMessageTapped?.call(message);
        }
      },
    );
  }

  // Setup message handlers
  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      developer.log('🔔 Foreground message: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // Background message opened
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      developer.log('🔔 Message opened from background');
      _onMessageTapped?.call(message);
    });

    // Check for initial message (app opened from terminated state)
    _fcm.getInitialMessage().then((message) {
      if (message != null) {
        developer.log('🔔 App opened from terminated state');
        _onMessageTapped?.call(message);
      }
    });
  }

  // Show local notification for foreground messages
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'togetherly_channel',
      'Togetherly Notifications',
      channelDescription: 'Notifications for Togetherly app',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: jsonEncode(message.data),
    );
  }

  // Register device token with backend
  Future<bool> registerDeviceToken(String token) async {
    try {
      final accessToken = await _authService.getAccessToken();
      if (accessToken == null) {
        developer.log('🔴 No access token available for device registration');
        return false;
      }

      final deviceName = await _getDeviceName();
      final request = DeviceTokenRequest(
        token: token,
        platform: DeviceTokenRequest.getPlatform(),
        deviceName: deviceName,
      );

      developer.log('🔵 Registering device token with backend...');

      final response = await http.post(
        Uri.parse('${ApiConfig.notificationsUrl}/device-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        developer.log('✅ Device token registered successfully');
        return true;
      } else {
        developer.log(
          '🔴 Failed to register device token: ${response.statusCode}',
        );
        developer.log('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      developer.log('🔴 Error registering device token: $e');
      return false;
    }
  }

  // Get device name
  Future<String> _getDeviceName() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return '${androidInfo.brand} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return '${iosInfo.name} ${iosInfo.model}';
      }
    } catch (e) {
      developer.log('Error getting device name: $e');
    }
    return 'Unknown Device';
  }

  // Get notifications from backend
  Future<NotificationsResponse?> getNotifications({
    String category = 'all',
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final accessToken = await _authService.getAccessToken();
      if (accessToken == null)
        throw ApiError(errorCode: 'AUTH_NO_TOKEN', message: 'No access token');

      developer.log('🔵 Fetching notifications...');

      final response = await http.get(
        Uri.parse(
          '${ApiConfig.notificationsUrl}?category=$category&page=$page&limit=$limit',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        developer.log('✅ Notifications fetched successfully');
        return NotificationsResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw ApiError(
          errorCode: 'AUTH_UNAUTHORIZED',
          message: 'Unauthorized',
          statusCode: 401,
        );
      } else {
        throw ApiError(
          errorCode: 'FETCH_NOTIFICATIONS_FAILED',
          message: 'Failed to fetch notifications',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      developer.log('🔴 Error fetching notifications: $e');
      rethrow;
    }
  }

  // Get unread count
  Future<UnreadCountResponse?> getUnreadCount({String category = 'all'}) async {
    try {
      final accessToken = await _authService.getAccessToken();
      if (accessToken == null)
        throw ApiError(errorCode: 'AUTH_NO_TOKEN', message: 'No access token');

      final response = await http.get(
        Uri.parse(
          '${ApiConfig.notificationsUrl}/unread-count?category=$category',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return UnreadCountResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw ApiError(
          errorCode: 'AUTH_UNAUTHORIZED',
          message: 'Unauthorized',
          statusCode: 401,
        );
      } else {
        throw ApiError(
          errorCode: 'FETCH_UNREAD_COUNT_FAILED',
          message: 'Failed to fetch unread count',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      developer.log('🔴 Error fetching unread count: $e');
      rethrow;
    }
  }

  // Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final accessToken = await _authService.getAccessToken();
      if (accessToken == null) return false;

      final response = await http.put(
        Uri.parse('${ApiConfig.notificationsUrl}/$notificationId/read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      developer.log('🔴 Error marking as read: $e');
      return false;
    }
  }

  // Mark all as read
  Future<bool> markAllAsRead({String? category}) async {
    try {
      final accessToken = await _authService.getAccessToken();
      if (accessToken == null) return false;

      final url = category != null
          ? '${ApiConfig.notificationsUrl}/mark-all-read?category=$category'
          : '${ApiConfig.notificationsUrl}/mark-all-read';

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      developer.log('🔴 Error marking all as read: $e');
      return false;
    }
  }

  // Dismiss notification
  Future<bool> dismissNotification(String notificationId) async {
    try {
      final accessToken = await _authService.getAccessToken();
      if (accessToken == null) return false;

      final response = await http.delete(
        Uri.parse('${ApiConfig.notificationsUrl}/$notificationId/dismiss'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      developer.log('🔴 Error dismissing notification: $e');
      return false;
    }
  }

  // Handle notification action
  Future<bool> handleAction(String notificationId, String action) async {
    try {
      final accessToken = await _authService.getAccessToken();
      if (accessToken == null) return false;

      developer.log(
        '🔵 Handling action: $action for notification: $notificationId',
      );

      final response = await http.post(
        Uri.parse('${ApiConfig.notificationsUrl}/$notificationId/action'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'action': action}),
      );

      return response.statusCode == 200;
    } catch (e) {
      developer.log('🔴 Error handling action: $e');
      return false;
    }
  }

  // Get current FCM token
  String? get currentToken => _currentToken;
}
