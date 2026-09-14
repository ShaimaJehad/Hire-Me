import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hire_me/app/routes/app_pages.dart';
import 'package:hire_me/core/utils/app_color.dart';

import 'package:hire_me/app/modules/job_seeker/chat/views/chat_view.dart';
import 'package:hire_me/app/modules/job_seeker/dashboard/views/job_seeker_dashboard_view.dart';
import 'package:hire_me/app/modules/job_seeker/my_applications/views/job_seeker_my_applications_view.dart';
import 'package:hire_me/app/modules/job_seeker/saved_jobs/views/job_seeker_saved_jobs_view.dart';
import 'package:hire_me/app/modules/job_seeker/profile/views/profile_view.dart';

import '../controllers/main_wrapper_controller.dart';

class MainWrapperView extends GetView<MainWrapperController> {
  const MainWrapperView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            ProfileView(),
            ChatView(),
            JobSeekerDashboardView(),
            JobSeekerMyApplicationsView(),
            JobSeekerSavedJobsView(),
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNavBar(),
    );
  }
}

class MainBottomNavBar extends GetView<MainWrapperController> {
  const MainBottomNavBar({super.key, this.navigateToWrapper = false});

  final bool navigateToWrapper;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: AppColor.kwhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _navIcon(
                index: 0,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
              ),
              Badge(
                isLabelVisible: controller.unreadChats > 0,
                label: Text('${controller.unreadChats}'),
                child: _navIcon(
                  index: 1,
                  icon: Icons.chat_bubble_outline_rounded,
                  activeIcon: Icons.chat_bubble_rounded,
                ),
              ),
              _homeIcon(),
              _navIcon(
                index: 3,
                icon: Icons.work_outline_rounded,
                activeIcon: Icons.work_rounded,
              ),
              _navIcon(
                index: 4,
                icon: Icons.bookmark_border_rounded,
                activeIcon: Icons.bookmark_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _homeIcon() {
    final isSelected = controller.currentIndex.value == 2;

    return GestureDetector(
      onTap: () => _onNavTap(2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: isSelected ? AppColor.kblue : AppColor.kwhite,
          shape: BoxShape.circle,
          border: Border.all(color: AppColor.kblue, width: 1.2),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColor.kblue.withValues(alpha: 0.22),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Icon(
          isSelected ? Icons.home_rounded : Icons.home_outlined,
          color: isSelected ? AppColor.kwhite : AppColor.kblue,
          size: 25,
        ),
      ),
    );
  }

  Widget _navIcon({
    required int index,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isSelected = controller.currentIndex.value == index;

    return GestureDetector(
      onTap: () => _onNavTap(index),
      child: SizedBox(
        width: 42,
        height: 52,
        child: Center(
          child: Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? AppColor.kblue : AppColor.greyLight,
            size: 25,
          ),
        ),
      ),
    );
  }

  void _onNavTap(int index) {
    if (navigateToWrapper) {
      Get.offAllNamed(Routes.mainWrapper, arguments: {'initialIndex': index});
      return;
    }

    controller.changePage(index);
  }
}
