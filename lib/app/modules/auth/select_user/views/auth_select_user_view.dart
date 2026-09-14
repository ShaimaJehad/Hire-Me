import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import '../../../../../core/utils/app_assets.dart';
import '../../../../../core/utils/app_color.dart';
import '../../../../../core/utils/app_string.dart';
import '../../../../../core/utils/app_text_style.dart';

import '../controllers/auth_select_user_controller.dart';

class AuthSelectUserView extends GetView<AuthSelectUserController> {
  const AuthSelectUserView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.kwhite,
      body: Stack(
        children: [
          Positioned(
            top: 450,
            bottom: 0,
            left: -10,
            child: SvgPicture.asset(Assets.imagesObjects, width: 150),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                Center(
                  child: Text(
                    AppString.selectUserType,
                    style: CustomTextstyle.poppinsBold,
                  ),
                ),

                const SizedBox(height: 30),

                Obx(
                  () => _RoleCard(
                    title: AppString.company,

                    image: Assets.imagesCompany,

                    isSelected: controller.selectedRole.value == 'company',
                    onTap: () => controller.selectRole('company'),
                  ),
                ),

                const SizedBox(height: 30),

                Obx(
                  () => _RoleCard(
                    title: AppString.user,
                    image: Assets.imagesUser,
                    isSelected: controller.selectedRole.value == 'jobSeeker',
                    onTap: () => controller.selectRole('jobSeeker'),
                  ),
                ),

                const Spacer(),

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
                    child: Text(
                      AppString.next,
                      style: CustomTextstyle.interRegular,
                    ),
                  ),
                ),

                const SizedBox(height: 42),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String image;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.image,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),

        height: 220,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFEAEFF9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColor.kblue : AppColor.ewhite,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColor.kwhite,
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 160,
              height: 180,

              child: Image.asset(
                image,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  title == 'Company'
                      ? Icons.business_rounded
                      : Icons.person_rounded,
                  size: 50,

                  color: AppColor.kblue,
                ),
              ),
            ),
            SizedBox(width: 24.0),
            Expanded(
              child: Center(
                child: Text(title, style: CustomTextstyle.interBold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
