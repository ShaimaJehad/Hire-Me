import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../../routes/app_pages.dart';
import '../../../../../core/utils/app_color.dart';

class AuthSelectUserController extends GetxController {
  final selectedRole = ''.obs;

  void selectRole(String role) {
    selectedRole.value = role;
  }

  void onNextPressed() {
    if (selectedRole.value.isEmpty) {
      Get.snackbar(
        'تنبيه',
        'الرجاء اختيار نوع المستخدم أولاً',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.kblue,
        colorText: const Color(0xFFFFFFFF),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    Get.toNamed(Routes.authRegister, arguments: {'role': selectedRole.value});
  }
}
