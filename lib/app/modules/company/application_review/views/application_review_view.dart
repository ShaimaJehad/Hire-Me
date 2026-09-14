import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/app_color.dart';
import '../controllers/application_review_controller.dart';
import '../model/application_review_model.dart';
import 'widgets/profile_card.dart';
import 'widgets/review_app_bar.dart';

class ApplicationReviewView extends GetView<ApplicationReviewController> {
  const ApplicationReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.ewhite,
      appBar: const ReviewAppBar(),
      body: Obx(() {
        final applicant = controller.applicant.value;

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 118),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileCard(
                    name: _valueOrFallback(applicant.name, 'Unknown'),
                    jobTitle: _valueOrFallback(
                      applicant.jobTitle,
                      'Unknown Job',
                    ),
                    location: _valueOrFallback(
                      applicant.location,
                      'Location not added',
                    ),
                    avatarUrl: applicant.avatarUrl,
                  ),
                  if (controller.readOnly.value &&
                      applicant.updatedAt.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _buildStatusBadge(applicant.status, applicant.updatedAt),
                  ],
                  const SizedBox(height: 16),
                  _buildSectionTitle('Applicant Information'),
                  const SizedBox(height: 10),
                  _buildInfoPanel(applicant),
                ],
              ),
            ),
            if (!controller.readOnly.value)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(
                    color: AppColor.kwhite,
                    border: Border(
                      top: BorderSide(color: AppColor.greyVeryLight),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.kblack.withValues(alpha: 0.05),
                        blurRadius: 14,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: controller.isProcessing.value
                                ? null
                                : () => controller.rejectApplication(
                                    applicant.id,
                                  ),
                            icon: const Icon(Icons.cancel_outlined, size: 18),
                            label: const Text(
                              'Reject',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColor.kdanger,
                              side: BorderSide(
                                color: AppColor.kdanger,
                                width: 1.4,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: controller.isProcessing.value
                                ? null
                                : () => controller.acceptApplication(
                                    applicant.id,
                                    applicant.jobSeekerId,
                                    applicant.name,
                                    controller.companyId,
                                    controller.companyName.value,
                                  ),
                            icon: const Icon(
                              Icons.check_circle_outline,
                              size: 18,
                            ),
                            label: const Text(
                              'Accept',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.kblue,
                              foregroundColor: AppColor.kwhite,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  static String _valueOrFallback(String value, String fallback) {
    final text = value.trim();

    if (text.isEmpty) {
      return fallback;
    }

    return text;
  }

  Widget _buildStatusBadge(String status, String date) {
    final isAccepted = status == 'Accepted';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: (isAccepted ? AppColor.ksuccess : AppColor.kdanger).withValues(
          alpha: 0.08,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isAccepted ? AppColor.ksuccess : AppColor.kdanger).withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isAccepted ? Icons.check_circle : Icons.cancel,
            color: isAccepted ? AppColor.ksuccess : AppColor.kdanger,
            size: 20,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAccepted ? 'Accepted' : 'Rejected',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isAccepted ? AppColor.ksuccess : AppColor.kdanger,
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColor.greydark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColor.kblack,
      ),
    );
  }

  Widget _buildInfoPanel(ApplicationReviewModel applicant) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.kwhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.greyVeryLight),
        boxShadow: [
          BoxShadow(
            color: AppColor.kblack.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCompactInfoRow(
            title: 'Email',
            content: _valueOrFallback(applicant.email, 'Email not added'),
            icon: Icons.email_outlined,
          ),
          _buildRowDivider(),
          _buildCompactInfoRow(
            title: 'Skills',
            content: _valueOrFallback(applicant.skills, 'No skills added'),
            icon: Icons.school_outlined,
          ),
          _buildRowDivider(),
          _buildCompactInfoRow(
            title: 'Experience',
            content: _valueOrFallback(
              applicant.experience,
              'No experience added',
            ),
            icon: Icons.calendar_today_outlined,
          ),
          _buildRowDivider(),
          _buildCompactInfoRow(
            title: 'Resume',
            content: 'View CV',
            icon: Icons.assignment_outlined,
            onTap: () => controller.viewApplicantCV(applicant.cvUrl),
          ),
        ],
      ),
    );
  }

  Widget _buildRowDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(color: AppColor.greyVeryLight, height: 1, thickness: 1),
    );
  }

  Widget _buildCompactInfoRow({
    required String title,
    required String content,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColor.kblue, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColor.greydark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColor.kblack,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 3,
                overflow: TextOverflow.fade,
              ),
            ],
          ),
        ),
      ],
    );

    if (onTap == null) return row;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: row,
      ),
    );
  }
}
