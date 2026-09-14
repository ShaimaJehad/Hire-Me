import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../routes/app_pages.dart';
import '../model/application_review_model.dart';

class ApplicationReviewController extends GetxController {
  late Rx<ApplicationReviewModel> applicant;

  final _firestore = FirebaseFirestore.instance;
  final _db = FirebaseDatabase.instance.ref();
  final _auth = FirebaseAuth.instance;

  final isProcessing = false.obs;
  final companyName = ''.obs;
  final readOnly = false.obs;

  String get companyId => _auth.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    _initializeApplicant();
    _fetchCompanyName();
  }

  Future<void> _fetchCompanyName() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!isClosed && doc.exists) {
        companyName.value = doc.data()?['name'] ?? '';
      }
    } catch (e) {
      debugPrint('Failed to fetch company name: $e');
    }
  }

  Future<String> _getCompanyLogoUrl() async {
    try {
      final doc = await _firestore.collection('companies').doc(companyId).get();
      if (doc.exists) {
        final data = doc.data();
        return data?['logoUrl']?.toString() ??
            data?['companyLogoUrl']?.toString() ??
            '';
      }
    } catch (e) {
      debugPrint('Failed to fetch company logo: $e');
    }
    return '';
  }

  void _initializeApplicant() {
    if (Get.arguments != null) {
      if (Get.arguments is Map<String, dynamic>) {
        final args = Get.arguments as Map<String, dynamic>;
        applicant = (args['application'] as ApplicationReviewModel).obs;
        readOnly.value = args['readOnly'] as bool? ?? false;
        return;
      }
      if (Get.arguments is ApplicationReviewModel) {
        applicant = (Get.arguments as ApplicationReviewModel).obs;
        return;
      }
    }
    applicant = ApplicationReviewModel(
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
    ).obs;
  }

  /// Accepts the application, updates its status in Firestore, creates a new
  /// chat document in Realtime Database (to match the existing chat
  /// architecture), seeds an initial auto-message, and routes to the company
  /// chat details screen.
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
      final updatedAt = DateTime.now().toIso8601String();
      await _firestore.collection('applications').doc(applicationId).set({
        'status': 'Accepted',
        'updatedAt': updatedAt,
      }, SetOptions(merge: true));

      if (isClosed) return;

      // Fallback: fetch company name if not available yet
      String resolvedCompanyName = companyName;
      if (resolvedCompanyName.isEmpty && companyId.isNotEmpty) {
        final doc = await _firestore.collection('users').doc(companyId).get();
        resolvedCompanyName = doc.data()?['name'] ?? 'Company';
      }

      if (isClosed) return;

      // 2. Create / update chat document in REALTIME DATABASE
      //    (NOT Firestore — the whole chat system lives in RTDB)
      final chatId = '${companyId}_$jobSeekerId';
      final now = DateTime.now();
      final autoMessage =
          'You have been accepted for: ${applicant.value.jobTitle}';

      final chatSnapshot = await _db.child('chats/$chatId').get();
      final chatExists = chatSnapshot.exists;

      final chatData = <String, dynamic>{
        'jobId': applicant.value.jobId,
        'lastMessage': autoMessage,
        'lastMessageTime': now.millisecondsSinceEpoch,
        'lastMessageAuthor': companyId,
        'unreadSeeker': ServerValue.increment(1),
      };

      if (!chatExists) {
        chatData['companyId'] = companyId;
        chatData['seekerId'] = jobSeekerId;
        chatData['companyName'] = resolvedCompanyName;
        chatData['seekerName'] = jobSeekerName;
        chatData['avatarUrl'] = applicant.value.avatarUrl;
        chatData['companyAvatarUrl'] = await _getCompanyLogoUrl();
        chatData['unreadCompany'] = 0;
      }

      await _db.child('chats/$chatId').update(chatData);

      if (isClosed) return;

      // 4. Add auto-message in RTDB messages sub-node
      final msgRef = _db.child('chats/$chatId/messages').push();
      await msgRef.set({
        'text': autoMessage,
        'senderId': companyId,
        'time': now.millisecondsSinceEpoch,
        'isRead': false,
      });

      if (isClosed) return;

      // 5. Route to company chat details
      Get.offNamed(
        Routes.companyChatDetails,
        arguments: {
          'chatId': chatId,
          'chatName': jobSeekerName,
          'avatarUrl': applicant.value.avatarUrl,
          'seekerId': jobSeekerId,
          'companyId': companyId,
        },
      );
    } catch (e, s) {
      debugPrint('acceptApplication error: $e\n$s');
      if (!isClosed) {
        _showError('Failed to accept application. Please try again.');
      }
    } finally {
      if (!isClosed) isProcessing.value = false;
    }
  }

  /// Rejects the application by updating its status and navigates back.
  Future<void> rejectApplication(String applicationId) async {
    isProcessing.value = true;

    try {
      await _firestore.collection('applications').doc(applicationId).set({
        'status': 'Rejected',
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      if (isClosed) return;

      Get.back();
    } catch (e, s) {
      debugPrint('rejectApplication error: $e\n$s');
      if (!isClosed) {
        _showError('Failed to reject application. Please try again.');
      }
    } finally {
      if (!isClosed) isProcessing.value = false;
    }
  }

  void viewApplicantCV(String? cvUrl) {
    final url = cvUrl?.isNotEmpty == true
        ? cvUrl!
        : 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';

    Get.toNamed(Routes.pdfViewer, arguments: url);
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFEF4444),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}
