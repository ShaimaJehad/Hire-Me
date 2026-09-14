import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

class CompanyMainWrapperController extends GetxController {
  final currentIndex = 2.obs; // Dashboard default
  final unreadChats = 0.obs;

  StreamSubscription? _chatSub;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    if (args is Map<String, dynamic>) {
      final initialIndex = args['initialIndex'];

      if (initialIndex is int && initialIndex >= 0 && initialIndex <= 4) {
        currentIndex.value = initialIndex;
      }
    }

    _listenToUnreadChats();
  }

  void _listenToUnreadChats() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _chatSub = FirebaseDatabase.instance
        .ref()
        .child('chats')
        .orderByChild('companyId')
        .equalTo(uid)
        .onValue
        .map((event) {
          final raw = event.snapshot.value;

          if (raw == null || raw is! Map) return 0;

          return raw.entries.where((entry) {
            final chat = entry.value;

            if (chat is! Map) return false;

            return ((chat['unreadCompany'] as num?)?.toInt() ?? 0) > 0;
          }).length;
        })
        .listen(
          (count) => unreadChats.value = count,
          onError: (_) => unreadChats.value = 0,
        );
  }

  void changePage(int index) {
    if (index == currentIndex.value) return;
    currentIndex.value = index;
  }

  void goToDashboard() {
    currentIndex.value = 2;
  }

  void goToPostJob() {
    currentIndex.value = 3;
  }

  void goToProfile() {
    currentIndex.value = 4;
  }

  @override
  void onClose() {
    _chatSub?.cancel();
    super.onClose();
  }
}
