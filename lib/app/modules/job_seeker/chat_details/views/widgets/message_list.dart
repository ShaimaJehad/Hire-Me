import 'package:flutter/widgets.dart';
import 'package:get/state_manager.dart';
import '../../../../../../core/helper/data_helper.dart';
import '../../controllers/chat_details_controller.dart';
import 'data_divider.dart';
import 'message_bubble.dart';

class MessagesList extends StatelessWidget {
  final ChatDetailsController controller;
  const MessagesList({required this.controller, super.key});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final lastSentIndex = controller.messages.lastIndexWhere(
        (m) => controller.isMe(m.senderId),
      );

      // ✅ اقري selectedMessageId هون عشان الـ Obx يتابعها
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
                showTime:
                    selectedId ==
                    msg.id, // ✅ من selectedId مش من controller مباشرة
                onTap: () => controller.toggleMessageTime(msg.id),
              ),
            ],
          );
        },
      );
    });
  }
}
