import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../data/repositories/auth_repository.dart';
import '../../modules/sync/sync_controller.dart';

/// Top-level background message handler required by FirebaseMessaging
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  debugPrint('FCM background message received: ${message.messageId} | ${message.notification?.title}');
}

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  factory NotificationService() => instance;
  NotificationService._internal();

  static const String channelId = 'gps_school_alerts';
  static const String channelName = 'School Alerts & Attendance';
  static const String channelDescription =
      'Notifications for attendance locking, correction requests, and school notices';

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  /// Initialize Firebase, FCM listeners, local notification channels, and register token
  Future<void> init() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      await _initLocalNotifications();
      await _requestPermissions();
      await _setupFcmListeners();
      _initialized = true;
      debugPrint('NotificationService initialized successfully');
    } catch (e, st) {
      debugPrint('NotificationService initialization failed gracefully: $e\n$st');
    }
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint('Notification tapped with payload: ${response.payload}');
      },
    );

    const androidChannel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(androidChannel);
  }

  Future<void> _requestPermissions() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint('User notification permission status: ${settings.authorizationStatus}');
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
    }
  }

  Future<void> _setupFcmListeners() async {
    try {
      // 1. Get FCM token
      // ignore: deprecated_member_use
      _fcmToken = await FirebaseMessaging.instance.getToken();
      debugPrint('FCM Token: $_fcmToken');

      if (_fcmToken != null) {
        await syncTokenToBackend(_fcmToken!);
      }

      // 2. Token refresh listener
      // ignore: deprecated_member_use
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        syncTokenToBackend(newToken);
      });

      // 3. Foreground message listener (Firebase real-time push invalidation)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('FCM foreground message: ${message.notification?.title} - ${message.notification?.body}');
        showForegroundNotification(message);
        if (Get.isRegistered<SyncController>()) {
          Get.find<SyncController>().syncNow(silent: true);
        }
      });

      // 4. Background opened message listener
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('App opened from notification: ${message.data}');
        if (Get.isRegistered<SyncController>()) {
          Get.find<SyncController>().syncNow(silent: true);
        }
      });
    } catch (e) {
      debugPrint('Error setting up FCM listeners: $e');
    }
  }

  /// Display a heads-up banner when notification arrives while app is in foreground
  Future<void> showForegroundNotification(RemoteMessage message) async {
    final title = message.notification?.title ?? message.data['title'] ?? 'School Notice';
    final body = message.notification?.body ?? message.data['bodyText'] ?? message.data['body'] ?? '';

    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const platformDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: platformDetails,
      payload: jsonEncode(message.data),
    );
  }

  /// Register or refresh device token on Cloudflare backend
  Future<void> syncTokenToBackend(String token) async {
    try {
      if (!Get.isRegistered<AuthRepository>()) return;
      final authRepo = Get.find<AuthRepository>();
      final sessionToken = await authRepo.getAuthToken();
      if (sessionToken == null || sessionToken.isEmpty) return;

      final url = Uri.parse('https://myschool-api.pages.dev/api/v1/notifications/register-token');
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $sessionToken',
        },
        body: jsonEncode({
          'deviceToken': token,
          'platform': 'android',
        }),
      );

      if (res.statusCode == 200) {
        debugPrint('Device token successfully registered with backend');
      } else {
        debugPrint('Failed to register device token: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      debugPrint('syncTokenToBackend error: $e');
    }
  }

  /// Send cloud alert to school staff / head teacher
  Future<bool> sendSchoolAlert({
    String? targetUserId,
    required String type,
    required String title,
    required String bodyText,
    Map<String, String>? data,
  }) async {
    try {
      if (!Get.isRegistered<AuthRepository>()) return false;
      final authRepo = Get.find<AuthRepository>();
      final sessionToken = await authRepo.getAuthToken();
      if (sessionToken == null || sessionToken.isEmpty) return false;

      final url = Uri.parse('https://myschool-api.pages.dev/api/v1/notifications/send-alert');
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $sessionToken',
        },
        body: jsonEncode({
          // ignore: use_null_aware_elements
          if (targetUserId != null) 'targetUserId': targetUserId,
          'type': type,
          'title': title,
          'bodyText': bodyText,
          'data': data ?? {},
        }),
      );

      return res.statusCode == 200;
    } catch (e) {
      debugPrint('sendSchoolAlert error: $e');
      return false;
    }
  }
}
