import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hire_me/app/shared/widgets/curved_app_bar.dart';
import 'package:hire_me/app/modules/job_seeker/my_applications/views/widgets/application_card.dart';
import 'package:hire_me/core/utils/app_color.dart';

import '../controllers/job_seeker_my_applications_controller.dart';

class JobSeekerMyApplicationsView
    extends GetView<JobSeekerMyApplicationsController> {
  const JobSeekerMyApplicationsView({super.key});

  static const _backgroundColor = Color(0xFFF5F7FF);
  static const _textDark = Color(0xFF1A1A2E);
  static const _textGrey = Color(0xFF8A8A9A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            CurvedAppBar(
              title: 'Application Status',
              bottom: _buildTabs(),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(color: AppColor.kblue),
                  );
                }

                final list = controller.filteredApplications;

                if (list.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemCount: list.length,
                  itemBuilder: (_, i) =>
                      ApplicationCard(app: list[i], controller: controller),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: controller.tabs.map((tab) {
            final isSelected = controller.selectedTab.value == tab;

            return GestureDetector(
              onTap: () => controller.selectTab(tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.white38,
                  ),
                ),
                child: Text(
                  tab,
                  style: TextStyle(
                    color: isSelected ? AppColor.kblue : Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_off_outlined,
              size: 68,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            const Text(
              'No applications found',
              style: TextStyle(
                color: _textDark,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Applications will appear here after you apply',
              textAlign: TextAlign.center,
              style: TextStyle(color: _textGrey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
