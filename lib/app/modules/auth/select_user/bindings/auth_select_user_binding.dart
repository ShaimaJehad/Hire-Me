import 'package:get/get.dart';

import '../controllers/auth_select_user_controller.dart';

class AuthSelectUserBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthSelectUserController>(
      () => AuthSelectUserController(),
    );
  }
}
