import 'package:flutter/material.dart';

import '../../../../../../core/utils/app_color.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColor.kblue,
      elevation: 0,

      title: const Text(
        'Chats',
        style: TextStyle(
          color: AppColor.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }
}
