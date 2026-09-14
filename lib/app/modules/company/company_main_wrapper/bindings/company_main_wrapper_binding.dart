import 'package:get/get.dart';

import '../../application_list/controllers/application_list_controller.dart';
import '../../company_chat/controllers/company_chat_controller.dart';
import '../../company_profile/controllers/company_profile_controller.dart';
import '../../dashboard/controllers/company_dashboard_controller.dart';
import '../../post_job/controllers/company_post_job_controller.dart';
import '../controllers/company_main_wrapper_controller.dart';

class CompanyMainWrapperBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompanyMainWrapperController>(
      () => CompanyMainWrapperController(),
      fenix: true,
    );

    Get.lazyPut<ApplicationListController>(
      () => ApplicationListController(),
      fenix: true,
    );

    Get.lazyPut<CompanyChatController>(
      () => CompanyChatController(),
      fenix: true,
    );

    Get.lazyPut<CompanyDashboardController>(
      () => CompanyDashboardController(),
      fenix: true,
    );

    Get.lazyPut<CompanyPostJobController>(
      () => CompanyPostJobController(),
      fenix: true,
    );

    Get.lazyPut<CompanyProfileController>(
      () => CompanyProfileController(),
      fenix: true,
    );
  }
}
