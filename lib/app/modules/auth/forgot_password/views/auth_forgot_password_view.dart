import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/app_color.dart';
import '../../../../../core/utils/app_text_style.dart';
import '../controllers/auth_forgot_password_controller.dart';

class AuthForgotPasswordView extends GetView<AuthForgotPasswordController> {
  const AuthForgotPasswordView({super.key});

  bool get _isResetStep {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    return args['step'] == 'reset';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _isResetStep ? _buildResetStep() : _buildEmailStep(),
        ),
      ),
    );
  }

  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 80),
        _buildTitle(
          title: 'Forgot Password?',
          subtitle: 'Recover your password if you have\nforgot the password!',
        ),
        const SizedBox(height: 60),
        _AuthTextField(
          controller: controller.emailController,
          hint: 'Email',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 40),
        _buildButton(
          label: 'Submit',
          onPressed: controller.onSubmitEmailPressed,
          isLoading: controller.isLoading,
        ),
      ],
    );
  }

  Widget _buildResetStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 80),
        _buildTitle(
          title: 'Forgot Password?',
          subtitle: 'Set your new password to login into your account!',
        ),
        const SizedBox(height: 60),
        Obx(
          () => _AuthTextField(
            controller: controller.newPasswordController,
            hint: 'Enter New Password',
            obscure: controller.obscureNew.value,
            suffixIcon: GestureDetector(
              onTap: controller.toggleObscureNew,
              child: Icon(
                controller.obscureNew.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF8A8A9A),
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => _AuthTextField(
            controller: controller.rePasswordController,
            hint: 'Re_Password',
            obscure: controller.obscureRe.value,
            suffixIcon: GestureDetector(
              onTap: controller.toggleObscureRe,
              child: Icon(
                controller.obscureRe.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF8A8A9A),
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        _buildButton(
          label: 'Confirm',
          onPressed: controller.onConfirmPressed,
          isLoading: controller.isLoading,
        ),
      ],
    );
  }

  Widget _buildTitle({required String title, required String subtitle}) {
    return Column(
      children: [
        Text(title, style: CustomTextstyle.poppinsBold2),
        const SizedBox(height: 16),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: CustomTextstyle.poppinsSemiBold,
        ),
      ],
    );
  }

  Widget _buildButton({
    required String label,
    required Future<void> Function() onPressed,
    required RxBool isLoading,
  }) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: isLoading.value ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.kblue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: isLoading.value
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(label, style: CustomTextstyle.poppinsSemiBoldWhite),
        ),
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType keyboardType;
  final Widget? suffixIcon;

  const _AuthTextField({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF8A8A9A), fontSize: 15),
        filled: true,
        fillColor: const Color(0xFFF0F3FF),
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1A3794), width: 1.8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
      ),
    );
  }
}
