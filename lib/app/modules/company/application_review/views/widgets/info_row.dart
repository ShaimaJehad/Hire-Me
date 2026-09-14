import 'package:flutter/material.dart';

import '../../../../../../core/utils/app_color.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  const InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColor.kblue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: AppColor.greyLight),
                ),
                if (value.isNotEmpty)
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColor.kblack,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
