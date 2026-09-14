import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../../../core/utils/app_color.dart';
import '../../../chat/views/widgets/avatar.dart';

class ChatDetailsAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String name;
  final String avatarUrl;

  const ChatDetailsAppbar({
    required this.name,
    required this.avatarUrl,
    super.key,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColor.kwhite,
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFF5F7FA),
        statusBarIconBrightness: Brightness.dark,
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColor.kblack, size: 20),
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          Avatar(name: name, avatarUrl: avatarUrl, radius: 16),
          const SizedBox(width: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColor.kblack,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.more_vert, color: AppColor.kblack, size: 20),
          onPressed: () => debugPrint('Chat more options pressed'),
        ),
      ],
    );
  }
}
