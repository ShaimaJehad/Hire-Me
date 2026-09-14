import 'package:flutter/material.dart';

import '../../../../../../core/utils/app_color.dart';

class DateDivider extends StatelessWidget {
  final String label;
  const DateDivider({required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Divider(color: AppColor.divider)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColor.textSecondary,
              ),
            ),
          ),
          const Expanded(child: Divider(color: AppColor.divider)),
        ],
      ),
    );
  }
}
