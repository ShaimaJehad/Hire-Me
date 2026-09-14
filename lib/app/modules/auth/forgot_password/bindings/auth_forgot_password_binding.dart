import 'package:get/get.dart';

import '../controllers/auth_forgot_password_controller.dart';

class AuthForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthForgotPasswordController>(
      () => AuthForgotPasswordController(),
    );
  }
}
