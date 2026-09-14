import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// ─── Fake Firestore QueryDocumentSnapshot ─────────────────────────────

class _FakeQueryDocumentSnapshot {
  final String id;

  _FakeQueryDocumentSnapshot({required this.id});
}

// ─── Fake Firestore QuerySnapshot ─────────────────────────────────────

class _FakeQuerySnapshot {
  final List<_FakeQueryDocumentSnapshot> docs;

  _FakeQuerySnapshot({required this.docs});
}

// ─── Testable controller mirroring CompanyDashboardController
//      notification badge logic ────────────────────────────────────────

class _FakeNotificationBadgeController {
  final unreadCount = 0.obs;
  bool _subscriptionCancelled = false;

  bool get isSubscriptionCancelled => _subscriptionCancelled;

  /// Simulates the Firestore snapshot stream callback from
  /// CompanyDashboardController's _notificationsSubscription:
  ///   listen(
  ///     (snapshot) => unreadCount.value = snapshot.docs.length,
  ///     onError: (_) => unreadCount.value = 0,
  ///   );
  void onNotificationSnapshot(_FakeQuerySnapshot snapshot) {
    unreadCount.value = snapshot.docs.length;
  }

  /// Simulates the stream error callback
  void onNotificationError(Object error) {
    unreadCount.value = 0;
  }

  /// Simulates onClose() subscription cleanup
  void cancelSubscription() {
    _subscriptionCancelled = true;
  }
}

// ─── Tests ────────────────────────────────────────────────────────────

void main() {
  late _FakeNotificationBadgeController controller;

  setUp(() {
    controller = _FakeNotificationBadgeController();
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  // ── 1. Initial state ─────────────────────────────────────────────

  group('Initial state', () {
    test('unreadCount should start at 0', () {
      expect(controller.unreadCount.value, 0);
    });

    test('subscription should not be cancelled initially', () {
      expect(controller.isSubscriptionCancelled, isFalse);
    });
  });

  // ── 2. Snapshot updates ──────────────────────────────────────────

  group('Snapshot updates', () {
    test('should update unreadCount when snapshot has unread notifications',
        () {
      final snapshot = _FakeQuerySnapshot(
        docs: [
          _FakeQueryDocumentSnapshot(id: 'notif-1'),
        ],
      );

      controller.onNotificationSnapshot(snapshot);

      expect(controller.unreadCount.value, 1);
    });

    test('should update unreadCount with multiple unread notifications',
        () {
      final snapshot = _FakeQuerySnapshot(
        docs: [
          _FakeQueryDocumentSnapshot(id: 'notif-1'),
          _FakeQueryDocumentSnapshot(id: 'notif-2'),
          _FakeQueryDocumentSnapshot(id: 'notif-3'),
        ],
      );

      controller.onNotificationSnapshot(snapshot);

      expect(controller.unreadCount.value, 3);
    });

    test('should reset unreadCount to 0 when all notifications are read',
        () {
      // Start with unread count at 3
      controller.unreadCount.value = 3;

      // Empty snapshot simulates all notifications being read
      final snapshot = _FakeQuerySnapshot(docs: []);

      controller.onNotificationSnapshot(snapshot);

      expect(controller.unreadCount.value, 0);
    });
  });

  // ── 3. Error handling ────────────────────────────────────────────

  group('Error handling', () {
    test('should reset unreadCount to 0 on stream error', () {
      // Start with some unread count
      controller.unreadCount.value = 5;

      controller.onNotificationError(Exception('stream error'));

      expect(controller.unreadCount.value, 0);
    });

    test('unreadCount stays at 0 on error when already 0', () {
      controller.onNotificationError(Exception('stream error'));

      expect(controller.unreadCount.value, 0);
    });
  });

  // ── 4. Subscription lifecycle ────────────────────────────────────

  group('Subscription lifecycle', () {
    test('should mark subscription as cancelled on cancelSubscription', () {
      controller.cancelSubscription();

      expect(controller.isSubscriptionCancelled, isTrue);
    });

    test('onClose should cancel the notification subscription', () {
      // Simulates the pattern in CompanyDashboardController.onClose()
      controller.cancelSubscription();

      expect(controller.isSubscriptionCancelled, isTrue);
    });
  });
}
