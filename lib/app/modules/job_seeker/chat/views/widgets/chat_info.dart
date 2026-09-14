import 'package:flutter/widgets.dart';

import '../../../../../../core/utils/app_color.dart';

class ChatInfo extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String lastMessageAuthor;
  final String currentUserId;
  const ChatInfo({
    required this.name,
    required this.lastMessage,
    required this.lastMessageAuthor,
    required this.currentUserId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColor.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                lastMessageAuthor == currentUserId
                    ? 'You: $lastMessage'
                    : '$name: $lastMessage',
                style: TextStyle(fontSize: 13, color: AppColor.greyLight),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
