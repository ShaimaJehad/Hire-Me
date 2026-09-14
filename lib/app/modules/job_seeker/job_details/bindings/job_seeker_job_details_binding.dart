import 'package:get/get.dart';

import '../controllers/job_seeker_job_details_controller.dart';

class JobSeekerJobDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JobSeekerJobDetailsController>(
      () => JobSeekerJobDetailsController(),
    );
  }
}
