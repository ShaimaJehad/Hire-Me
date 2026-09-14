import 'package:get/get.dart';

import '../controllers/job_seeker_saved_jobs_controller.dart';

class JobSeekerSavedJobsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JobSeekerSavedJobsController>(
      () => JobSeekerSavedJobsController(),
    );
  }
}
