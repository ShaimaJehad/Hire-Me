import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import 'package:hire_me/app/modules/job_seeker/dashboard/models/job_model.dart';

class JobSeekerSavedJobsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _savedJobsSubscription;

  final savedJobs = <JobModel>[].obs;
  final savedJobIds = <String>{}.obs;

  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    listenToSavedJobs();
  }

  void listenToSavedJobs() {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      isLoading.value = false;
      return;
    }

    isLoading.value = true;

    _savedJobsSubscription = _firestore
        .collection('savedJobs')
        .where('seekerId', isEqualTo: uid)
        .snapshots()
        .listen(
          (snapshot) async {
            try {
              final jobIds = snapshot.docs
                  .map((doc) => doc.data()['jobId']?.toString() ?? '')
                  .where((id) => id.isNotEmpty)
                  .toSet();

              savedJobIds.clear();
              savedJobIds.addAll(jobIds);
              if (jobIds.isEmpty) {
                savedJobs.clear();
                isLoading.value = false;
                return;
              }

              final jobs = <JobModel>[];
              final jobSnap = await _firestore
                  .collection('jobs')
                  .where(FieldPath.documentId, whereIn: jobIds.toList())
                  .get();
              for (final doc in jobSnap.docs) {
                jobs.add(JobModel.fromMap(doc.id, doc.data()));
              }

              jobs.sort((a, b) {
                final aDate = a.createdAt?.toDate();
                final bDate = b.createdAt?.toDate();

                if (aDate == null && bDate == null) return 0;
                if (aDate == null) return 1;
                if (bDate == null) return -1;

                return bDate.compareTo(aDate);
              });

              savedJobs.value = jobs;
              isLoading.value = false;
            } catch (_) {
              isLoading.value = false;
              if (_auth.currentUser == null) return;
              Get.snackbar('Error', 'Failed to load saved jobs');
            }
          },
          onError: (_) {
            isLoading.value = false;
            if (_auth.currentUser == null) return;
            Get.snackbar('Error', 'Failed to load saved jobs');
          },
        );
  }

  bool isJobSaved(String jobId) {
    return savedJobIds.contains(jobId);
  }

  Future<void> removeSavedJob(String jobId) async {
    try {
      final uid = _auth.currentUser?.uid;

      if (uid == null) {
        Get.snackbar('Login Required', 'Please login first');
        return;
      }

      final docId = '${uid}_$jobId';

      await _firestore.collection('savedJobs').doc(docId).delete();

      savedJobs.removeWhere((job) => job.id == jobId);

      final updatedIds = {...savedJobIds};
      updatedIds.remove(jobId);
      savedJobIds.remove(jobId);
      Get.snackbar('Removed', 'Job removed from saved jobs');
    } catch (_) {
      Get.snackbar('Error', 'Failed to remove saved job');
    }
  }

  Future<void> refreshSavedJobs() async {
    listenToSavedJobs();
  }

  @override
  void onClose() {
    _savedJobsSubscription?.cancel();
    super.onClose();
  }
}
