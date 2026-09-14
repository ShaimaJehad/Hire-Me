import 'package:flutter/material.dart';
import 'package:hire_me/app/modules/company/application_review/model/job_with_application.dart';
import 'package:hire_me/core/utils/app_color.dart';

class ApplicationGroupTitle extends StatelessWidget {
  final JobWithApplicants job;

  const ApplicationGroupTitle({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColor.kblue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.work_outline_rounded,
            color: AppColor.kblue,
            size: 22,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job.jobTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColor.kblack,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${job.applicants.length} ${job.applicants.length == 1 ? 'applicant' : 'applicants'}',
                style: TextStyle(
                  color: AppColor.greydark,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
