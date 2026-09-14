import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hire_me/app/routes/app_pages.dart';
import 'package:hire_me/core/utils/app_color.dart';
import 'package:hire_me/core/utils/app_text_style.dart';
import 'package:hire_me/app/modules/job_seeker/dashboard/models/job_model.dart';

class JobCardWidget extends StatelessWidget {
  final JobModel job;
  final bool isSaved;
  final VoidCallback onSaveTap;

  const JobCardWidget({
    super.key,
    required this.job,
    required this.isSaved,
    required this.onSaveTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.jobSeekerJobDetails, arguments: job);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 19, vertical: 9),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColor.kwhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColor.eblack.withValues(alpha: .04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fieldLogoBox(),

                const SizedBox(width: 12),

                Expanded(child: _jobMainInfo()),

                IconButton(
                  onPressed: onSaveTap,
                  icon: Icon(
                    isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: AppColor.kblue,
                    size: 27,
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 13),
              child: Divider(
                color: AppColor.kblue.withValues(alpha: 0.32),
                thickness: 1,
              ),
            ),

            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColor.kblue,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    job.location.isNotEmpty ? job.location : 'Not specified',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColor.greydark, fontSize: 12),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Text(
              job.salary.isNotEmpty ? job.salary : 'Salary not specified',
              style: TextStyle(
                color: AppColor.kblue,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _badge(_formatJobType(job.jobType), isPrimary: false),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _badge(_formatWorkMode(job.workMode), isPrimary: true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLogoBox() {
    final iconUrl = job.subFieldIconUrl.isNotEmpty
        ? job.subFieldIconUrl
        : job.mainFieldIconUrl;

    return Container(
      width: 68,
      height: 68,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColor.kblue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.kblue.withValues(alpha: 0.10)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: iconUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: iconUrl,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Icon(
                  Icons.work_outline_rounded,
                  color: AppColor.kblue,
                  size: 36,
                ),
              )
            : Icon(Icons.work_outline_rounded, color: AppColor.kblue, size: 36),
      ),
    );
  }

  Widget _jobMainInfo() {
    return Column(
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

        const SizedBox(height: 2),

        Text(
          job.companyName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: AppColor.greydark, fontSize: 13),
        ),
      ],
    );
  }

  Widget _badge(String text, {required bool isPrimary}) {
    return Container(
      height: 34,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isPrimary ? AppColor.kblue : AppColor.kwhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.kblue),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isPrimary ? AppColor.kwhite : AppColor.kblue,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatJobType(String value) {
    if (value == 'FullTime') return 'Full Time';
    if (value == 'PartTime') return 'Part Time';
    return value.isEmpty ? 'Not specified' : value;
  }

  String _formatWorkMode(String value) {
    if (value == 'OnSite') return 'On Site';
    if (value == 'Remote') return 'Remote';
    if (value == 'Hybrid') return 'Hybrid';
    return value.isEmpty ? 'Not specified' : value;
  }
}
