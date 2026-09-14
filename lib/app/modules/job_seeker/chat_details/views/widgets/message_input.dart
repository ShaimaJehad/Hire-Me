import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/utils/app_color.dart';
import '../../controllers/chat_details_controller.dart';
import 'send_button.dart';

class MessageInput extends StatelessWidget {
  final ChatDetailsController controller;
  const MessageInput({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.white,
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.background,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColor.divider),
              ),
              child: TextField(
                controller: controller.messageController,
                onChanged: controller.onTextChanged,
                maxLines: 4,
                minLines: 1,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColor.textPrimary,
                ),
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    color: AppColor.textSecondary,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Obx(
            () => SendButton(
              hasText: controller.hasText.value,
              onTap: controller.sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
