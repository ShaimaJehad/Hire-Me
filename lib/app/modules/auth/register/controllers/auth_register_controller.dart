import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_pages.dart';
import '../../../../services/notification_service.dart';
import '../../../../services/storage_service.dart';

class AuthRegisterController extends GetxController {
  final nameController = TextEditingController();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final obscureConfirm = true.obs;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = StorageService.to;

  String get _role {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    return StorageService.normalizeRole(args['role'] as String?) ??
        AppUserRole.jobSeeker.value;
  }

  void toggleObscurePassword() => obscurePassword.toggle();
  void toggleObscureConfirm() => obscureConfirm.toggle();

  Future<void> onSignUpPressed() async {
    if (!_isValid()) return;

    isLoading.value = true;
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = credential.user;
      if (user == null) {
        _showError('Unable to create account. Please try again.');
        return;
      }

      await _saveUserToFirestore(user.uid);
      await _storage.saveAuthSession(
        userId: user.uid,
        role: _role,
        accessToken: await user.getIdToken(),
        companyId: _role == AppUserRole.company.value ? user.uid : null,
        jobSeekerId: _role == AppUserRole.jobSeeker.value ? user.uid : null,
      );

      await Get.find<NotificationService>().saveFcmToken();

      _navigateAfterRegister();
    } on FirebaseAuthException catch (e) {
      _showError(_mapFirebaseError(e.code));
    } catch (_) {
      await _auth.signOut();
      await _storage.clearAuthSession();
      _showError('Unable to complete account creation');
    } finally {
      isLoading.value = false;
    }
  }

  void onLoginPressed() => Get.offAllNamed(Routes.authLogin);

  bool _isValid() {
    if (nameController.text.trim().isEmpty) {
      _showError('Please enter your full name');
      return false;
    }
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        confirmPasswordController.text.trim().isEmpty) {
      _showError('Please fill all fields');
      return false;
    }
    if (!GetUtils.isEmail(emailController.text.trim())) {
      _showError('Please enter a valid email');
      return false;
    }
    if (passwordController.text != confirmPasswordController.text) {
      _showError('Passwords do not match');
      return false;
    }
    if (passwordController.text.length < 6) {
      _showError('Password must be at least 6 characters');
      return false;
    }
    return true;
  }

  Future<void> _saveUserToFirestore(String uid) async {
    final collection = _role == AppUserRole.company.value ? 'companies' : 'jobSeekers';
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'name': nameController.text.trim(),

      'email': emailController.text.trim(),
      'role': _role,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _firestore.collection(collection).doc(uid).set({
      'uid': uid,
      'name': nameController.text.trim(),

      'email': emailController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  void _navigateAfterRegister() {
    if (_role == AppUserRole.company.value) {
      Get.offAllNamed(Routes.companyMainWrapper);
    } else {
      Get.offAllNamed(Routes.mainWrapper);
    }
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak';
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

  @override
  void onClose() {
    nameController.dispose();

    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
