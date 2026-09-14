import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../core/utils/app_color.dart';
import 'application_avatar.dart';
import 'application_info.dart';
import '../../../application_review/model/application_review_model.dart';
import '../../../../../routes/app_pages.dart';

class ApplicantTile extends StatelessWidget {
  final ApplicationReviewModel applicant;
  final bool readOnly;
  const ApplicantTile({
    required this.applicant,
    this.readOnly = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColor.kwhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.greyVeryLight),
        boxShadow: [
          BoxShadow(
            color: AppColor.kblack.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Get.toNamed(
          Routes.applicationReview,
          arguments: {'application': applicant, 'readOnly': readOnly},
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              ApplicantAvatar(name: applicant.name, url: applicant.avatarUrl),
              const SizedBox(width: 12),
              Expanded(
                child: ApplicantInfo(
                  name: applicant.name,
                  jobTitle: applicant.jobTitle,
                  location: applicant.location,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.kblue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      readOnly ? applicant.updatedAt : applicant.appliedAt,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColor.kblue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColor.greydark,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
