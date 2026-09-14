import 'package:flutter/material.dart';

import '../../../../../../core/utils/app_color.dart';

class ApplicantAvatar extends StatelessWidget {
  final String name;
  final String url;
  const ApplicantAvatar({required this.name, required this.url, super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 24,
      backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
      backgroundColor: _getColor(name),
      child: url.isEmpty
          ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                color: AppColor.kwhite,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            )
          : null,
    );
  }

  Color _getColor(String name) {
    final colors = [AppColor.kblue, AppColor.kblack, AppColor.greydark];
    if (name.isEmpty) return colors[0];
    return colors[name.codeUnitAt(0) % colors.length];
  }
}
