import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hire_me/core/utils/app_color.dart';

import '../../application_review/model/job_with_application.dart';
import '../controllers/application_list_controller.dart';
import 'widgets/applications_group_card.dart';
import 'widgets/applications_header.dart';
import 'widgets/company_job_card.dart';
import 'widgets/empty_state.dart';
import 'widgets/main_tab_switch.dart';
import 'widgets/status_filter_bar.dart';

class ApplicationListView extends GetView<ApplicationListController> {
  const ApplicationListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.ewhite,
      body: Obx(() {
        return Column(
          children: [
            ApplicantsHeader(
              jobsCount: controller.jobsCount.value,
              applicantsCount: controller.applicantsCount.value,
              onJobsTap: controller.showJobsTab,
              onApplicationsTap: controller.showApplicationsTab,
            ),

            MainTabSwitch(
              activeTab: controller.activeTab.value,
              onJobsTap: controller.showJobsTab,
              onApplicationsTap: controller.showApplicationsTab,
            ),

            if (controller.activeTab.value == 'applications')
              StatusFilterBar(
                selectedStatus: controller.selectedStatus.value,
                onSelect: (status) => controller.selectedStatus.value = status,
              ),

            Expanded(
              child: controller.activeTab.value == 'jobs'
                  ? _buildJobsTab()
                  : _buildApplicationsTab(controller.filteredJobs),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildJobsTab() {
    if (controller.isJobsLoading.value) {
      return Center(child: CircularProgressIndicator(color: AppColor.kblue));
    }

    final jobs = controller.companyJobs;

    if (jobs.isEmpty) {
      return const EmptyState(
        icon: Icons.work_outline_rounded,
        title: 'No jobs posted yet',
        subtitle: 'Your posted jobs will appear here.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      itemCount: jobs.length,
      itemBuilder: (_, index) {
        final job = jobs[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: CompanyJobCard(
            job: job,
            onViewApplicants: () {
              controller.selectedStatus.value = 'Pending';
              controller.showApplicationsTab();
            },
            onEdit: () => controller.editJob(job),
            onClose: () => controller.confirmCloseJob(job),
            onDelete: () => controller.confirmDeleteJob(job),
          ),
        );
      },
    );
  }

  Widget _buildApplicationsTab(List<JobWithApplicants> jobs) {
    if (controller.isLoading.value) {
      return Center(child: CircularProgressIndicator(color: AppColor.kblue));
    }

    if (jobs.isEmpty) {
      return const EmptyState(
        icon: Icons.inbox_outlined,
        title: 'No applications yet',
        subtitle: 'New applications will appear here.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      itemCount: jobs.length,
      itemBuilder: (_, jobIndex) {
        final job = jobs[jobIndex];

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: ApplicationsGroupCard(
            job: job,
            readOnly: controller.selectedStatus.value != 'Pending',
          ),
        );
      },
    );
  }
}
