import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hire_me/app/modules/job_seeker/apply_job/controllers/job_seeker_apply_job_controller.dart';
import 'package:hire_me/core/utils/app_color.dart';
import 'package:hire_me/core/utils/app_string.dart';
import 'package:hire_me/core/utils/app_text_style.dart';

class ApplyJobButton extends GetView<JobSeekerApplyJobController> {
  const ApplyJobButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : controller.onApplyPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.kblue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.4,
                  ),
                )
              : Text(
                  AppString.apply,
                  style: CustomTextstyle.interRegular400white,
                ),
        ),
      ),
    );
  }
}
