import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../../routes/app_pages.dart';
import '../../../../services/storage_service.dart';

class AuthSplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    try {
      await Future.delayed(const Duration(seconds: 3));

      final storage = StorageService.to;

      if (storage.isFirstTime) {
        Get.offAllNamed(Routes.onboarding);
        return;
      }

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        await storage.clearAuthSession();
        Get.offAllNamed(Routes.authLogin);
        return;
      }

      final cachedRole = StorageService.normalizeRole(storage.userRole);
      final role = cachedRole ?? await _loadRoleFromFirestore(user.uid);

      if (role == null) {
        await storage.clearAuthSession();
        await FirebaseAuth.instance.signOut();
        Get.offAllNamed(Routes.authLogin);
        return;
      }

      await storage.saveAuthSession(
        userId: user.uid,
        role: role,
        accessToken: await user.getIdToken(),
        companyId: role == AppUserRole.company.value ? user.uid : null,
        jobSeekerId: role == AppUserRole.jobSeeker.value ? user.uid : null,
      );

      if (role == AppUserRole.company.value) {
        Get.offAllNamed(Routes.companyMainWrapper);
      } else {
        Get.offAllNamed(Routes.mainWrapper);
      }
    } catch (_) {
      await FirebaseAuth.instance.signOut();
      if (Get.isRegistered<StorageService>()) {
        await StorageService.to.clearAuthSession();
      }
      Get.offAllNamed(Routes.authLogin);
    }
  }

  Future<String?> _loadRoleFromFirestore(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    return StorageService.normalizeRole(doc.data()?['role'] as String?);
  }
}
