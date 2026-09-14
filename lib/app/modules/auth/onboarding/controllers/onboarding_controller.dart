import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../services/storage_service.dart';
import '../../../../../core/utils/app_assets.dart';
import '../../../../routes/app_pages.dart';

class OnboardingPageModel {
  final String image;
  final String title;
  final String subtitle;

  const OnboardingPageModel({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}

class OnboardingController extends GetxController {
  late final PageController pageController;
  final currentPage = 0.obs;

  final List<OnboardingPageModel> pages = const [
    OnboardingPageModel(
      image: Assets.imagesOnboard1,
      title: 'Your Career Starts Here',
      subtitle: 'Begin your journey today',
    ),
    OnboardingPageModel(
      image: Assets.imagesOnboard2,
      title: 'Find The Right Talent',
      subtitle: 'Post jobs, hire faster',
    ),
    OnboardingPageModel(
      image: Assets.imagesOnboard3,
      title: 'One Click to Your Future',
      subtitle: 'Your future in one tap',
    ),
    OnboardingPageModel(
      image: Assets.imagesOnboard4,
      title: 'Connecting Talent to Opportunities',
      subtitle: 'Skills that meet opportunities',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  bool get isLastPage => currentPage.value == pages.length - 1;

  void onPageChanged(int index) => currentPage.value = index;

  void onNextPressed() {
    if (!isLastPage) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _goToSelectUser();
    }
  }

  void onSkipPressed() => _goToSelectUser();

  Future<void> _goToSelectUser() async {
    await StorageService.to.markOnboardingComplete();
    Get.offAllNamed(Routes.authSelectUser);
  }
}
