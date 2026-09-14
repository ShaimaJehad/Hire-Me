import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hire_me/app/shared/widgets/curved_app_bar.dart';
import 'package:hire_me/core/utils/app_color.dart';
import 'package:hire_me/core/utils/app_text_style.dart';
import 'package:hire_me/app/modules/job_seeker/dashboard/views/widgets/job_card_widget.dart';

import '../controllers/job_seeker_saved_jobs_controller.dart';

class JobSeekerSavedJobsView extends GetView<JobSeekerSavedJobsController> {
  const JobSeekerSavedJobsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            const CurvedAppBar(title: 'Saved Jobs'),
            Expanded(
              child: RefreshIndicator(
                color: AppColor.kblue,
                onRefresh: controller.refreshSavedJobs,
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(color: AppColor.kblue),
                    );
                  }

                  if (controller.savedJobs.isEmpty) {
                    return _emptyState();
                  }

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 14, bottom: 24),
                    itemCount: controller.savedJobs.length,
                    itemBuilder: (context, index) {
                      final job = controller.savedJobs[index];

                      return JobCardWidget(
                        job: job,
                        isSaved: true,
                        onSaveTap: () => controller.removeSavedJob(job.id),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Icon(
          Icons.bookmark_border_rounded,
          size: 90,
          color: AppColor.greyLight,
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'No saved jobs yet',
            style: CustomTextstyle.poppinsSemiBold.copyWith(
              fontSize: 17,
              color: AppColor.eblack,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Jobs you save will appear here',
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
