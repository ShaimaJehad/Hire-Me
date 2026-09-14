import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../routes/app_pages.dart';
import '../services/storage_service.dart';

class RoleGuardMiddleware extends GetMiddleware {
  RoleGuardMiddleware({required this.requiredRole});

  final String requiredRole;

  @override
  RouteSettings? redirect(String? _) {
    if (!Get.isRegistered<StorageService>()) {
      return const RouteSettings(name: Routes.authLogin);
    }

    final storage = StorageService.to;
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null || !storage.isLoggedIn) {
      storage.clearAuthSession();
      return const RouteSettings(name: Routes.authLogin);
    }

    final role = StorageService.normalizeRole(storage.userRole);
    if (role == null) {
      storage.clearAuthSession();
      return const RouteSettings(name: Routes.authLogin);
    }

    if (role != requiredRole) {
      final targetRoute = role == AppUserRole.company.value
          ? Routes.companyMainWrapper
          : Routes.mainWrapper;
      return RouteSettings(name: targetRoute);
    }

    return null;
  }
}
