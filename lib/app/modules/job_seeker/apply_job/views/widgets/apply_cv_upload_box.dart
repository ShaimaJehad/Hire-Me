import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hire_me/app/modules/job_seeker/apply_job/controllers/job_seeker_apply_job_controller.dart';
import 'package:hire_me/core/utils/app_color.dart';

class ApplyCvUploadBox extends GetView<JobSeekerApplyJobController> {
  const ApplyCvUploadBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: controller.pickCV,
        child: Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: controller.cvFileName.value.isEmpty
              ? const _EmptyUploadContent()
              : _SelectedFileContent(fileName: controller.cvFileName.value),
        ),
      ),
    );
  }
}

class _EmptyUploadContent extends StatelessWidget {
  const _EmptyUploadContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.cloud_upload_outlined,
          size: 48,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 8),
        Text(
          'Tap to upload PDF or Word',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
      ],
    );
  }
}

class _SelectedFileContent extends StatelessWidget {
  const _SelectedFileContent({required this.fileName});

  final String fileName;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.insert_drive_file_outlined, size: 40, color: AppColor.kblue),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            fileName,
            style: TextStyle(
              color: AppColor.kblue,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
