import 'package:flutter/material.dart';

import '../../../../../../core/utils/app_color.dart';

class ApplicantInfo extends StatelessWidget {
  final String name;
  final String jobTitle;
  final String location;

  const ApplicantInfo({
    required this.name,
    required this.jobTitle,
    required this.location,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final safeLocation = location.trim().isEmpty
        ? 'Location not added'
        : location.trim();

    final safeJobTitle = jobTitle.trim().isEmpty
        ? 'Job title not added'
        : jobTitle.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name.trim().isEmpty ? 'Unknown Applicant' : name.trim(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColor.kblack,
          ),
        ),

        const SizedBox(height: 4),

        Row(
          children: [
            Icon(Icons.work_outline_rounded, size: 13, color: AppColor.kblue),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                safeJobTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColor.greydark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 3),

        Row(
          children: [
            Icon(Icons.location_on_outlined, size: 13, color: AppColor.kblue),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                safeLocation,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColor.greyLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
