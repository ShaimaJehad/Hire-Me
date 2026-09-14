import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hire_me/app/modules/job_seeker/dashboard/controllers/job_seeker_dashboard_controller.dart';
import 'package:hire_me/app/modules/job_seeker/dashboard/views/widgets/header_widget.dart';
import 'package:hire_me/app/modules/job_seeker/dashboard/views/widgets/job_card_widget.dart';
import 'package:hire_me/app/modules/job_seeker/dashboard/views/widgets/job_filter_bottom_sheet.dart';
import 'package:hire_me/app/modules/job_seeker/dashboard/views/widgets/main_fields_widget.dart';
import 'package:hire_me/app/modules/job_seeker/dashboard/views/widgets/search_widget.dart';
import 'package:hire_me/app/modules/job_seeker/dashboard/views/widgets/sub_fields_widget.dart';
import 'package:hire_me/core/utils/app_color.dart';
import 'package:hire_me/core/utils/app_text_style.dart';

class JobSeekerDashboardView extends GetView<JobSeekerDashboardController> {
  const JobSeekerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshDashboard,
          color: AppColor.kblue,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HeaderWidget(),

                Transform.translate(
                  offset: const Offset(0, -28),
                  child: SearchFilterWidget(
                    searchController: controller.searchTextController,
                    onChanged: controller.onSearch,
                    onFilterTap: JobFilterBottomSheet.show,
                  ),
                ),

                const MainFieldsWidget(),

                const SubFieldsWidget(),

                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 5, 25, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Job For You',
                        style: CustomTextstyle.poppinsBold.copyWith(
                          fontSize: 18,
                          color: AppColor.eblack,
                        ),
                      ),
                      GestureDetector(
                        onTap: controller.clearFilters,
                        child: Text(
                          'Clear',
                          style: TextStyle(
                            color: AppColor.kblue,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Obx(() {
                  if (controller.isLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (controller.filteredJobs.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: controller.filteredJobs.length,
                    itemBuilder: (context, index) {
                      final job = controller.filteredJobs[index];

                      return Obx(
                        () => JobCardWidget(
                          job: job,
                          isSaved: controller.isJobSaved(job.id),
                          onSaveTap: () => controller.toggleSaveJob(job.id),
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 78, color: AppColor.greyLight),
            const SizedBox(height: 12),
            Text(
              'No jobs found',
              style: CustomTextstyle.poppins500Grey.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              'Try changing the search or filters',
              style: TextStyle(color: AppColor.greyLight, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
