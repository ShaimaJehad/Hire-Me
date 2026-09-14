import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../model/chat_model.dart';
import '../services/chat_services.dart';

class ChatController extends GetxController {
  final ChatService _chatService = ChatService();
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  final searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxList<ChatModel> allChats = <ChatModel>[].obs;
  final RxBool isLoading = true.obs;
  StreamSubscription? _chatsSub;

  @override
  void onInit() {
    super.onInit();

    _listenToChats();
  }

  void _listenToChats() {
    _chatsSub = _chatService
        .getChats(currentUserId)
        .listen(
          (chats) {
            allChats.value = chats;
            isLoading.value = false;
          },
          onError: (e) {
            log('Chat stream error: $e');
            isLoading.value = false;
          },
        );
  }

  List<ChatModel> get filteredChats {
    if (searchQuery.value.isEmpty) return allChats;
    return allChats
        .where(
          (c) => c
              .otherName(currentUserId)
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase()),
        )
        .toList();
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
  }

  @override
  void onClose() {
    _chatsSub?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
