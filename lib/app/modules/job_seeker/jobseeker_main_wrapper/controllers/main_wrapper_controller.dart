import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

class MainWrapperController extends GetxController {
  final currentIndex = 2.obs;
  final unreadChats = 0.obs;

  StreamSubscription? _chatSub;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args is Map && args['initialIndex'] is int) {
      currentIndex.value = args['initialIndex'];
    }

    _listenToUnreadChats();
  }

  void _listenToUnreadChats() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    _chatSub = FirebaseDatabase.instance
        .ref()
        .child('chats')
        .orderByChild('seekerId')
        .equalTo(uid)
        .onValue
        .map((event) {
          final raw = event.snapshot.value;
          if (raw == null || raw is! Map) return 0;
          return raw.entries.where((e) {
            final chat = e.value;
            if (chat is! Map) return false;
            return ((chat['unreadSeeker'] as num?)?.toInt() ?? 0) > 0;
          }).length;
        })
        .listen(
          (c) => unreadChats.value = c,
          onError: (e) => unreadChats.value = 0,
        );
  }

  void changePage(int index) {
    currentIndex.value = index;
  }

  @override
  void onClose() {
    _chatSub?.cancel();
    super.onClose();
  }
}
