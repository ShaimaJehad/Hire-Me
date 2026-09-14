import 'package:flutter/widgets.dart';

import '../../../../../../core/utils/app_color.dart';
import '../../../../../../core/helper/data_helper.dart';
import 'unread_badge.dart';

class ChatMeta extends StatelessWidget {
  final DateTime time;
  final int unreadCount;
  const ChatMeta({required this.time, required this.unreadCount, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          formatTime(time),
          style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
        ),
        const SizedBox(height: 6),
        if (unreadCount > 0)
          UnreadBadge(count: unreadCount)
        else
          const SizedBox(height: 18),
      ],
    );
  }
}
