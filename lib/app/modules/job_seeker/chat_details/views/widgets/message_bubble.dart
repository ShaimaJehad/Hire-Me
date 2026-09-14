import 'package:flutter/material.dart';

import '../../../../../../core/utils/app_color.dart';
import '../../../chat/views/widgets/avatar.dart';
import '../../model/chat_details_model.dart';

class MessageBubble extends StatelessWidget {
  final ChatDetailsModel message;
  final String time;
  final bool isMe;
  final bool isSeen;
  final String senderName;
  final String senderAvatarUrl;
  final bool showTime;
  final VoidCallback onTap;

  const MessageBubble({
    required this.message,
    required this.time,
    required this.isMe,
    required this.isSeen,
    required this.senderName,
    required this.showTime,
    required this.onTap,
    this.senderAvatarUrl = '',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap, // ✅
        child: Row(
          mainAxisAlignment: isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              Avatar(name: senderName, avatarUrl: senderAvatarUrl, radius: 16),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? AppColor.kblue : AppColor.greyVeryLight,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        fontSize: 14,
                        color: isMe ? AppColor.kwhite : AppColor.kblack,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showTime) // ✅
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColor.greyLight,
                          ),
                        ),
                      if (showTime && isMe && isSeen) const SizedBox(width: 4),
                      if (isMe && isSeen)
                        Text(
                          '✓✓',
                          style: TextStyle(fontSize: 10, color: AppColor.kblue),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
