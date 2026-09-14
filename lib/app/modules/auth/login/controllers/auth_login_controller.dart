import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_pages.dart';
import '../../../../services/notification_service.dart';
import '../../../../services/storage_service.dart';

class AuthLoginController extends GetxController {
  // Controllers are eagerly initialized when AuthLoginController is created.
  // This is safe because onClose() below guarantees they are disposed.
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final rememberMe = false.obs;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = StorageService.to;

  void toggleObscure() => obscurePassword.toggle();
  void toggleRememberMe() => rememberMe.toggle();

  Future<void> onSignInPressed() async {
    if (!_isValid()) return;

    _setLoading(true);
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Guard: if the controller/route was disposed while we awaited
      // (e.g. user pressed back or killed the page), stop immediately.
      if (isClosed) return;

      await _navigateAfterLogin(credential.user);
    } on FirebaseAuthException catch (e) {
      if (isClosed) return;
      _showError(_mapFirebaseError(e.code));
      _setLoading(false);
    } catch (e, s) {
      debugPrint('Unexpected login error: $e\n$s');

      // Always clean up auth state, even if the widget is gone.
      await _auth.signOut();
      await _storage.clearAuthSession();

      if (isClosed) return;
      _showError('Unable to complete sign in');
      _setLoading(false);
    }
    // NOTE: No 'finally' block that resets isLoading.
    // If _navigateAfterLogin succeeds, Get.offAllNamed destroys this route.
    // Updating any observable here would force a rebuild on dying widgets,
    // which causes the "used after disposed" crash.
  }

  void onForgotPasswordPressed() {
    Get.toNamed(Routes.authForgotPassword);
  }

  void onCreateAccountPressed() {
    Get.toNamed(Routes.authSelectUser);
  }

  bool _isValid() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please fill all fields');
      return false;
    }
    if (!GetUtils.isEmail(email)) {
      _showError('Please enter a valid email');
      return false;
    }
    return true;
  }

  Future<void> _navigateAfterLogin(User? user) async {
    if (user == null) {
      _showError('Unable to complete sign in');
      _setLoading(false);
      return;
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();

    // After every await, check if the controller is still alive.
    if (isClosed) return;

    final role = StorageService.normalizeRole(doc.data()?['role'] as String?);

    if (role == null) {
      // Critical cleanup: sign out and clear local session regardless of UI state.
      await _auth.signOut();
      await _storage.clearAuthSession();

      if (isClosed) return;
      _showError('No valid role was found for this account');
      _setLoading(false);
      return;
    }

    await _storage.saveAuthSession(
      userId: user.uid,
      role: role,
      accessToken: await user.getIdToken(),
      companyId: role == AppUserRole.company.value ? user.uid : null,
      jobSeekerId: role == AppUserRole.jobSeeker.value ? user.uid : null,
    );

    await Get.find<NotificationService>().saveFcmToken();

    if (isClosed) return;

    // Dismiss keyboard and remove focus before the route is destroyed.
    // This prevents "FocusNode was disposed with an active focus" errors.
    FocusManager.instance.primaryFocus?.unfocus();

    if (role == AppUserRole.company.value) {
      Get.offAllNamed(Routes.companyMainWrapper);
    } else {
      Get.offAllNamed(Routes.mainWrapper);
    }

    // Intentionally NOT calling _setLoading(false) here.
    // The login route is gone; touching observables now rebuilds dead widgets.
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Try again later';
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

  /// Safely sets [isLoading]. Prevents updating observables after the
  /// controller has been closed, which would trigger a rebuild on a
  /// disposed widget tree.
  void _setLoading(bool value) {
    if (isClosed) return;
    isLoading.value = value;
  }

  @override
  void onClose() {
    // Dispose text controllers before calling super.onClose().
    // This ensures they are cleaned up exactly once.
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
