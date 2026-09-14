import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../../../../core/helper/data_helper.dart';
import '../../controllers/company_chat_details_controller.dart';
import '../../../../job_seeker/chat_details/views/widgets/data_divider.dart';
import '../../../../job_seeker/chat_details/views/widgets/message_bubble.dart';

class CompanyMessagesList extends StatelessWidget {
  final CompanyChatDetailsController controller;
  const CompanyMessagesList({required this.controller, super.key});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final lastSentIndex = controller.messages.lastIndexWhere(
        (m) => controller.isMe(m.senderId),
      );

      final selectedId = controller.selectedMessageId.value;

      return ListView.builder(
        controller: controller.scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: controller.messages.length,
        itemBuilder: (_, index) {
          final msg = controller.messages[index];
          return Column(
            children: [
              if (controller.showDateDivider(index))
                DateDivider(label: formatDate(msg.time)),
              MessageBubble(
                message: msg,
                time: formatTime(msg.time),
                isMe: controller.isMe(msg.senderId),
                isSeen:
                    controller.isMe(msg.senderId) &&
                    index == lastSentIndex &&
                    controller.otherLastSeen.value >=
                        msg.time.millisecondsSinceEpoch,
                senderName: controller.chatName,
                senderAvatarUrl: controller.chatAvatarUrl,
                showTime: selectedId == msg.id,
                onTap: () => controller.toggleMessageTime(msg.id),
              ),
            ],
          );
        },
      );
    });
  }
}
