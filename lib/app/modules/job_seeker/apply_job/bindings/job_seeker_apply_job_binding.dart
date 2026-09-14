import 'package:get/get.dart';

import '../controllers/job_seeker_apply_job_controller.dart';

class JobSeekerApplyJobBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JobSeekerApplyJobController>(
      () => JobSeekerApplyJobController(),
    );
  }
}
