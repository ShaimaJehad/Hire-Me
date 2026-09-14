import 'package:flutter/material.dart';

import '../../../../../../core/utils/app_color.dart';

class ProfileCard extends StatelessWidget {
  final String name;
  final String jobTitle;
  final String location;
  final String avatarUrl;

  const ProfileCard({
    super.key,
    required this.name,
    required this.jobTitle,
    required this.location,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
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
          CircleAvatar(
            radius: 46,
            backgroundColor: AppColor.kblue.withValues(alpha: 0.1),
            backgroundImage: NetworkImage(
              avatarUrl.isNotEmpty
                  ? avatarUrl
                  : 'https://i.pravatar.cc/150?img=47',
            ),
          ),
          const SizedBox(height: 14),
          Text(
            name,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: AppColor.kblack,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.work_outline_rounded, size: 16, color: AppColor.kblue),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  jobTitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColor.greydark,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: AppColor.kblue),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  location,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColor.greydark,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
