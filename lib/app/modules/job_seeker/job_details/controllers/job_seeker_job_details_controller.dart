import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import 'package:hire_me/app/modules/job_seeker/dashboard/models/job_model.dart';
import 'package:hire_me/app/routes/app_pages.dart';

class JobSeekerJobDetailsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Rxn<JobModel> job = Rxn<JobModel>();
  final isSaved = false.obs;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    if (args is JobModel) {
      job.value = args;
      checkIfSaved();
    } else {
      Get.snackbar('Error', 'Job data not found');
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.back();
      });
    }
  }

  Future<void> checkIfSaved() async {
    try {
      final uid = _auth.currentUser?.uid;
      final currentJob = job.value;

      if (uid == null || currentJob == null) return;

      final docId = '${uid}_${currentJob.id}';

      final doc = await _firestore.collection('savedJobs').doc(docId).get();

      isSaved.value = doc.exists;
    } catch (_) {
      isSaved.value = false;
    }
  }

  Future<void> toggleSaveJob() async {
    try {
      final uid = _auth.currentUser?.uid;
      final currentJob = job.value;

      if (uid == null) {
        Get.snackbar('Login Required', 'Please login to save jobs');
        return;
      }

      if (currentJob == null) return;

      final docId = '${uid}_${currentJob.id}';
      final savedJobRef = _firestore.collection('savedJobs').doc(docId);

      if (isSaved.value) {
        await savedJobRef.delete();
        isSaved.value = false;
      } else {
        await savedJobRef.set({
          'seekerId': uid,
          'jobId': currentJob.id,
          'savedAt': FieldValue.serverTimestamp(),
        });

        isSaved.value = true;
      }
    } catch (_) {
      Get.snackbar('Error', 'Failed to update saved job');
    }
  }

  void goToApplyJob() {
    final currentJob = job.value;

    if (currentJob == null) return;

    if (currentJob.status == 'Closed') {
      Get.snackbar('Closed Job', 'You cannot apply for a closed job');
      return;
    }

    Get.toNamed(Routes.jobSeekerApplyJob, arguments: currentJob);
  }

  String formatJobType(String value) {
    if (value == 'FullTime') return 'Full Time';
    if (value == 'PartTime') return 'Part Time';
    return value;
  }
}
