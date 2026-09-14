import 'package:get/get.dart';

import '../controllers/company_dashboard_controller.dart';

class CompanyDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompanyDashboardController>(
      () => CompanyDashboardController(),
    );
  }
}
