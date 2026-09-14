import 'package:flutter/material.dart';

import '../../../../../../core/utils/app_color.dart';

class Avatar extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final double radius; // ✅ أضف هاد

  const Avatar({
    required this.name,
    required this.avatarUrl,
    this.radius = 26, // default للـ Chat List
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
      backgroundColor: _getAvatarColor(name),
      child: avatarUrl.isEmpty
          ? Text(
              name[0].toUpperCase(),
              style: TextStyle(
                color: AppColor.white,
                fontWeight: FontWeight.bold,
                fontSize:
                    radius * 0.7, // ✅ fontSize تتغير تلقائياً مع الـ radius
              ),
            )
          : null,
    );
  }
}

Color _getAvatarColor(String name) {
  final colors = [
    const Color(0xFF4A90D9),
    const Color(0xFFE8944A),
    const Color(0xFF7B68EE),
    const Color(0xFF48C78E),
    const Color(0xFFE05C7A),
  ];
  return colors[name.codeUnitAt(0) % colors.length];
}
