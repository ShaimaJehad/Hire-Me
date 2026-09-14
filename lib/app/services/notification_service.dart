import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../routes/app_pages.dart';
import 'storage_service.dart';

class NotificationService extends GetxService {
  static final RxString currentScreen = ''.obs;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<NotificationService> init() async {
    await _setupLocalNotifications();
    await _requestPermission();
    await _getFcmToken();
    _listenToTokenRefresh();
    _listenToForegroundMessages();
    _listenToMessageOpenedApp();
    await _checkInitialMessage();
    return this;
  }

  Future<void> _setupLocalNotifications() async {
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
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'hireme_notifications',
        'HireMe Notifications',
        description: 'Job application notifications',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
    );
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
  }

  Future<void> _getFcmToken() async {
    debugPrint('🔵 Getting FCM token...');
    try {
      final token = await _messaging.getToken();
      debugPrint('🟢 FCM token retrieved: $token');
      if (token != null) {
        await _saveTokenToFirestore(token);
      }
    } catch (e) {
      debugPrint('FCM token retrieval failed: $e');
    }
  }

  Future<void> saveFcmToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveTokenToFirestore(token);
      }
    } catch (e) {
      debugPrint('FCM token retrieval failed: $e');
    }
  }

  void _listenToTokenRefresh() {
    _messaging.onTokenRefresh.listen(_saveTokenToFirestore);
  }

  Future<void> _saveTokenToFirestore(String token) async {
    final uid = _auth.currentUser?.uid;
    debugPrint('🔵 Saving token for uid: $uid');
    if (uid == null) return;
    try {
      final role = StorageService.to.userRole;
      debugPrint('🔵 User role: $role');
      if (role == AppUserRole.jobSeeker.value) {
        await _firestore.collection('jobSeekers').doc(uid).set({
          'fcmToken': token,
        }, SetOptions(merge: true));
        debugPrint('🟢 Token saved to jobSeekers collection');
      } else if (role == AppUserRole.company.value) {
        await _firestore.collection('companies').doc(uid).set({
          'fcmToken': token,
        }, SetOptions(merge: true));
        debugPrint('🟢 Token saved to companies collection');
      } else {
        debugPrint(
          'Unknown role "$role" for uid $uid — skipping role-specific save',
        );
      }

      await _firestore.collection('users').doc(uid).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
      debugPrint('🟢 Token saved to users collection');
    } catch (e) {
      debugPrint('🔴 Error saving token: $e');
    }
  }

  void _listenToForegroundMessages() {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    try {
      debugPrint('🔵 Foreground message received: ${message.notification?.title}');
      debugPrint('🔵 Message type: ${message.data['type']}');
      debugPrint('🔵 Current screen: ${NotificationService.currentScreen.value}');
      final type = message.data['type'];
      final screen = currentScreen.value;

      if (type == 'chat_message' && screen == 'chat_details') return;
      if (type == 'application_update' && screen == 'notifications') return;
      if (type == 'new_application' && screen == 'notifications') return;

      final title = message.notification?.title ??
          message.data['title']?.toString() ??
          'HireMe';
      final body = message.notification?.body ??
          message.data['body']?.toString() ??
          '';

      final androidDetails = AndroidNotificationDetails(
        'hireme_notifications',
        'HireMe Notifications',
        channelDescription: 'Job application notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        showWhen: true,
        enableLights: true,
        colorized: true,
      );
      const iosDetails = DarwinNotificationDetails();
      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        details,
        payload: jsonEncode(message.data),
      );
    } catch (e) {
      debugPrint('🔴 Failed to show foreground notification: $e');
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;
    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      _navigateFromData(data);
    } catch (_) {}
  }

  void _listenToMessageOpenedApp() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _navigateFromData(message.data);
    });
  }

  Future<void> _checkInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    if (message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateFromData(message.data);
      });
    }
  }

  void _navigateFromData(Map<String, dynamic> data) {
    final type = data['type'];
    debugPrint('🔵 Navigate from notification type: $type');
    switch (type) {
      case 'application_update':
        Get.toNamed(Routes.jobSeekerNotifications);
        break;
      case 'new_application':
        Get.toNamed(Routes.applicationList);
        break;
      case 'chat_message':
        final chatId = data['chatId'] as String?;
        final senderId = data['senderId'] as String?;
        if (chatId == null || senderId == null) break;
        final uid = _auth.currentUser?.uid;
        if (uid == null || uid == senderId) break;
        final role = StorageService.to.userRole;
        if (role == AppUserRole.jobSeeker.value) {
          Get.toNamed(Routes.jobSeekerChatDetails, arguments: chatId);
        } else if (role == AppUserRole.company.value) {
          Get.toNamed(Routes.companyChatDetails, arguments: chatId);
        }
        break;
      default:
        debugPrint('Unknown notification type: $type');
    }
  }
}
