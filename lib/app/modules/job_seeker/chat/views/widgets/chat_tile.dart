import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/chat_model.dart';
import 'avatar.dart';
import 'chat_info.dart';
import 'chat_meta.dart';
import '../../../../../../core/utils/app_color.dart';
import '../../../../../routes/app_pages.dart';

class ChatTile extends StatelessWidget {
  final ChatModel chat;
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  ChatTile({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Get.toNamed(
              Routes.jobSeekerChatDetails,
              arguments: {
                'chatId': chat.id,
                'chatName': chat.otherName(currentUserId),
                'avatarUrl': chat.otherAvatarUrl(currentUserId),
                'seekerId': chat.seekerId,
                'companyId': chat.companyId,
              },
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Avatar(
                  name: chat.otherName(currentUserId),
                  avatarUrl: chat.otherAvatarUrl(currentUserId),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChatInfo(
                    name: chat.otherName(currentUserId), // ✅
                    lastMessage: chat.lastMessage,
                    lastMessageAuthor: chat.lastMessageAuthor,

                    currentUserId: currentUserId,
                  ),
                ),
                ChatMeta(
                  time: chat.lastMessageTime,
                  unreadCount: chat.unreadFor(
                    FirebaseAuth.instance.currentUser!.uid,
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(height: 1, color: AppColor.divider),
      ],
    );
  }
}
