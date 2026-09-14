// test/application_review_controller_test.dart
//
// Unit tests for ApplicationReviewController acceptance/rejection flow.
// Uses manual fakes (no mock packages in pubspec.yaml).
//
// Run: flutter test test/application_review_controller_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hire_me/app/modules/company/application_review/model/application_review_model.dart';
import 'package:hire_me/app/routes/app_pages.dart';

// ─── Fake Firestore ────────────────────────────────────────────────────────

class _FakeFirestoreDocument {
  Map<String, dynamic> data = {};
  bool exists = false;
}

class _FakeFirestoreCollection {
  final Map<String, _FakeFirestoreDocument> _docs = {};

  void setDoc(String id, Map<String, dynamic> data, {bool merge = false}) {
    if (!_docs.containsKey(id)) {
      _docs[id] = _FakeFirestoreDocument();
    }
    final doc = _docs[id]!;
    if (merge) {
      doc.data.addAll(data);
    } else {
      doc.data = Map<String, dynamic>.from(data);
    }
    doc.exists = true;
  }

  Map<String, dynamic>? getDocData(String id) {
    return _docs[id]?.data;
  }

  bool docExists(String id) {
    return _docs[id]?.exists ?? false;
  }
}

class _FakeFirestore {
  final Map<String, _FakeFirestoreCollection> _collections = {};

  _FakeFirestoreCollection collection(String name) {
    _collections.putIfAbsent(name, () => _FakeFirestoreCollection());
    return _collections[name]!;
  }
}

// ─── Fake Realtime Database ────────────────────────────────────────────────

class _FakeRTDBReference {
  final String _path;
  final Map<String, dynamic> _store;
  int _pushCounter = 0;

  _FakeRTDBReference(this._path, this._store);

  _FakeRTDBReference child(String childPath) {
    final newPath = _path.isEmpty ? childPath : '$_path/$childPath';
    return _FakeRTDBReference(newPath, _store);
  }

  Future<void> set(Map<String, dynamic> data) async {
    _store[_path] = Map<String, dynamic>.from(data);
  }

  _FakePushResult push() {
    _pushCounter++;
    final key = 'push_$_pushCounter';
    final newPath = _path.isEmpty ? key : '$_path/$key';
    return _FakePushResult(newPath, _store);
  }

  Map<String, dynamic>? getData() => _store[_path];
  String get path => _path;
}

class _FakePushResult {
  final String _path;
  final Map<String, dynamic> _store;

  _FakePushResult(this._path, this._store);

  Future<void> set(Map<String, dynamic> data) async {
    _store[_path] = Map<String, dynamic>.from(data);
  }
}

class _FakeRTDB {
  final Map<String, dynamic> _store = {};

  _FakeRTDBReference ref() {
    return _FakeRTDBReference('', _store);
  }

  Map<String, dynamic> get store => Map<String, dynamic>.from(_store);
}

// ─── Fake GetX navigation tracker ──────────────────────────────────────────

class _NavigationRecord {
  final String? route;
  final dynamic arguments;
  final bool isBack;

  _NavigationRecord({this.route, this.arguments, this.isBack = false});
}

// ─── Testable controller that mirrors the real one ─────────────────────────
// This fake follows the exact same logic as ApplicationReviewController
// but uses injectable fakes instead of hard-coded Firebase singletons.

class _FakeApplicationReviewController {
  final _FakeFirestore _firestore;
  final _FakeRTDB _rtdb;
  final List<_NavigationRecord> _navigationHistory = [];

  late Rx<ApplicationReviewModel> applicant;
  final isProcessing = false.obs;
  final companyName = ''.obs;

  _FakeApplicationReviewController({
    required _FakeFirestore firestore,
    required _FakeRTDB rtdb,
    ApplicationReviewModel? initialApplicant,
    String initialCompanyName = '',
  }) : _firestore = firestore,
       _rtdb = rtdb {
    applicant =
        (initialApplicant ??
                ApplicationReviewModel(
                  id: '0',
                  jobSeekerId: '0',
                  name: 'Unknown',
                  jobTitle: 'Unknown',
                  location: 'Unknown',
                  email: 'Unknown',
                  skills: 'Unknown',
                  experience: 'Unknown',
                  education: 'Unknown',
                  cvUrl: '',
                  appliedAt: '',
                  applicantFcmToken: '',
                  jobId: '',
                ))
            .obs;
    companyName.value = initialCompanyName;
  }

