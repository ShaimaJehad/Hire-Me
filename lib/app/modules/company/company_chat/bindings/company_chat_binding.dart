import 'package:get/get.dart';

import '../controllers/company_chat_controller.dart';

class CompanyChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompanyChatController>(
      () => CompanyChatController(),
    );
  }
}
