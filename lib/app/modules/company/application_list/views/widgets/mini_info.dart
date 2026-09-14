import 'package:flutter/material.dart';
import 'package:hire_me/core/utils/app_color.dart';

class MiniInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const MiniInfo({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 17, color: AppColor.kblue),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: AppColor.greyLight,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColor.kblack,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
