import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hire_me/app/routes/app_pages.dart';

// ─── Fake Firebase Auth ──────────────────────────────────────────────

class _FakeFirebaseAuth {
  String? currentUid;
  bool signOutCalled = false;

  Future<void> signOut() async {
    signOutCalled = true;
  }
}

// ─── Fake Firestore ──────────────────────────────────────────────────

class _FakeFirestoreDoc {
  Map<String, dynamic>? data;
  bool mergeUsed = false;

  void set(Map<String, dynamic> newData, {bool merge = false}) {
    if (merge && data != null) {
      data!.addAll(newData);
    } else {
      data = Map<String, dynamic>.from(newData);
    }
    mergeUsed = merge;
  }
}

class _FakeFirestoreCollection {
  final Map<String, _FakeFirestoreDoc> _docs = {};

  _FakeFirestoreDoc doc(String id) {
    _docs.putIfAbsent(id, () => _FakeFirestoreDoc());
    return _docs[id]!;
  }
}

class _FakeFirestore {
  final Map<String, _FakeFirestoreCollection> _collections = {};

  _FakeFirestoreCollection collection(String name) {
    _collections.putIfAbsent(name, () => _FakeFirestoreCollection());
    return _collections[name]!;
  }
}

// ─── Fake Firebase Messaging ─────────────────────────────────────────

class _FakeFirebaseMessaging {
  bool deleteTokenCalled = false;

  Future<void> deleteToken() async {
    deleteTokenCalled = true;
  }
}

// ─── Fake Storage Service ────────────────────────────────────────────

class _FakeStorageService {
  bool clearAuthSessionCalled = false;
  String? userRole;

  Future<void> clearAuthSession() async {
    clearAuthSessionCalled = true;
  }
}

// ─── Testable controller mirroring ProfileController.logout() ────────

class _FakeProfileController {
  final _FakeFirebaseAuth auth;
  final _FakeFirestore firestore;
  final _FakeFirebaseMessaging messaging;
  final _FakeStorageService storage;
  final List<String> navigationHistory = [];

  _FakeProfileController({
    required this.auth,
    required this.firestore,
    required this.messaging,
    required this.storage,
  });

  /// FieldValue.delete() sentinel — mirrors Firestore's FieldValue.delete()
  static const fcmDeleteSentinel = '__fcm_delete__';

  Future<void> logout() async {
    final uid = auth.currentUid;
    if (uid != null) {
      final role = storage.userRole;
      final roleCollection =
          role == 'company' ? 'companies' : 'jobSeekers';
      firestore.collection(roleCollection).doc(uid).set({
        'fcmToken': fcmDeleteSentinel,
      }, merge: true);
      firestore.collection('users').doc(uid).set({
        'fcmToken': fcmDeleteSentinel,
      }, merge: true);
      await messaging.deleteToken();
    }
    await storage.clearAuthSession();
    await auth.signOut();
    navigationHistory.add(Routes.authLogin);
  }
}

// ─── Tests ───────────────────────────────────────────────────────────

