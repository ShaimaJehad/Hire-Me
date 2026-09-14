import 'package:get/get.dart';

import '../controllers/jobseekercongratulations_controller.dart';

class JobSeekerCongratulationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JobSeekerCongratulationsController>(
      () => JobSeekerCongratulationsController(),
    );
  }
}
