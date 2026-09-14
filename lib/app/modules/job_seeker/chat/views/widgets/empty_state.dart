import 'package:flutter/material.dart';

import '../../../../../../core/utils/app_color.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: AppColor.textSecondary,
          ),
          SizedBox(height: 12),
          Text(
            'No chats found',
            style: TextStyle(color: AppColor.textSecondary, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
