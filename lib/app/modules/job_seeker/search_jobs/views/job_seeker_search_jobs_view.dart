import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hire_me/core/utils/app_color.dart';
import 'package:hire_me/core/utils/app_text_style.dart';
import 'package:hire_me/app/modules/job_seeker/dashboard/views/widgets/job_card_widget.dart';

import '../controllers/job_seeker_search_jobs_controller.dart';

class JobSeekerSearchJobsView extends GetView<JobSeekerSearchJobsController> {
  const JobSeekerSearchJobsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        backgroundColor: AppColor.kblue,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Search Jobs',
          style: CustomTextstyle.poppinsSemiBoldWhite.copyWith(
            fontSize: 18,
            color: AppColor.kwhite,
          ),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColor.kwhite,
            size: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBox(),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(color: AppColor.kblue),
                  );
                }

                if (controller.searchResults.isEmpty) {
                  return _emptyState();
                }

                return RefreshIndicator(
                  color: AppColor.kblue,
                  onRefresh: controller.refreshSearch,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 12, bottom: 24),
                    itemCount: controller.searchResults.length,
                    itemBuilder: (context, index) {
                      final job = controller.searchResults[index];

                      return Obx(
                        () => JobCardWidget(
                          job: job,
                          isSaved: controller.isJobSaved(job.id),
                          onSaveTap: () => controller.toggleSaveJob(job.id),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      color: AppColor.kblue,
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 22),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColor.kwhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColor.eblack.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Obx(
          () => TextField(
            controller: controller.searchController,
            autofocus: true,
            onChanged: controller.onSearchChanged,
            style: TextStyle(fontSize: 15, color: AppColor.kblack),
            decoration: InputDecoration(
              hintText: 'Search by job, company, field...',
              hintStyle: TextStyle(color: AppColor.greyLight, fontSize: 13),
              prefixIcon: Icon(Icons.search_rounded, color: AppColor.kblue),
              suffixIcon: controller.searchQuery.value.isNotEmpty
                  ? IconButton(
                      onPressed: controller.clearSearch,
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColor.greyLight,
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Icon(Icons.search_off_rounded, size: 90, color: AppColor.greyLight),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'No jobs found',
            style: CustomTextstyle.poppinsSemiBold.copyWith(
              fontSize: 17,
              color: AppColor.eblack,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Try another keyword',
            style: TextStyle(
              fontSize: 13,
              color: AppColor.greyLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
