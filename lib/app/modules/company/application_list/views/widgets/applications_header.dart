import 'package:flutter/material.dart';

import '../../../../../../core/utils/app_color.dart';

class ApplicantsHeader extends StatelessWidget {
  final int jobsCount;
  final int applicantsCount;
  final VoidCallback? onJobsTap;
  final VoidCallback? onApplicationsTap;

  const ApplicantsHeader({
    required this.jobsCount,
    required this.applicantsCount,
    this.onJobsTap,
    this.onApplicationsTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
      decoration: BoxDecoration(
        color: AppColor.kblue,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Job Management',
              style: TextStyle(
                color: AppColor.kwhite,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                GestureDetector(
                  onTap: onJobsTap,
                  child: _InfoPill(
                    icon: Icons.work_outline_rounded,
                    text: '$jobsCount ${jobsCount == 1 ? 'job' : 'jobs'}',
                  ),
                ),
                GestureDetector(
                  onTap: onApplicationsTap,
                  child: _InfoPill(
                    icon: Icons.group_outlined,
                    text:
                        '$applicantsCount ${applicantsCount == 1 ? 'applicant' : 'applicants'}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColor.kwhite.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColor.kwhite.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColor.kwhite),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: AppColor.kwhite,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
