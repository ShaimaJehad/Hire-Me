import 'package:get/get.dart';

import '../controllers/company_post_job_controller.dart';

class CompanyPostJobBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompanyPostJobController>(() => CompanyPostJobController());
  }
}
