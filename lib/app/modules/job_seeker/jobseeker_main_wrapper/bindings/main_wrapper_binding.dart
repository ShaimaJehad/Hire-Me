import 'package:get/get.dart';

import 'package:hire_me/app/modules/job_seeker/chat/controllers/chat_controller.dart';
import 'package:hire_me/app/modules/job_seeker/dashboard/controllers/job_seeker_dashboard_controller.dart';
import 'package:hire_me/app/modules/job_seeker/my_applications/controllers/job_seeker_my_applications_controller.dart';
import 'package:hire_me/app/modules/job_seeker/saved_jobs/controllers/job_seeker_saved_jobs_controller.dart';
import 'package:hire_me/app/modules/job_seeker/profile/controllers/profile_controller.dart';

import '../controllers/main_wrapper_controller.dart';

class MainWrapperBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainWrapperController>(() => MainWrapperController());

    Get.lazyPut<JobSeekerDashboardController>(
      () => JobSeekerDashboardController(),
    );

    Get.lazyPut<ChatController>(() => ChatController());

    Get.lazyPut<JobSeekerMyApplicationsController>(
      () => JobSeekerMyApplicationsController(),
    );

    Get.lazyPut<JobSeekerSavedJobsController>(
      () => JobSeekerSavedJobsController(),
    );

    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
