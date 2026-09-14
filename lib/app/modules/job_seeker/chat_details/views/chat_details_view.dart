import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'widgets/chat_details_appbar.dart';
import 'widgets/message_input.dart';
import 'widgets/message_list.dart';
import '../../../../../core/utils/app_color.dart';

import '../controllers/chat_details_controller.dart';

class ChatDetailsView extends StatelessWidget {
  const ChatDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final chatId = args is Map<String, dynamic>
        ? (args['chatId'] as String? ?? '')
        : args is String
            ? args
            : '';
    final controller = Get.find<ChatDetailsController>(
      tag: chatId.isNotEmpty ? chatId : null,
    );

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: ChatDetailsAppbar(
        name: controller.chatName,
        avatarUrl: controller.chatAvatarUrl,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return MessagesList(controller: controller);
            }),
          ),
          MessageInput(controller: controller),
        ],
      ),
    );
  }
}
