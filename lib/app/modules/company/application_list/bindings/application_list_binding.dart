import 'package:get/get.dart';

import '../controllers/application_list_controller.dart';

class ApplicationListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApplicationListController>(
      () => ApplicationListController(),
    );
  }
}
