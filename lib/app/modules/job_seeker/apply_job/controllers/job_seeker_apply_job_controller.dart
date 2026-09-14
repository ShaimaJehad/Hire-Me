import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hire_me/app/modules/job_seeker/dashboard/models/job_model.dart';
import 'package:hire_me/app/routes/app_pages.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JobSeekerApplyJobController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  final isLoading = false.obs;
  final cvFileName = ''.obs;
  final cvFilePath = ''.obs;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _supabase = Supabase.instance.client;

  JobModel? get job {
    final args = Get.arguments;
    if (args is JobModel) return args;
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    _setUserEmail();
    _validateJobData();
  }

  void _setUserEmail() {
    final user = _auth.currentUser;
    if (user != null) {
      emailController.text = user.email ?? '';
    }
  }

  void _validateJobData() {
    if (job == null) {
      _showError('Job data not found');
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.back();
      });
    }
  }

  Future<void> pickCV() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.isNotEmpty) {
        cvFileName.value = result.files.single.name;
        cvFilePath.value = result.files.single.path ?? '';
      }
    } catch (e) {
      debugPrint('FilePicker error: $e');
      _showError('Failed to pick CV file');
    }
  }

  Future<void> onApplyPressed() async {
    if (!_validateForm()) return;

    final currentJob = job;
    if (currentJob == null) {
      _showError('Job data not found');
      return;
    }

    final uid = _auth.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      _showError('Please login first');
      return;
    }

    final file = File(cvFilePath.value);
    if (!file.existsSync()) {
      _showError('CV file not found. Please upload again');
      return;
    }

    isLoading.value = true;

    try {
      final alreadyApplied = await _hasAlreadyApplied(
        seekerId: uid,
        jobId: currentJob.id,
      );

      if (alreadyApplied) {
        _showError('You have already applied to this job');
        return;
      }

      final cvUrl = await _uploadCV(uid: uid, file: file);

      await _saveApplication(uid: uid, job: currentJob, cvUrl: cvUrl);

      Get.offNamed(Routes.jobSeekerCongratulations);
    } catch (e) {
      _showError('Failed to apply: $e');
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateForm() {
    if (nameController.text.trim().isEmpty) {
      _showError('Please enter your full name');
      return false;
    }

    if (cvFilePath.value.isEmpty) {
      _showError('Please upload your CV');
      return false;
    }

    return true;
  }

  Future<bool> _hasAlreadyApplied({
    required String seekerId,
    required String jobId,
  }) async {
    final existing = await _firestore
        .collection('applications')
        .where('seekerId', isEqualTo: seekerId)
        .where('jobId', isEqualTo: jobId)
        .limit(1)
        .get();

    return existing.docs.isNotEmpty;
  }

  Future<String> _uploadCV({required String uid, required File file}) async {
    final fileName =
        '${uid}_${DateTime.now().millisecondsSinceEpoch}_${cvFileName.value}';

    await _supabase.storage.from('cv').upload(fileName, file);

    return _supabase.storage.from('cv').getPublicUrl(fileName);
  }

  Future<void> _saveApplication({
    required String uid,
    required JobModel job,
    required String cvUrl,
  }) async {
    final data = <String, dynamic>{
      'jobId': job.id,
      'jobTitle': job.title,
      'companyId': job.companyId,
      'companyName': job.companyName,
      'mainFieldIconUrl': job.mainFieldIconUrl,
      'subFieldIconUrl': job.subFieldIconUrl,
      'seekerId': uid,
      'seekerName': nameController.text.trim(),
      'email': emailController.text.trim(),
      'cvUrl': cvUrl,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('applications').add(data);
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
    super.onClose();
  }
}
