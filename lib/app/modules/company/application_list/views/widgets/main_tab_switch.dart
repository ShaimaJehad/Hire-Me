import 'package:flutter/material.dart';
import 'package:hire_me/core/utils/app_color.dart';

class MainTabSwitch extends StatelessWidget {
  final String activeTab;
  final VoidCallback onJobsTap;
  final VoidCallback onApplicationsTap;

  const MainTabSwitch({
    super.key,
    required this.activeTab,
    required this.onJobsTap,
    required this.onApplicationsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.kwhite,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              title: 'Jobs',
              isActive: activeTab == 'jobs',
              onTap: onJobsTap,
            ),
          ),
          Expanded(
            child: _TabButton(
              title: 'Applications',
              isActive: activeTab == 'applications',
              onTap: onApplicationsTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? AppColor.kblue : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? AppColor.kblue : AppColor.greydark,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
