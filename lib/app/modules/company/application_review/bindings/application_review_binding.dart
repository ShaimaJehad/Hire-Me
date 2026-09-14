import 'package:get/get.dart';

import '../controllers/application_review_controller.dart';

class ApplicationReviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApplicationReviewController>(
      () => ApplicationReviewController(),
    );
  }
}
