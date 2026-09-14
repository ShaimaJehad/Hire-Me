import 'package:get/get.dart';

import '../controllers/job_seeker_my_applications_controller.dart';

class JobSeekerMyApplicationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JobSeekerMyApplicationsController>(
      () => JobSeekerMyApplicationsController(),
    );
  }
}
