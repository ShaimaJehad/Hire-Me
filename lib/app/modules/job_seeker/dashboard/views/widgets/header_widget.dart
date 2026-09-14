import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hire_me/app/routes/app_pages.dart';
import 'package:hire_me/core/utils/app_color.dart';
import 'package:hire_me/core/utils/app_text_style.dart';

import '../../controllers/job_seeker_dashboard_controller.dart';

class HeaderWidget extends GetView<JobSeekerDashboardController> {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(25, 34, 25, 70),
      decoration: BoxDecoration(
        color: AppColor.kblue,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(
            () => Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${controller.userName.value}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CustomTextstyle.poppinsSemiBoldWhite.copyWith(
                      fontSize: 15,
                      color: AppColor.kwhite.withValues(alpha: .85),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Find the right job\nfor your skills',
                    style: CustomTextstyle.poppinsBold.copyWith(
                      color: AppColor.kwhite,
                      fontSize: 24,
                      height: 1.12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          Obx(
            () => Badge(
              isLabelVisible: controller.notificationBadgeCount > 0,
              label: Text('${controller.notificationBadgeCount}'),
              textStyle: const TextStyle(color: Colors.white, fontSize: 10),
              textColor: Colors.white,
              backgroundColor: Colors.red,
              smallSize: 18,
              child: GestureDetector(
                onTap: () => Get.toNamed(Routes.jobSeekerNotifications),
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppColor.kwhite.withValues(alpha: .14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: AppColor.kwhite,
                    size: 27,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
