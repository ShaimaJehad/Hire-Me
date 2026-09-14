import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_pages.dart';

class AuthForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  final newPasswordController = TextEditingController();
  final rePasswordController = TextEditingController();

  final isLoading = false.obs;
  final obscureNew = true.obs;
  final obscureRe = true.obs;

  final _auth = FirebaseAuth.instance;

  void toggleObscureNew() => obscureNew.toggle();
  void toggleObscureRe() => obscureRe.toggle();

  Future<void> onSubmitEmailPressed() async {
    if (emailController.text.trim().isEmpty) {
      _showError('Please enter your email');
      return;
    }
    if (!GetUtils.isEmail(emailController.text.trim())) {
      _showError('Please enter a valid email');
      return;
    }

    isLoading.value = true;
    try {
      await _auth.sendPasswordResetEmail(email: emailController.text.trim());
      _showSuccess('Reset link sent! Check your email');

      await Future.delayed(const Duration(seconds: 2));
      Get.offAllNamed(Routes.authLogin);
    } on FirebaseAuthException catch (e) {
      _showError(_mapFirebaseError(e.code));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onConfirmPressed() async {
    if (!_isResetValid()) return;

    isLoading.value = true;
    try {
      await _auth.currentUser?.updatePassword(
        newPasswordController.text.trim(),
      );
      _showSuccess('Password updated successfully!');
      Get.offAllNamed(Routes.authLogin);
    } on FirebaseAuthException catch (e) {
      _showError(_mapFirebaseError(e.code));
    } finally {
      isLoading.value = false;
    }
  }

  bool _isResetValid() {
    if (newPasswordController.text.trim().isEmpty ||
        rePasswordController.text.trim().isEmpty) {
      _showError('Please fill all fields');
      return false;
    }
    if (newPasswordController.text != rePasswordController.text) {
      _showError('Passwords do not match');
      return false;
    }
    if (newPasswordController.text.length < 6) {
      _showError('Password must be at least 6 characters');
      return false;
    }
    return true;
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'invalid-email':
        return 'Invalid email address';
      case 'requires-recent-login':
        return 'Please login again to change your password';
      default:
        return 'Something went wrong. Please try again';
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFEF4444),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF22C55E),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    newPasswordController.dispose();
    rePasswordController.dispose();
    super.onClose();
  }
}