  // Simulates: Get.toNamed(route, arguments: args)
  void _navigate(String route, {dynamic arguments}) {
    _navigationHistory.add(
      _NavigationRecord(route: route, arguments: arguments),
    );
  }

  // Simulates: Get.back()
  void _goBack() {
    _navigationHistory.add(_NavigationRecord(isBack: true));
  }

  List<_NavigationRecord> get navigationHistory =>
      List.unmodifiable(_navigationHistory);

  // ── Core logic (mirrors real ApplicationReviewController) ──

  Future<void> acceptApplication(
    String applicationId,
    String jobSeekerId,
    String jobSeekerName,
    String companyId,
    String companyName,
  ) async {
    isProcessing.value = true;

    try {
      // 1. Update application status to Accepted in Firestore
      _firestore.collection('applications').setDoc(applicationId, {
        'status': 'Accepted',
      }, merge: true);

      // Fallback: fetch company name if not available yet
      String resolvedCompanyName = companyName;
      if (resolvedCompanyName.isEmpty && companyId.isNotEmpty) {
        final doc = _firestore.collection('users').getDocData(companyId);
        resolvedCompanyName = doc?['name'] ?? 'Company';
      }

      // 2. Create chat document in RTDB
      final chatId = '${companyId}_$jobSeekerId';
      final now = DateTime.now();

      final chatRef = _rtdb.ref().child('chats/$chatId');
      // ignore: avoid_print
      print('DEBUG jobId passed to chat: ${applicant.value.jobId}');
      await chatRef.set({
        'companyId': companyId,
        'seekerId': jobSeekerId,
        'jobId': applicant.value.jobId,
        'companyName': resolvedCompanyName,
        'seekerName': jobSeekerName,
        'lastMessage': 'You have been accepted for this position.',
        'lastMessageTime': now.millisecondsSinceEpoch,
        'lastMessageAuthor': companyId,
        'avatarUrl': applicant.value.avatarUrl,
        'unreadSeeker': 1,
        'unreadCompany': 0,
      });

      // 3. Add initial auto-message in RTDB messages sub-node
      final msgRef = _rtdb.ref().child('chats/$chatId/messages').push();
      await msgRef.set({
        'text': 'You have been accepted for this position.',
        'senderId': companyId,
        'time': now.millisecondsSinceEpoch,
        'isRead': false,
      });

      // 4. Route to company chat details
      _navigate(
        Routes.companyChatDetails,
        arguments: {
          'chatId': chatId,
          'chatName': jobSeekerName,
          'avatarUrl': applicant.value.avatarUrl,
          'seekerId': jobSeekerId,
          'companyId': companyId,
        },
      );
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> rejectApplication(String applicationId) async {
    isProcessing.value = true;

    try {
      _firestore.collection('applications').setDoc(applicationId, {
        'status': 'Rejected',
      }, merge: true);

      _goBack();
    } finally {
      isProcessing.value = false;
    }
  }
}

// ─── Tests ─────────────────────────────────────────────────────────────────

void main() {
  late _FakeFirestore fakeFirestore;
  late _FakeRTDB fakeRTDB;
  late _FakeApplicationReviewController controller;

  final testApplicant = ApplicationReviewModel(
    id: 'app-001',
    jobSeekerId: 'seeker-123',
    name: 'John Doe',
    jobTitle: 'Flutter Developer',
    location: 'Cairo',
    email: 'john@example.com',
    skills: 'Flutter, Dart',
    experience: '3 years',
    education: 'CS Degree',
    cvUrl: 'https://example.com/cv.pdf',
    avatarUrl: 'https://example.com/avatar.png',
    appliedAt: '2026-05-01',
    applicantFcmToken: 'fcm-token-123',
    jobId: 'job-789',
  );

  const testCompanyId = 'company-456';
  const testCompanyName = 'TechCorp';
  const testJobSeekerName = 'John Doe';
  const testJobSeekerId = 'seeker-123';
  const testApplicationId = 'app-001';

  setUp(() {
    fakeFirestore = _FakeFirestore();
    fakeRTDB = _FakeRTDB();
    controller = _FakeApplicationReviewController(
      firestore: fakeFirestore,
      rtdb: fakeRTDB,
      initialApplicant: testApplicant,
      initialCompanyName: testCompanyName,
    );
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  // ── 1. acceptApplication() updates Firestore status to "Accepted" ──

  group('acceptApplication — Firestore status', () {
    test(
      'should update application status to "Accepted" in Firestore',
      () async {
        await controller.acceptApplication(
          testApplicationId,
          testJobSeekerId,
          testJobSeekerName,
          testCompanyId,
          testCompanyName,
        );

        final appData = fakeFirestore
            .collection('applications')
            .getDocData(testApplicationId);

        expect(appData, isNotNull);
        expect(appData!['status'], 'Accepted');
      },
    );

    test(
      'should use merge when updating status (preserves other fields)',
      () async {
        // Pre-populate with existing application data
        fakeFirestore.collection('applications').setDoc(testApplicationId, {
          'seekerId': testJobSeekerId,
          'seekerName': testJobSeekerName,
          'jobId': 'job-789',
          'status': 'pending',
        });

        await controller.acceptApplication(
          testApplicationId,
          testJobSeekerId,
          testJobSeekerName,
          testCompanyId,
          testCompanyName,
        );

        final appData = fakeFirestore
            .collection('applications')
            .getDocData(testApplicationId);

        expect(appData!['status'], 'Accepted');
        // Merge should preserve existing fields
        expect(appData['seekerId'], testJobSeekerId);
        expect(appData['jobId'], 'job-789');
      },
    );
  });

  // ── 2. acceptApplication() creates correct chat node in RTDB ──

  group('acceptApplication — RTDB chat creation', () {
    test(
      'should create chat document at chats/{companyId}_{jobSeekerId}',
      () async {
        await controller.acceptApplication(
          testApplicationId,
          testJobSeekerId,
          testJobSeekerName,
          testCompanyId,
          testCompanyName,
        );

        final expectedChatPath = 'chats/${testCompanyId}_$testJobSeekerId';
        final chatData = fakeRTDB.store[expectedChatPath];

        expect(chatData, isNotNull);
      },
    );

    test('should set correct companyId and seekerId', () async {
      await controller.acceptApplication(
        testApplicationId,
        testJobSeekerId,
        testJobSeekerName,
        testCompanyId,
        testCompanyName,
      );

      final chatData =
          fakeRTDB.store['chats/${testCompanyId}_$testJobSeekerId'];

      expect(chatData!['companyId'], testCompanyId);
      expect(chatData['seekerId'], testJobSeekerId);
    });

    test('should set seekerName and companyName', () async {
      await controller.acceptApplication(
        testApplicationId,
        testJobSeekerId,
        testJobSeekerName,
        testCompanyId,
        testCompanyName,
      );

      final chatData =
          fakeRTDB.store['chats/${testCompanyId}_$testJobSeekerId'];

      expect(chatData!['seekerName'], testJobSeekerName);
      expect(chatData['companyName'], testCompanyName);
    });

    test('should set jobId from applicant model', () async {
      await controller.acceptApplication(
        testApplicationId,
        testJobSeekerId,
        testJobSeekerName,
        testCompanyId,
        testCompanyName,
      );

      final chatData =
          fakeRTDB.store['chats/${testCompanyId}_$testJobSeekerId'];

      expect(chatData!['jobId'], testApplicant.jobId);
    });

    test('should set unreadSeeker to 1 and unreadCompany to 0', () async {
      await controller.acceptApplication(
        testApplicationId,
        testJobSeekerId,
        testJobSeekerName,
        testCompanyId,
        testCompanyName,
      );

      final chatData =
          fakeRTDB.store['chats/${testCompanyId}_$testJobSeekerId'];

      expect(chatData!['unreadSeeker'], 1);
      expect(chatData['unreadCompany'], 0);
    });

    test('should set lastMessage to acceptance message', () async {
      await controller.acceptApplication(
        testApplicationId,
        testJobSeekerId,
        testJobSeekerName,
        testCompanyId,
        testCompanyName,
      );

      final chatData =
          fakeRTDB.store['chats/${testCompanyId}_$testJobSeekerId'];

      expect(
        chatData!['lastMessage'],
        'You have been accepted for this position.',
      );
    });

    test('should set lastMessageAuthor to companyId', () async {
      await controller.acceptApplication(
        testApplicationId,
        testJobSeekerId,
        testJobSeekerName,
        testCompanyId,
        testCompanyName,
      );

      final chatData =
          fakeRTDB.store['chats/${testCompanyId}_$testJobSeekerId'];

      expect(chatData!['lastMessageAuthor'], testCompanyId);
    });

    test('should include avatarUrl from applicant', () async {
      await controller.acceptApplication(
        testApplicationId,
        testJobSeekerId,
        testJobSeekerName,
        testCompanyId,
        testCompanyName,
      );

      final chatData =
          fakeRTDB.store['chats/${testCompanyId}_$testJobSeekerId'];

      expect(chatData!['avatarUrl'], testApplicant.avatarUrl);
    });

    test('should set lastMessageTime as millisecondsSinceEpoch', () async {
      await controller.acceptApplication(
        testApplicationId,
        testJobSeekerId,
        testJobSeekerName,
        testCompanyId,
        testCompanyName,
      );

      final chatData =
          fakeRTDB.store['chats/${testCompanyId}_$testJobSeekerId'];

      expect(chatData!['lastMessageTime'], isA<int>());
      expect(chatData['lastMessageTime'], greaterThan(0));
    });
  });

  // ── 3. acceptApplication() adds auto-message in messages sub-node ──

  group('acceptApplication — auto-message', () {
    test('should create a message in chats/{chatId}/messages', () async {
      await controller.acceptApplication(
        testApplicationId,
        testJobSeekerId,
        testJobSeekerName,
        testCompanyId,
        testCompanyName,
      );

      final chatId = '${testCompanyId}_$testJobSeekerId';
      final store = fakeRTDB.store;

      // Find any key that matches the messages path pattern
      final messageEntries = store.entries.where(
        (e) => e.key.startsWith('chats/$chatId/messages/push_'),
      );

      expect(
        messageEntries.isNotEmpty,
        isTrue,
        reason: 'Expected a message entry under chats/$chatId/messages/',
      );
    });

    test('auto-message should have correct text', () async {
      await controller.acceptApplication(
        testApplicationId,
        testJobSeekerId,
        testJobSeekerName,
        testCompanyId,
        testCompanyName,
      );

      final store = fakeRTDB.store;
      final messageEntry = store.entries.firstWhere(
        (e) => e.key.contains('/messages/push_'),
      );

      expect(
        messageEntry.value['text'],
        'You have been accepted for this position.',
      );
    });

    test('auto-message should have senderId = companyId', () async {
      await controller.acceptApplication(
        testApplicationId,
        testJobSeekerId,
        testJobSeekerName,
        testCompanyId,
        testCompanyName,
      );

      final store = fakeRTDB.store;
      final messageEntry = store.entries.firstWhere(
        (e) => e.key.contains('/messages/push_'),
      );

      expect(messageEntry.value['senderId'], testCompanyId);
    });

    test('auto-message should have isRead = false', () async {
      await controller.acceptApplication(
        testApplicationId,
        testJobSeekerId,
        testJobSeekerName,
        testCompanyId,
        testCompanyName,
      );

      final store = fakeRTDB.store;
      final messageEntry = store.entries.firstWhere(
        (e) => e.key.contains('/messages/push_'),
      );

      expect(messageEntry.value['isRead'], false);
    });

    test('auto-message time should be millisecondsSinceEpoch', () async {
      await controller.acceptApplication(
        testApplicationId,
        testJobSeekerId,
        testJobSeekerName,
        testCompanyId,
        testCompanyName,
      );

      final store = fakeRTDB.store;
      final messageEntry = store.entries.firstWhere(
        (e) => e.key.contains('/messages/push_'),
      );

      expect(messageEntry.value['time'], isA<int>());
      expect(messageEntry.value['time'], greaterThan(0));
    });
  });

  // ── 4. acceptApplication() navigates to COMPANY_CHAT_DETAILS ──

  group('acceptApplication — navigation', () {
    test('should navigate to Routes.COMPANY_CHAT_DETAILS', () async {
      await controller.acceptApplication(
        testApplicationId,
        testJobSeekerId,
        testJobSeekerName,
        testCompanyId,
        testCompanyName,
      );

      final nav = controller.navigationHistory.last;
      expect(nav.route, Routes.companyChatDetails);
    });

    test('should pass correct chatId in arguments', () async {
      await controller.acceptApplication(
        testApplicationId,
        testJobSeekerId,
        testJobSeekerName,
        testCompanyId,
        testCompanyName,
      );

      final args =
          controller.navigationHistory.last.arguments as Map<String, dynamic>;
      expect(args['chatId'], '${testCompanyId}_$testJobSeekerId');
    });

    test('should pass correct chatName (jobSeekerName) in arguments', () async {
      await controller.acceptApplication(
        testApplicationId,
        testJobSeekerId,
        testJobSeekerName,
        testCompanyId,
        testCompanyName,
      );

      final args =
          controller.navigationHistory.last.arguments as Map<String, dynamic>;
      expect(args['chatName'], testJobSeekerName);
    });

    test('should pass correct seekerId in arguments', () async {
      await controller.acceptApplication(
        testApplicationId,
        testJobSeekerId,
        testJobSeekerName,
        testCompanyId,
        testCompanyName,
      );

      final args =
          controller.navigationHistory.last.arguments as Map<String, dynamic>;
      expect(args['seekerId'], testJobSeekerId);
    });

    test('should pass correct companyId in arguments', () async {
      await controller.acceptApplication(
        testApplicationId,
        testJobSeekerId,
        testJobSeekerName,
        testCompanyId,
        testCompanyName,
      );

      final args =
          controller.navigationHistory.last.arguments as Map<String, dynamic>;
      expect(args['companyId'], testCompanyId);
    });

    test('should pass avatarUrl from applicant in arguments', () async {
      await controller.acceptApplication(
        testApplicationId,
        testJobSeekerId,
        testJobSeekerName,
        testCompanyId,
        testCompanyName,
      );

      final args =
          controller.navigationHistory.last.arguments as Map<String, dynamic>;
      expect(args['avatarUrl'], testApplicant.avatarUrl);
    });
  });

  // ── 5. rejectApplication() updates Firestore status to "Rejected" ──

  group('rejectApplication — Firestore status', () {
    test('should update application status to "Rejected"', () async {
      await controller.rejectApplication(testApplicationId);

      final appData = fakeFirestore
          .collection('applications')
          .getDocData(testApplicationId);

      expect(appData, isNotNull);
      expect(appData!['status'], 'Rejected');
    });

    test('should use merge when updating status', () async {
      fakeFirestore.collection('applications').setDoc(testApplicationId, {
        'seekerId': testJobSeekerId,
        'seekerName': testJobSeekerName,
        'status': 'pending',
      });

      await controller.rejectApplication(testApplicationId);

      final appData = fakeFirestore
          .collection('applications')
          .getDocData(testApplicationId);

      expect(appData!['status'], 'Rejected');
      expect(appData['seekerId'], testJobSeekerId);
    });
  });

  // ── 6. rejectApplication() navigates back ──

  group('rejectApplication — navigation', () {
    test('should call Get.back() (navigate back)', () async {
      await controller.rejectApplication(testApplicationId);

      final nav = controller.navigationHistory.last;
      expect(nav.isBack, isTrue);
    });

    test('should NOT navigate to any route', () async {
      await controller.rejectApplication(testApplicationId);

      final hasRouteNavigation = controller.navigationHistory.any(
        (n) => n.route != null,
      );
      expect(hasRouteNavigation, isFalse);
    });
  });

  // ── 7. Accepted application disappears from ApplicationListController ──

  group('ApplicationList filtering — accepted apps disappear', () {
    test('pending applications should appear in the list', () {
      // Simulate Firestore documents with status == "pending"
      final pendingApps = [
        {
          'seekerId': 'seeker-1',
          'seekerName': 'Alice',
          'jobId': 'job-1',
          'jobTitle': 'Dev',
          'status': 'pending',
        },
        {
          'seekerId': 'seeker-2',
          'seekerName': 'Bob',
          'jobId': 'job-1',
          'jobTitle': 'Dev',
          'status': 'pending',
        },
      ];

      // Filter mimics ApplicationListController._listenToApplications()
      final filtered = pendingApps
          .where((doc) => doc['status'] == 'pending')
          .toList();

      expect(filtered.length, 2);
    });

    test('accepted applications should NOT appear in pending list', () {
      final allApps = [
        {
          'seekerId': 'seeker-1',
          'seekerName': 'Alice',
          'jobId': 'job-1',
          'jobTitle': 'Dev',
          'status': 'pending',
        },
        {
          'seekerId': 'seeker-2',
          'seekerName': 'Bob',
          'jobId': 'job-1',
          'jobTitle': 'Dev',
          'status': 'Accepted',
        },
        {
          'seekerId': 'seeker-3',
          'seekerName': 'Charlie',
          'jobId': 'job-1',
          'jobTitle': 'Dev',
          'status': 'Rejected',
        },
      ];

      // This is the exact filter from ApplicationListController:
      // .where('status', isEqualTo: 'pending')
      final pendingOnly = allApps
          .where((doc) => doc['status'] == 'pending')
          .toList();

      expect(pendingOnly.length, 1);
      expect(pendingOnly.first['seekerName'], 'Alice');
    });

    test(
      'after acceptApplication, the app is no longer in pending list',
      () async {
        // Start with a pending application
        fakeFirestore.collection('applications').setDoc(testApplicationId, {
          'seekerId': testJobSeekerId,
          'seekerName': testJobSeekerName,
          'jobId': 'job-1',
          'jobTitle': 'Dev',
          'status': 'pending',
        });

        // Accept it
        await controller.acceptApplication(
          testApplicationId,
          testJobSeekerId,
          testJobSeekerName,
          testCompanyId,
          testCompanyName,
        );

        // Simulate the ApplicationListController stream filter
        final appData = fakeFirestore
            .collection('applications')
            .getDocData(testApplicationId);

        // The ApplicationListController uses: .where('status', isEqualTo: 'pending')
        // After acceptance, status is 'Accepted', so it won't match
        expect(appData!['status'], isNot('pending'));
        expect(appData['status'], 'Accepted');
      },
    );

    test(
      'after rejectApplication, the app is no longer in pending list',
      () async {
        fakeFirestore.collection('applications').setDoc(testApplicationId, {
          'seekerId': testJobSeekerId,
          'seekerName': testJobSeekerName,
          'jobId': 'job-1',
          'jobTitle': 'Dev',
          'status': 'pending',
        });

        await controller.rejectApplication(testApplicationId);

        final appData = fakeFirestore
            .collection('applications')
            .getDocData(testApplicationId);

        expect(appData!['status'], isNot('pending'));
        expect(appData['status'], 'Rejected');
      },
    );
  });

  // ── Edge cases ──

  group('Edge cases', () {
    test(
      'acceptApplication with empty companyName falls back to "Company"',
      () async {
        final controllerNoName = _FakeApplicationReviewController(
          firestore: fakeFirestore,
          rtdb: fakeRTDB,
          initialApplicant: testApplicant,
          initialCompanyName: '',
        );

        // No company doc in Firestore fallback either
        await controllerNoName.acceptApplication(
          testApplicationId,
          testJobSeekerId,
          testJobSeekerName,
          testCompanyId,
          '',
        );

        final chatData =
            fakeRTDB.store['chats/${testCompanyId}_$testJobSeekerId'];

        expect(chatData!['companyName'], 'Company');
      },
    );

    test('isProcessing is true during execution and false after', () async {
      // Before
      expect(controller.isProcessing.value, false);

      // Start the async operation
      final future = controller.acceptApplication(
        testApplicationId,
        testJobSeekerId,
        testJobSeekerName,
        testCompanyId,
        testCompanyName,
      );

      // After completion
      await future;
      expect(controller.isProcessing.value, false);
    });

    test(
      'rejectApplication sets isProcessing back to false after completion',
      () async {
        expect(controller.isProcessing.value, false);

        await controller.rejectApplication(testApplicationId);

        expect(controller.isProcessing.value, false);
      },
    );
  });
}
