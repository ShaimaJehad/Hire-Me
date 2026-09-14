import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../../data/repositories/notification_repository.dart';
import '../../../../services/notification_service.dart';
import '../models/notification_model.dart';

class JobSeekerNotificationsController extends GetxController {
  final notifications = <NotificationModel>[].obs;
  StreamSubscription? _notificationsSub;

  final _auth = FirebaseAuth.instance;
  final _repository = NotificationRepository();

  @override
  void onInit() {
    super.onInit();
    NotificationService.currentScreen.value = 'notifications';
    _listenToNotifications();
  }

  void _listenToNotifications() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _notificationsSub = _repository.streamNotifications(uid).listen(
      (snapshot) {
        notifications.value = snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.id, doc.data()))
            .where((n) => n.type != 'chat_message')
            .toList();
      },
      onError: (_) => notifications.value = [],
    );
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  Future<void> markAsRead(String id) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    try {
      await _repository.markAsRead(uid, id);
    } catch (e) {
      debugPrint('Error in JobSeekerNotificationsController.markAsRead: $e');
    }
  }

  Future<void> markAllAsRead() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final unread = notifications.where((n) => !n.isRead).toList();
    if (unread.isEmpty) return;
    try {
      await _repository.markAllAsRead(uid, unread.map((n) => n.id).toList());
    } catch (e) {
      debugPrint('Error in JobSeekerNotificationsController.markAllAsRead: $e');
    }
  }

  @override
  void onClose() {
    NotificationService.currentScreen.value = '';
    _notificationsSub?.cancel();
    super.onClose();
  }
}
