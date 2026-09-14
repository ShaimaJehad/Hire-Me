import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'widgets/company_message_input.dart';
import 'widgets/company_message_list.dart';
import '../../../job_seeker/chat_details/views/widgets/chat_details_appbar.dart';
import '../../../../../core/utils/app_color.dart';

import '../controllers/company_chat_details_controller.dart';

class CompanyChatDetailsView extends StatelessWidget {
  const CompanyChatDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final chatId = args is Map<String, dynamic>
        ? (args['chatId'] as String? ?? '')
        : args is String
            ? args
            : '';
    final controller = Get.find<CompanyChatDetailsController>(
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
                return const Center(child: CircularProgressIndicator());
              }
              return CompanyMessagesList(controller: controller);
            }),
          ),
          CompanyMessageInput(controller: controller),
        ],
      ),
    );
  }
}
