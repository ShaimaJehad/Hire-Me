import 'package:flutter/material.dart';
import '../../../../../../core/utils/app_color.dart';

class JobCardHeader extends StatelessWidget {
  final String jobTitle;
  final int applicantCount;

  const JobCardHeader({
    required this.jobTitle,
    required this.applicantCount,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColor.kblue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.kblue.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jobTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColor.kblue,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$applicantCount ${applicantCount == 1 ? 'applicant' : 'applicants'}',
                  style: TextStyle(fontSize: 12, color: AppColor.greyLight),
                ),
              ],
            ),
          ),
          Icon(Icons.work_outline_rounded, color: AppColor.kblue, size: 24),
        ],
      ),
    );
  }
}
