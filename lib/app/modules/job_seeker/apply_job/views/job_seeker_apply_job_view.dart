import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hire_me/app/modules/job_seeker/apply_job/views/widgets/apply_cv_upload_box.dart';
import 'package:hire_me/app/modules/job_seeker/apply_job/views/widgets/apply_job_button.dart';
import 'package:hire_me/core/utils/app_color.dart';
import 'package:hire_me/core/utils/app_text_style.dart';

import '../controllers/job_seeker_apply_job_controller.dart';

class JobSeekerApplyJobView extends GetView<JobSeekerApplyJobController> {
  const JobSeekerApplyJobView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            _buildLabel('Full Name'),
            const SizedBox(height: 8),
            _buildTextField(controller: controller.nameController),

            const SizedBox(height: 20),

            _buildLabel('Email'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: controller.emailController,
              readOnly: true,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 20),

            _buildLabel('Upload Cv\\Resume'),
            const SizedBox(height: 8),
            const ApplyCvUploadBox(),

            const SizedBox(height: 40),

            const ApplyJobButton(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColor.kblue,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      title: Text('Apply job', style: CustomTextstyle.interSemiBoldwhite),
      centerTitle: true,
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: Icon(
            Icons.notifications_outlined,
            color: Colors.white,
            size: 26,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: CustomTextstyle.interRegular500black);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintStyle: const TextStyle(color: Color(0xFF8A8A9A), fontSize: 14),
        filled: true,
        fillColor: readOnly ? const Color(0xFFEEEEEE) : Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.kblue, width: 1.8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
