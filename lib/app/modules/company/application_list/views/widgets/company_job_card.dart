import 'package:flutter/material.dart';
import 'package:hire_me/app/modules/company/application_list/model/company_job_model.dart';
import 'package:hire_me/app/modules/company/application_list/views/widgets/job_actions_sheet.dart';
import 'package:hire_me/app/modules/company/application_list/views/widgets/job_icon_box.dart';
import 'package:hire_me/app/modules/company/application_list/views/widgets/job_info_row.dart';
import 'package:hire_me/app/modules/company/application_list/views/widgets/mini_info.dart';
import 'package:hire_me/app/modules/company/application_list/views/widgets/status_badge.dart';
import 'package:hire_me/core/utils/app_color.dart';

class CompanyJobCard extends StatelessWidget {
  final CompanyJobModel job;
  final VoidCallback onViewApplicants;
  final VoidCallback onEdit;
  final VoidCallback onClose;
  final VoidCallback onDelete;

  const CompanyJobCard({
    super.key,
    required this.job,
    required this.onViewApplicants,
    required this.onEdit,
    required this.onClose,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isOpen = job.status.toLowerCase() == 'open';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.kwhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColor.greyVeryLight),
        boxShadow: [
          BoxShadow(
            color: AppColor.kblack.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              JobIconBox(job: job),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            job.title.isEmpty ? 'Untitled Job' : job.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColor.kblack,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(status: job.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    JobInfoRow(
                      icon: Icons.location_on_outlined,
                      text: job.location.isEmpty
                          ? 'Location not added'
                          : job.location,
                    ),
                    const SizedBox(height: 6),
                    JobInfoRow(
                      icon: Icons.calendar_today_outlined,
                      text: job.datePosted.isEmpty
                          ? 'Date not added'
                          : 'Posted ${job.datePosted}',
                    ),
                    const SizedBox(height: 6),
                    JobInfoRow(
                      icon: Icons.people_outline_rounded,
                      text:
                          '${job.applicantCount} applicant${job.applicantCount == 1 ? '' : 's'}',
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              GestureDetector(
                onTap: () {
                  JobActionsSheet.show(
                    jobTitle: job.title,
                    isOpen: isOpen,
                    onEdit: onEdit,
                    onClose: onClose,
                    onDelete: onDelete,
                  );
                },
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColor.kblue.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.more_vert_rounded,
                    color: AppColor.kblue,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColor.greyVeryLight),
            ),
            child: Row(
              children: [
                Expanded(
                  child: MiniInfo(
                    icon: Icons.attach_money_rounded,
                    title: 'Salary',
                    value: job.salary.isEmpty ? '-' : job.salary,
                  ),
                ),
                Container(width: 1, height: 34, color: AppColor.greyVeryLight),
                Expanded(
                  child: MiniInfo(
                    icon: Icons.work_history_outlined,
                    title: 'Type',
                    value: job.jobTypeLabel.isEmpty ? '-' : job.jobTypeLabel,
                  ),
                ),
                Container(width: 1, height: 34, color: AppColor.greyVeryLight),
                Expanded(
                  child: MiniInfo(
                    icon: Icons.public_rounded,
                    title: 'Mode',
                    value: job.workMode.isEmpty ? '-' : job.workMode,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onViewApplicants,
                  icon: Icon(
                    Icons.visibility_outlined,
                    size: 17,
                    color: AppColor.kblue,
                  ),
                  label: Text(
                    'View Applicants',
                    style: TextStyle(
                      color: AppColor.kblue,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColor.kblue.withValues(alpha: 0.35),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 17,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Edit Job',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.kblue,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
