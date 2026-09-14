import 'package:get/get.dart';

import '../controllers/company_notifications_controller.dart';

class CompanyNotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompanyNotificationsController>(
      () => CompanyNotificationsController(),
    );
  }
}
