import 'package:get/get.dart';

import '../controllers/job_seeker_dashboard_controller.dart';

class JobSeekerDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JobSeekerDashboardController>(
      () => JobSeekerDashboardController(),
    );
  }
}
