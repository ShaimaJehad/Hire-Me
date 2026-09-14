import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/utils/app_color.dart';

class JobActionsSheet extends StatelessWidget {
  final String jobTitle;
  final bool isOpen;
  final VoidCallback onEdit;
  final VoidCallback onClose;
  final VoidCallback onDelete;

  const JobActionsSheet({
    super.key,
    required this.jobTitle,
    required this.isOpen,
    required this.onEdit,
    required this.onClose,
    required this.onDelete,
  });

  static void show({
    required String jobTitle,
    required bool isOpen,
    required VoidCallback onEdit,
    required VoidCallback onClose,
    required VoidCallback onDelete,
  }) {
    Get.bottomSheet(
      JobActionsSheet(
        jobTitle: jobTitle,
        isOpen: isOpen,
        onEdit: onEdit,
        onClose: onClose,
        onDelete: onDelete,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
      decoration: BoxDecoration(
        color: AppColor.kwhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: AppColor.kblack.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColor.greyLight.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(99),
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColor.kblue.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.business_center_outlined,
                    color: AppColor.kblue,
                    size: 23,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Job Actions',
                        style: TextStyle(
                          color: AppColor.kblack,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        jobTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColor.greyLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            _ActionTile(
              icon: Icons.edit_outlined,
              title: 'Edit Job',
              subtitle: 'Update job information',
              color: AppColor.kblue,
              onTap: () {
                Get.back();
                onEdit();
              },
            ),

            if (isOpen)
              _ActionTile(
                icon: Icons.lock_outline_rounded,
                title: 'Close Job',
                subtitle: 'Stop receiving new applications',
                color: const Color(0xFFF59E0B),
                onTap: () {
                  Get.back();
                  onClose();
                },
              ),

            _ActionTile(
              icon: Icons.delete_outline_rounded,
              title: 'Delete Job',
              subtitle: 'Remove job and related applications',
              color: const Color(0xFFEF4444),
              showDivider: false,
              onTap: () {
                Get.back();
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool showDivider;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 21),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: AppColor.kblack,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: AppColor.greyLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColor.greyLight,
                  size: 15,
                ),
              ],
            ),
          ),

          if (showDivider)
            Divider(
              height: 1,
              thickness: 0.8,
              color: AppColor.kblack.withValues(alpha: 0.05),
              indent: 54,
            ),
        ],
      ),
    );
  }
}
