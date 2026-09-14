import 'package:get/get.dart';

import '../controllers/chat_details_controller.dart';

class ChatDetailsBinding extends Bindings {
  @override
  void dependencies() {
    String chatName = 'Chat';
    String chatAvatarUrl = '';
    String chatId = '';
    String seekerId = '';
    String companyId = '';

    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      chatName = args['chatName'] as String? ?? 'Chat';
      chatAvatarUrl = args['avatarUrl'] as String? ?? '';
      chatId = args['chatId'] as String? ?? '';
      seekerId = args['seekerId'] as String? ?? '';
      companyId = args['companyId'] as String? ?? '';
    } else if (args is String) {
      chatId = args;
    }

    Get.lazyPut<ChatDetailsController>(
      () => ChatDetailsController(
        chatName: chatName,
        chatAvatarUrl: chatAvatarUrl,
        chatId: chatId,
        seekerId: seekerId,
        companyId: companyId,
      ),
      tag: chatId.isNotEmpty ? chatId : null,
    );
  }
}
