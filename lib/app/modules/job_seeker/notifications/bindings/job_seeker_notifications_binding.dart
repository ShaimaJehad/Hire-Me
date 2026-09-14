import 'package:get/get.dart';

import '../controllers/job_seeker_notifications_controller.dart';

class JobSeekerNotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JobSeekerNotificationsController>(
      () => JobSeekerNotificationsController(),
    );
  }
}
