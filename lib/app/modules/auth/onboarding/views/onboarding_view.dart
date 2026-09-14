import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/app_assets.dart';
import '../../../../../core/utils/app_color.dart';
import '../../../../../core/utils/app_string.dart';
import '../../../../../core/utils/app_text_style.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 450,
              bottom: 0,
              left: -10,
              child: SvgPicture.asset(Assets.imagesObjects, width: 150),
            ),
            PageView.builder(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              itemCount: controller.pages.length,
              itemBuilder: (_, index) =>
                  _OnboardingSlide(page: controller.pages[index]),
            ),

            Positioned(
              top: 16,
              right: 20,
              child: Obx(
                () => controller.isLastPage
                    ? const SizedBox.shrink()
                    : GestureDetector(
                        onTap: controller.onSkipPressed,
                        child: Text(
                          AppString.skip,
                          style: CustomTextstyle.montserratMedium,
                        ),
                      ),
              ),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
      child: Column(
        children: [
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                controller.pages.length,
                (i) =>
                    _DotIndicator(isActive: controller.currentPage.value == i),
              ),
            ),
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: controller.onNextPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.kblue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(AppString.next, style: CustomTextstyle.interRegular),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  final OnboardingPageModel page;
  const _OnboardingSlide({required this.page});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 60),

          SizedBox(
            height: screenHeight * 0.45,
            child: Image.asset(
              page.image,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Icon(
                Icons.image_outlined,
                size: 120,
                color: Colors.grey.shade300,
              ),
            ),
          ),

          const SizedBox(height: 36),

          Text(
            page.title,
            textAlign: TextAlign.center,
            style: CustomTextstyle.poppinsBold,
          ),

          const SizedBox(height: 12),

          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: CustomTextstyle.interSemiBold,
          ),
        ],
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  final bool isActive;
  const _DotIndicator({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColor.kblue : AppColor.greyVeryLight,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
