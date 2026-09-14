import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../services/notification_service.dart';
import '../../../job_seeker/chat/services/chat_services.dart';
import '../../../job_seeker/chat_details/model/chat_details_model.dart';

class CompanyChatDetailsController extends GetxController {
  final String chatId;
  final String chatName;
  final String chatAvatarUrl;
  String seekerId;
  String companyId;

  CompanyChatDetailsController({
    required this.chatId,
    required this.chatName,
    this.chatAvatarUrl = '',
    required this.seekerId,
    required this.companyId,
  });

  final ChatService _chatService = ChatService();
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final messageController = TextEditingController();
  final scrollController = ScrollController();
  final RxBool hasText = false.obs;
  final RxBool isLoading = true.obs;
  final RxList<ChatDetailsModel> messages = <ChatDetailsModel>[].obs;
  final RxInt otherLastSeen = 0.obs;
  final RxString selectedMessageId = ''.obs;
  bool isMe(String senderId) => senderId == currentUserId;

  StreamSubscription? _messageSub;
  StreamSubscription? _seenSub;

  @override
  void onInit() {
    super.onInit();
    NotificationService.currentScreen.value = 'chat_details';
    _initChat();
  }

  Future<void> _initChat() async {
    await _loadChatMetadata();
    await _setActivePresence(true);

    _listenToMessages();
    _markChatAsRead();
    _markSeen();
    _listenToOtherSeen();
  }

  Future<void> _loadChatMetadata() async {
    if (seekerId.isNotEmpty && companyId.isNotEmpty) return;
    final snapshot = await FirebaseDatabase.instance
        .ref()
        .child('chats/$chatId')
        .get();
    final data = snapshot.value as Map<dynamic, dynamic>?;
    if (data == null) return;
    if (seekerId.isEmpty) seekerId = data['seekerId'] as String? ?? '';
    if (companyId.isEmpty) companyId = data['companyId'] as String? ?? '';
  }

  void _listenToMessages() {
    _messageSub = _chatService.getMessages(chatId).listen(
      (msgs) {
        messages.value = msgs;
        isLoading.value = false;
        _markSeen();
        _markChatAsRead();

        Future.delayed(const Duration(milliseconds: 100), () {
          if (scrollController.hasClients) {
            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      },
      onError: (_) => isLoading.value = false,
    );
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    final message = ChatDetailsModel(
      id: '',
      text: text,
      senderId: currentUserId,
      time: DateTime.now(),
    );

    messageController.clear();
    hasText.value = false;

    await _chatService.sendMessage(
      chatId,
      message,
      seekerId: seekerId,
      companyId: companyId,
      currentUserId: currentUserId,
    );
  }

  void onTextChanged(String value) {
    hasText.value = value.trim().isNotEmpty;
  }

  bool showDateDivider(int index) {
    if (index == 0) return true;
    final prev = messages[index - 1].time;
    final curr = messages[index].time;
    return prev.day != curr.day;
  }

  Future<void> _markChatAsRead() async {
    final isSeeker = currentUserId == seekerId;
    final unreadField = isSeeker ? 'unreadSeeker' : 'unreadCompany';

    await FirebaseDatabase.instance
        .ref()
        .child('chats/$chatId/$unreadField')
        .set(0);
  }

  Future<void> _setActivePresence(bool isActive) async {
    final isSeeker = currentUserId == seekerId;
    final field = isSeeker ? 'activeSeeker' : 'activeCompany';
    await FirebaseDatabase.instance
        .ref()
        .child('chats/$chatId/$field')
        .set(isActive);
  }

  Future<void> _markSeen() async {
    await FirebaseDatabase.instance
        .ref()
        .child('chats/$chatId/meta/lastSeenBy/$currentUserId')
        .set(DateTime.now().millisecondsSinceEpoch);
  }

  void _listenToOtherSeen() {
    final otherId = currentUserId == seekerId ? companyId : seekerId;

    _seenSub = FirebaseDatabase.instance
        .ref()
        .child('chats/$chatId/meta/lastSeenBy/$otherId')
        .onValue
        .listen(
          (event) {
            final val = event.snapshot.value;
            otherLastSeen.value = (val as num?)?.toInt() ?? 0;
          },
          onError: (_) => otherLastSeen.value = 0,
        );
  }

  void toggleMessageTime(String messageId) {
    if (selectedMessageId.value == messageId) {
      selectedMessageId.value = '';
    } else {
      selectedMessageId.value = messageId;
    }
  }

  @override
  void onClose() {
    _setActivePresence(false);
    NotificationService.currentScreen.value = '';
    _messageSub?.cancel();
    _seenSub?.cancel();
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
