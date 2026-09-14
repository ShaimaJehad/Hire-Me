import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hire_me/app/modules/job_seeker/dashboard/models/job_model.dart';

class JobSeekerSearchJobsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController searchController = TextEditingController();

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _jobsSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _savedJobsSubscription;

  final allJobs = <JobModel>[].obs;
  final searchResults = <JobModel>[].obs;
  final savedJobIds = <String>{}.obs;

  final isLoading = true.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    listenToOpenJobs();
    listenToSavedJobs();
  }

  void listenToOpenJobs() {
    isLoading.value = true;

    _jobsSubscription = _firestore
        .collection('jobs')
        .where('status', isEqualTo: 'Open')
        .snapshots()
        .listen(
          (snapshot) {
            final jobs = snapshot.docs
                .map((doc) => JobModel.fromMap(doc.id, doc.data()))
                .toList();

            jobs.sort((a, b) {
              final aDate = a.createdAt?.toDate();
              final bDate = b.createdAt?.toDate();

              if (aDate == null && bDate == null) return 0;
              if (aDate == null) return 1;
              if (bDate == null) return -1;

              return bDate.compareTo(aDate);
            });

            allJobs.value = jobs;
            applySearch();

            isLoading.value = false;
          },
          onError: (_) {
            isLoading.value = false;
            if (_auth.currentUser == null) return;
            Get.snackbar('Error', 'Failed to load jobs');
          },
        );
  }

  void listenToSavedJobs() {
    final uid = _auth.currentUser?.uid;

    if (uid == null) return;

    _savedJobsSubscription = _firestore
        .collection('savedJobs')
        .where('seekerId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
          final ids = snapshot.docs
              .map((doc) => doc.data()['jobId']?.toString() ?? '')
              .where((id) => id.isNotEmpty)
              .toSet();

          savedJobIds.clear();
          savedJobIds.addAll(ids);
        });
  }

  void onSearchChanged(String value) {
    searchQuery.value = value.trim();
    applySearch();
  }

  void applySearch() {
    final query = searchQuery.value.toLowerCase();

    if (query.isEmpty) {
      searchResults.value = allJobs;
      return;
    }

    final results = allJobs.where((job) {
      return job.title.toLowerCase().contains(query) ||
          job.companyName.toLowerCase().contains(query) ||
          job.mainFieldName.toLowerCase().contains(query) ||
          job.location.toLowerCase().contains(query) ||
          job.jobType.toLowerCase().contains(query) ||
          job.workMode.toLowerCase().contains(query) ||
          job.description.toLowerCase().contains(query) ||
          job.requirements.toLowerCase().contains(query);
    }).toList();

    searchResults.value = results;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    searchResults.value = allJobs;
  }

  bool isJobSaved(String jobId) {
    return savedJobIds.contains(jobId);
  }

  Future<void> toggleSaveJob(String jobId) async {
    try {
      final uid = _auth.currentUser?.uid;

      if (uid == null) {
        Get.snackbar('Login Required', 'Please login to save jobs');
        return;
      }

      final docId = '${uid}_$jobId';
      final savedJobRef = _firestore.collection('savedJobs').doc(docId);

      if (isJobSaved(jobId)) {
        await savedJobRef.delete();
      } else {
        await savedJobRef.set({
          'seekerId': uid,
          'jobId': jobId,
          'savedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {
      Get.snackbar('Error', 'Failed to update saved job');
    }
  }

  Future<void> refreshSearch() async {
    applySearch();
  }

  @override
  void onClose() {
    _jobsSubscription?.cancel();
    _savedJobsSubscription?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
