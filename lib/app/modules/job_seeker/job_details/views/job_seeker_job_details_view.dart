import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hire_me/core/utils/app_color.dart';
import 'package:hire_me/core/utils/app_text_style.dart';

import '../controllers/job_seeker_job_details_controller.dart';
import '../../jobseeker_main_wrapper/views/main_wrapper_view.dart';

class JobSeekerJobDetailsView extends GetView<JobSeekerJobDetailsController> {
  const JobSeekerJobDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final job = controller.job.value;

      if (job == null) {
        return Scaffold(
          backgroundColor: const Color(0xffF5F7FA),
          body: Center(child: CircularProgressIndicator(color: AppColor.kblue)),
        );
      }

      return Scaffold(
        backgroundColor: const Color(0xffF5F7FA),
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildJobHeaderCard(),
                      const SizedBox(height: 16),
                      _buildDescriptionCard(),
                      const SizedBox(height: 16),
                      _buildRequirementsCard(),
                      const SizedBox(height: 28),
                      _buildApplyButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const MainBottomNavBar(navigateToWrapper: true),
      );
    });
  }

  Widget _buildAppBar() {
    return Container(
      height: 68,
      width: double.infinity,
      color: AppColor.kblue,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          GestureDetector(
            onTap: Get.back,
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColor.kwhite,
              size: 20,
            ),
          ),
          Expanded(
            child: Text(
              'Job Description',
              textAlign: TextAlign.center,
              style: CustomTextstyle.poppinsSemiBoldWhite.copyWith(
                fontSize: 18,
                color: AppColor.kwhite,
              ),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildJobHeaderCard() {
    final job = controller.job.value!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: AppColor.kwhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColor.eblack.withValues(alpha: 0.06),
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
              _fieldLogoBox(),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CustomTextstyle.poppinsSemiBold.copyWith(
                        fontSize: 16,
                        color: AppColor.eblack,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      job.companyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColor.greydark,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: Colors.green.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            job.location.isNotEmpty
                                ? job.location
                                : 'Not specified',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColor.greydark,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      job.salary.trim().isNotEmpty
                          ? job.salary.trim()
                          : 'Salary not specified',
                      style: TextStyle(
                        color: AppColor.kblue,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              Obx(
                () => IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: controller.toggleSaveJob,
                  icon: Icon(
                    controller.isSaved.value
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: AppColor.kblue,
                    size: 27,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              _buildBadge(
                controller.formatJobType(job.jobType),
                isPrimary: false,
              ),
              const SizedBox(width: 10),
              _buildBadge(_formatWorkMode(job.workMode), isPrimary: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fieldLogoBox() {
    final job = controller.job.value!;

    final iconUrl = job.subFieldIconUrl.isNotEmpty
        ? job.subFieldIconUrl
        : job.mainFieldIconUrl;

    return Container(
      width: 52,
      height: 52,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: AppColor.kblue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: iconUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: iconUrl,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Icon(
                  Icons.work_outline_rounded,
                  color: AppColor.kblue,
                  size: 30,
                ),
              )
            : Icon(Icons.work_outline_rounded, color: AppColor.kblue, size: 30),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    final job = controller.job.value!;

    return _infoCard(
      title: 'Job Description',
      child: _sectionText(
        job.description.isNotEmpty
            ? job.description
            : 'No job description available.',
      ),
    );
  }

  Widget _buildRequirementsCard() {
    final job = controller.job.value!;

    final requirementsText = job.requirements.isNotEmpty
        ? job.requirements
        : 'No requirements added for this job.';

    return _infoCard(
      title: 'Requirements and Skills',
      child: _requirementsText(requirementsText),
    );
  }

  Widget _infoCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: AppColor.kwhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColor.eblack.withValues(alpha: 0.045),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_sectionTitle(title), const SizedBox(height: 10), child],
      ),
    );
  }

  Widget _buildBadge(String text, {required bool isPrimary}) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isPrimary ? AppColor.kblue : AppColor.kwhite,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColor.kblue, width: 1),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isPrimary ? AppColor.kwhite : AppColor.kblue,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColor.eblack,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _sectionText(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppColor.eblack.withValues(alpha: 0.78),
        fontSize: 13,
        height: 1.55,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _requirementsText(String text) {
    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.length <= 1) {
      return _sectionText(text);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '•',
                style: TextStyle(
                  color: AppColor.kblue,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  line,
                  style: TextStyle(
                    color: AppColor.eblack.withValues(alpha: 0.78),
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildApplyButton() {
    final job = controller.job.value!;
    final isClosed = job.status.toLowerCase() == 'closed';

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isClosed ? null : controller.goToApplyJob,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.kblue,
          disabledBackgroundColor: AppColor.greyLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: Text(
          isClosed ? 'Closed' : 'Apply Now',
          style: TextStyle(
            color: AppColor.kwhite,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  String _formatWorkMode(String value) {
    switch (value) {
      case 'OnSite':
        return 'On Site';
      case 'Remote':
        return 'Remote';
      case 'Hybrid':
        return 'Hybrid';
      default:
        return value.isEmpty ? 'Not specified' : value;
    }
  }
}
