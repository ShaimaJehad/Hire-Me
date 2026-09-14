import 'package:flutter/material.dart';
import 'package:hire_me/core/utils/app_color.dart';

class StatusFilterBar extends StatelessWidget {
  final String selectedStatus;
  final void Function(String) onSelect;

  const StatusFilterBar({
    super.key,
    required this.selectedStatus,
    required this.onSelect,
  });

  static const _tabs = ['Pending', 'Accepted', 'Rejected'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _tabs.map((tab) {
            final isActive = selectedStatus == tab;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onSelect(tab),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 17,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? AppColor.kblue : AppColor.kwhite,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isActive ? AppColor.kblue : AppColor.greyVeryLight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.kblack.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    tab,
                    style: TextStyle(
                      color: isActive ? AppColor.kwhite : AppColor.greydark,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