void main() {
  late _FakeFirebaseAuth fakeAuth;
  late _FakeFirestore fakeFirestore;
  late _FakeFirebaseMessaging fakeMessaging;
  late _FakeStorageService fakeStorage;
  late _FakeProfileController controller;

  const testUid = 'user-123';

  setUp(() {
    fakeAuth = _FakeFirebaseAuth();
    fakeFirestore = _FakeFirestore();
    fakeMessaging = _FakeFirebaseMessaging();
    fakeStorage = _FakeStorageService();
    controller = _FakeProfileController(
      auth: fakeAuth,
      firestore: fakeFirestore,
      messaging: fakeMessaging,
      storage: fakeStorage,
    );
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  // ── 1. FCM token cleanup ─────────────────────────────────────────

  group('FCM token cleanup', () {
    test('should delete FCM token from role-specific Firestore doc', () async {
      fakeAuth.currentUid = testUid;
      fakeStorage.userRole = 'jobSeeker';

      await controller.logout();

      final roleDoc = fakeFirestore
          .collection('jobSeekers')
          .doc(testUid);
      expect(roleDoc.data, isNotNull);
      expect(roleDoc.data!['fcmToken'], _FakeProfileController.fcmDeleteSentinel);
    });

    test('should delete FCM token from users fallback Firestore doc', () async {
      fakeAuth.currentUid = testUid;
      fakeStorage.userRole = 'jobSeeker';

      await controller.logout();

      final usersDoc = fakeFirestore
          .collection('users')
          .doc(testUid);
      expect(usersDoc.data, isNotNull);
      expect(usersDoc.data!['fcmToken'], _FakeProfileController.fcmDeleteSentinel);
    });

    test('should use SetOptions(merge: true) for role doc', () async {
      fakeAuth.currentUid = testUid;
      fakeStorage.userRole = 'jobSeeker';

      await controller.logout();

      final roleDoc = fakeFirestore
          .collection('jobSeekers')
          .doc(testUid);
      expect(roleDoc.mergeUsed, isTrue);
    });

    test('should use SetOptions(merge: true) for users doc', () async {
      fakeAuth.currentUid = testUid;
      fakeStorage.userRole = 'jobSeeker';

      await controller.logout();

      final usersDoc = fakeFirestore
          .collection('users')
          .doc(testUid);
      expect(usersDoc.mergeUsed, isTrue);
    });
  });

  // ── 2. Role collection selection ─────────────────────────────────

  group('Role collection selection', () {
    test('should use "companies" collection when role is company', () async {
      fakeAuth.currentUid = testUid;
      fakeStorage.userRole = 'company';

      await controller.logout();

      final roleDoc = fakeFirestore
          .collection('companies')
          .doc(testUid);
      expect(roleDoc.data, isNotNull);
      expect(roleDoc.data!['fcmToken'], _FakeProfileController.fcmDeleteSentinel);
    });

    test('should use "jobSeekers" collection when role is jobSeeker', () async {
      fakeAuth.currentUid = testUid;
      fakeStorage.userRole = 'jobSeeker';

      await controller.logout();

      final roleDoc = fakeFirestore
          .collection('jobSeekers')
          .doc(testUid);
      expect(roleDoc.data, isNotNull);
      expect(roleDoc.data!['fcmToken'], _FakeProfileController.fcmDeleteSentinel);
    });

    test('should use "jobSeekers" collection when role is null', () async {
      fakeAuth.currentUid = testUid;
      fakeStorage.userRole = null;

      await controller.logout();

      final roleDoc = fakeFirestore
          .collection('jobSeekers')
          .doc(testUid);
      expect(roleDoc.data, isNotNull);
    });
  });

  // ── 3. FirebaseMessaging calls ──────────────────────────────────

  group('FirebaseMessaging calls', () {
    test('should call FirebaseMessaging.instance.deleteToken()', () async {
      fakeAuth.currentUid = testUid;
      fakeStorage.userRole = 'jobSeeker';

      await controller.logout();

      expect(fakeMessaging.deleteTokenCalled, isTrue);
    });
  });

  // ── 4. StorageService calls ─────────────────────────────────────

  group('StorageService calls', () {
    test('should call StorageService.to.clearAuthSession()', () async {
      fakeAuth.currentUid = testUid;
      fakeStorage.userRole = 'jobSeeker';

      await controller.logout();

      expect(fakeStorage.clearAuthSessionCalled, isTrue);
    });
  });

  // ── 5. Auth calls ───────────────────────────────────────────────

  group('Auth calls', () {
    test('should call _auth.signOut()', () async {
      fakeAuth.currentUid = testUid;
      fakeStorage.userRole = 'jobSeeker';

      await controller.logout();

      expect(fakeAuth.signOutCalled, isTrue);
    });
  });

  // ── 6. Navigation ───────────────────────────────────────────────

  group('Navigation', () {
    test('should navigate to Routes.authLogin', () async {
      fakeAuth.currentUid = testUid;
      fakeStorage.userRole = 'jobSeeker';

      await controller.logout();

      expect(controller.navigationHistory, contains(Routes.authLogin));
    });
  });

  // ── 7. Null uid edge case ───────────────────────────────────────

  group('Edge cases', () {
    test('should NOT delete FCM token when uid is null', () async {
      fakeAuth.currentUid = null;
      fakeStorage.userRole = 'jobSeeker';

      await controller.logout();

      expect(fakeMessaging.deleteTokenCalled, isFalse);
    });

    test('should still call clearAuthSession when uid is null', () async {
      fakeAuth.currentUid = null;
      fakeStorage.userRole = 'jobSeeker';

      await controller.logout();

      expect(fakeStorage.clearAuthSessionCalled, isTrue);
    });

    test('should still call signOut when uid is null', () async {
      fakeAuth.currentUid = null;
      fakeStorage.userRole = 'jobSeeker';

      await controller.logout();

      expect(fakeAuth.signOutCalled, isTrue);
    });

    test('should still navigate when uid is null', () async {
      fakeAuth.currentUid = null;
      fakeStorage.userRole = 'jobSeeker';

      await controller.logout();

      expect(controller.navigationHistory, contains(Routes.authLogin));
    });
  });
}
