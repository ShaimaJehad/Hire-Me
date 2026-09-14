import 'package:flutter/material.dart';
import 'package:hire_me/app/modules/company/application_list/views/widgets/application_group_title.dart';
import 'package:hire_me/app/modules/company/application_list/views/widgets/application_tile.dart';
import 'package:hire_me/app/modules/company/application_review/model/job_with_application.dart';
import 'package:hire_me/core/utils/app_color.dart';

class ApplicationsGroupCard extends StatelessWidget {
  final JobWithApplicants job;
  final bool readOnly;

  const ApplicationsGroupCard({
    super.key,
    required this.job,
    required this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.kwhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.greyVeryLight),
        boxShadow: [
          BoxShadow(
            color: AppColor.kblack.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          backgroundColor: AppColor.kwhite,
          collapsedBackgroundColor: AppColor.kwhite,
          iconColor: AppColor.kblue,
          collapsedIconColor: AppColor.kblue,
          shape: const Border(),
          collapsedShape: const Border(),
          title: ApplicationGroupTitle(job: job),
          children: [
            const SizedBox(height: 4),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: job.applicants.length,
              itemBuilder: (_, applicantIndex) {
                final applicant = job.applicants[applicantIndex];

                return ApplicantTile(applicant: applicant, readOnly: readOnly);
              },
            ),
          ],
        ),
      ),
    );
  }
}
