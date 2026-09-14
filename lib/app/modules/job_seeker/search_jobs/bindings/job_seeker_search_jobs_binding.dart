import 'package:get/get.dart';

import '../controllers/job_seeker_search_jobs_controller.dart';

class JobSeekerSearchJobsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JobSeekerSearchJobsController>(
      () => JobSeekerSearchJobsController(),
    );
  }
}
