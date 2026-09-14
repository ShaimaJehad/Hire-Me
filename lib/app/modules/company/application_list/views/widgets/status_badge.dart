import 'package:flutter/material.dart';
import 'package:hire_me/core/utils/app_color.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isOpen = status.toLowerCase() == 'open';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: isOpen ? const Color(0xFFE8F7EE) : const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.isEmpty ? 'Open' : status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: isOpen ? const Color(0xFF16A34A) : AppColor.greydark,
        ),
      ),
    );
  }
}
