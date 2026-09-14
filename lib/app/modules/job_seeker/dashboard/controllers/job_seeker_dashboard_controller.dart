import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hire_me/app/modules/job_seeker/dashboard/models/job_model.dart';

class JobSeekerDashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController searchTextController = TextEditingController();

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _jobsSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _mainFieldsSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _subFieldsSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _savedJobsSubscription;
  StreamSubscription<int>? _notifBadgeSub;

  final userName = 'User'.obs;

  final allJobs = <JobModel>[].obs;
  final filteredJobs = <JobModel>[].obs;

  final mainFields = <MainFieldModel>[].obs;
  final subFields = <SubFieldModel>[].obs;

  final savedJobIds = <String>{}.obs;
  final notificationBadgeCount = 0.obs;

  final isLoading = true.obs;
  final isMainFieldsLoading = true.obs;
  final isSubFieldsLoading = false.obs;

  final searchQuery = ''.obs;

  final selectedMainFieldId = 'all'.obs;
  final selectedSubFieldId = 'all'.obs;

  final selectedJobType = 'all'.obs;
  final selectedWorkMode = 'all'.obs;
  final selectedLocation = 'all'.obs;

  final jobTypes = const ['all', 'FullTime', 'PartTime', 'Freelance'];

  final workModes = const ['all', 'OnSite', 'Remote', 'Hybrid'];

  List<String> get locations {
    final uniqueLocations = allJobs
        .map((job) => job.location.trim())
        .where((location) => location.isNotEmpty)
        .toSet()
        .toList();

    uniqueLocations.sort();

    return ['all', ...uniqueLocations];
  }

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
    listenToMainFields();
    listenToOpenJobs();
    listenToSavedJobs();
    listenToNotificationBadge();
  }

  Future<void> fetchUserData() async {
    try {
      final uid = _auth.currentUser?.uid;

      if (uid == null) return;

      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final data = userDoc.data();

        userName.value =
            data?['fullName']?.toString() ??
            data?['name']?.toString() ??
            'User';

        return;
      }

      final seekerDoc = await _firestore
          .collection('jobSeekers')
          .doc(uid)
          .get();

      if (seekerDoc.exists) {
        final data = seekerDoc.data();

        userName.value =
            data?['fullName']?.toString() ??
            data?['name']?.toString() ??
            'User';
      }
    } catch (_) {
      userName.value = 'User';
    }
  }

  void listenToMainFields() {
    isMainFieldsLoading.value = true;

    _mainFieldsSubscription?.cancel();

    _mainFieldsSubscription = _firestore
        .collection('mainFields')
        .snapshots()
        .listen(
          (snapshot) {
            final fields = snapshot.docs.map((doc) {
              return MainFieldModel.fromMap(doc.id, doc.data());
            }).toList();

            fields.sort((a, b) => a.name.compareTo(b.name));

            mainFields.value = fields;

            isMainFieldsLoading.value = false;
          },
          onError: (_) {
            isMainFieldsLoading.value = false;
            if (_auth.currentUser == null) return;
            Get.snackbar('Error', 'Failed to load main fields');
          },
        );
  }

  void listenToSubFields(String mainFieldId) {
    _subFieldsSubscription?.cancel();

    selectedSubFieldId.value = 'all';
    subFields.clear();

    if (mainFieldId == 'all' || mainFieldId.isEmpty) {
      isSubFieldsLoading.value = false;
      applyFilters();
      return;
    }

    isSubFieldsLoading.value = true;

    _subFieldsSubscription = _firestore
        .collection('mainFields')
        .doc(mainFieldId)
        .collection('subFields')
        .snapshots()
        .listen(
          (snapshot) {
            final fields = snapshot.docs.map((doc) {
              return SubFieldModel.fromMap(doc.id, doc.data());
            }).toList();

            fields.sort((a, b) => a.name.compareTo(b.name));

            subFields.value = fields;

            isSubFieldsLoading.value = false;
          },
          onError: (_) {
            isSubFieldsLoading.value = false;
            if (_auth.currentUser == null) return;
            Get.snackbar('Error', 'Failed to load specializations');
          },
        );
  }

  void listenToOpenJobs() {
    isLoading.value = true;

    _jobsSubscription?.cancel();

    _jobsSubscription = _firestore
        .collection('jobs')
        .where('status', isEqualTo: 'Open')
        .snapshots()
        .listen(
          (snapshot) {
            final jobs = snapshot.docs
                .map((doc) => JobModel.fromMap(doc.id, doc.data()))
                .where((job) => !job.isDeleted)
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
            applyFilters();

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

    _savedJobsSubscription?.cancel();

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

  void onSearch(String value) {
    searchQuery.value = value.trim();
    applyFilters();
  }

  void selectMainField(String fieldId) {
    selectedMainFieldId.value = fieldId;
    selectedSubFieldId.value = 'all';

    listenToSubFields(fieldId);
    applyFilters();
  }

  void selectSubField(String fieldId) {
    selectedSubFieldId.value = fieldId;
    applyFilters();
  }

  void setJobTypeFilter(String value) {
    selectedJobType.value = value;
    applyFilters();
  }

  void setWorkModeFilter(String value) {
    selectedWorkMode.value = value;
    applyFilters();
  }

  void setLocationFilter(String value) {
    selectedLocation.value = value;
    applyFilters();
  }

  void clearFilters() {
    selectedMainFieldId.value = 'all';
    selectedSubFieldId.value = 'all';
    selectedJobType.value = 'all';
    selectedWorkMode.value = 'all';
    selectedLocation.value = 'all';
    searchQuery.value = '';

    subFields.clear();
    _subFieldsSubscription?.cancel();

    searchTextController.clear();
    applyFilters();
  }

  void applyFilters() {
    Iterable<JobModel> results = allJobs;

    if (selectedMainFieldId.value != 'all') {
      results = results.where(
        (job) => job.mainFieldId == selectedMainFieldId.value,
      );
    }

    if (selectedSubFieldId.value != 'all') {
      results = results.where(
        (job) => job.subFieldId == selectedSubFieldId.value,
      );
    }

    if (selectedJobType.value != 'all') {
      results = results.where((job) => job.jobType == selectedJobType.value);
    }

    if (selectedWorkMode.value != 'all') {
      results = results.where((job) => job.workMode == selectedWorkMode.value);
    }

    if (selectedLocation.value != 'all') {
      results = results.where(
        (job) => job.location.trim() == selectedLocation.value,
      );
    }

    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();

      results = results.where((job) {
        return job.title.toLowerCase().contains(query) ||
            job.companyName.toLowerCase().contains(query) ||
            job.mainFieldName.toLowerCase().contains(query) ||
            job.subFieldName.toLowerCase().contains(query) ||
            job.location.toLowerCase().contains(query) ||
            job.description.toLowerCase().contains(query);
      });
    }

    filteredJobs.value = results.toList();
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

      final savedJobDocId = '${uid}_$jobId';

      final savedJobRef = _firestore.collection('savedJobs').doc(savedJobDocId);

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

  void listenToNotificationBadge() {
    final uid = _auth.currentUser?.uid;

    if (uid == null) return;

    _notifBadgeSub = _firestore
        .collection('notifications')
        .doc(uid)
        .collection('items')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length)
        .listen(
          (jobCount) => notificationBadgeCount.value = jobCount,
          onError: (_) => notificationBadgeCount.value = 0,
        );
  }

  Future<void> refreshDashboard() async {
    await fetchUserData();
  }

  @override
  void onClose() {
    _jobsSubscription?.cancel();
    _mainFieldsSubscription?.cancel();
    _subFieldsSubscription?.cancel();
    _savedJobsSubscription?.cancel();
    _notifBadgeSub?.cancel();

    searchTextController.dispose();

    super.onClose();
  }
}
// import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:hire_me/app/modules/job_seeker/dashboard/models/job_model.dart';

// class JobSeekerDashboardController extends GetxController {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   final TextEditingController searchTextController = TextEditingController();

//   StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _jobsSubscription;
//   StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
//   _mainFieldsSubscription;
//   StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
//   _subFieldsSubscription;
//   StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
//   _savedJobsSubscription;
//   StreamSubscription<int>? _notifBadgeSub;

//   final userName = 'User'.obs;

//   final allJobs = <JobModel>[].obs;
//   final filteredJobs = <JobModel>[].obs;

//   final mainFields = <MainFieldModel>[].obs;
//   final subFields = <SubFieldModel>[].obs;

//   final savedJobIds = <String>{}.obs;
//   final notificationBadgeCount = 0.obs;

//   final isLoading = true.obs;
//   final isMainFieldsLoading = true.obs;
//   final isSubFieldsLoading = false.obs;

//   final searchQuery = ''.obs;

//   final selectedMainFieldId = 'all'.obs;
//   final selectedSubFieldId = 'all'.obs;

//   final selectedJobType = 'all'.obs;
//   final selectedWorkMode = 'all'.obs;

//   final jobTypes = const ['all', 'FullTime', 'PartTime', 'Freelance'];

//   final workModes = const ['all', 'OnSite', 'Remote', 'Hybrid'];

//   @override
//   void onInit() {
//     super.onInit();
//     fetchUserData();
//     listenToMainFields();
//     listenToOpenJobs();
//     listenToSavedJobs();
//     listenToNotificationBadge();
//   }

//   Future<void> fetchUserData() async {
//     try {
//       final uid = _auth.currentUser?.uid;

//       if (uid == null) return;

//       final userDoc = await _firestore.collection('users').doc(uid).get();

//       if (userDoc.exists) {
//         final data = userDoc.data();

//         userName.value =
//             data?['fullName']?.toString() ??
//             data?['name']?.toString() ??
//             'User';

//         return;
//       }

//       final seekerDoc = await _firestore
//           .collection('jobSeekers')
//           .doc(uid)
//           .get();

//       if (seekerDoc.exists) {
//         final data = seekerDoc.data();

//         userName.value =
//             data?['fullName']?.toString() ??
//             data?['name']?.toString() ??
//             'User';
//       }
//     } catch (_) {
//       userName.value = 'User';
//     }
//   }

//   void listenToMainFields() {
//     isMainFieldsLoading.value = true;

//     _mainFieldsSubscription?.cancel();

//     _mainFieldsSubscription = _firestore
//         .collection('mainFields')
//         .snapshots()
//         .listen(
//           (snapshot) {
//             final fields = snapshot.docs.map((doc) {
//               return MainFieldModel.fromMap(doc.id, doc.data());
//             }).toList();

//             fields.sort((a, b) => a.name.compareTo(b.name));

//             mainFields.value = fields;

//             isMainFieldsLoading.value = false;
//           },
//           onError: (_) {
//             isMainFieldsLoading.value = false;
//             if (_auth.currentUser == null) return;
//             Get.snackbar('Error', 'Failed to load main fields');
//           },
//         );
//   }

//   void listenToSubFields(String mainFieldId) {
//     _subFieldsSubscription?.cancel();

//     selectedSubFieldId.value = 'all';
//     subFields.clear();

//     if (mainFieldId == 'all' || mainFieldId.isEmpty) {
//       isSubFieldsLoading.value = false;
//       applyFilters();
//       return;
//     }

//     isSubFieldsLoading.value = true;

//     _subFieldsSubscription = _firestore
//         .collection('mainFields')
//         .doc(mainFieldId)
//         .collection('subFields')
//         .snapshots()
//         .listen(
//           (snapshot) {
//             final fields = snapshot.docs.map((doc) {
//               return SubFieldModel.fromMap(doc.id, doc.data());
//             }).toList();

//             fields.sort((a, b) => a.name.compareTo(b.name));

//             subFields.value = fields;

//             isSubFieldsLoading.value = false;
//           },
//           onError: (_) {
//             isSubFieldsLoading.value = false;
//             if (_auth.currentUser == null) return;
//             Get.snackbar('Error', 'Failed to load specializations');
//           },
//         );
//   }

//   void listenToOpenJobs() {
//     isLoading.value = true;

//     _jobsSubscription?.cancel();

//     _jobsSubscription = _firestore
//         .collection('jobs')
//         .where('status', isEqualTo: 'Open')
//         .snapshots()
//         .listen(
//           (snapshot) {
//             final jobs = snapshot.docs
//                 .map((doc) => JobModel.fromMap(doc.id, doc.data()))
//                 .where((job) => !job.isDeleted)
//                 .toList();

//             jobs.sort((a, b) {
//               final aDate = a.createdAt?.toDate();
//               final bDate = b.createdAt?.toDate();

//               if (aDate == null && bDate == null) return 0;
//               if (aDate == null) return 1;
//               if (bDate == null) return -1;

//               return bDate.compareTo(aDate);
//             });

//             allJobs.value = jobs;
//             applyFilters();

//             isLoading.value = false;
//           },
//           onError: (_) {
//             isLoading.value = false;
//             if (_auth.currentUser == null) return;
//             Get.snackbar('Error', 'Failed to load jobs');
//           },
//         );
//   }

//   void listenToSavedJobs() {
//     final uid = _auth.currentUser?.uid;

//     if (uid == null) return;

//     _savedJobsSubscription?.cancel();

//     _savedJobsSubscription = _firestore
//         .collection('savedJobs')
//         .where('seekerId', isEqualTo: uid)
//         .snapshots()
//         .listen((snapshot) {
//           final ids = snapshot.docs
//               .map((doc) => doc.data()['jobId']?.toString() ?? '')
//               .where((id) => id.isNotEmpty)
//               .toSet();

//           savedJobIds.clear();
//           savedJobIds.addAll(ids);
//         });
//   }

//   void onSearch(String value) {
//     searchQuery.value = value.trim();
//     applyFilters();
//   }

//   void selectMainField(String fieldId) {
//     selectedMainFieldId.value = fieldId;
//     selectedSubFieldId.value = 'all';

//     listenToSubFields(fieldId);
//     applyFilters();
//   }

//   void selectSubField(String fieldId) {
//     selectedSubFieldId.value = fieldId;
//     applyFilters();
//   }

//   void setJobTypeFilter(String value) {
//     selectedJobType.value = value;
//     applyFilters();
//   }

//   void setWorkModeFilter(String value) {
//     selectedWorkMode.value = value;
//     applyFilters();
//   }

//   void clearFilters() {
//     selectedMainFieldId.value = 'all';
//     selectedSubFieldId.value = 'all';
//     selectedJobType.value = 'all';
//     selectedWorkMode.value = 'all';
//     searchQuery.value = '';

//     subFields.clear();
//     _subFieldsSubscription?.cancel();

//     searchTextController.clear();
//     applyFilters();
//   }

//   void applyFilters() {
//     Iterable<JobModel> results = allJobs;

//     if (selectedMainFieldId.value != 'all') {
//       results = results.where(
//         (job) => job.mainFieldId == selectedMainFieldId.value,
//       );
//     }

//     if (selectedSubFieldId.value != 'all') {
//       results = results.where(
//         (job) => job.subFieldId == selectedSubFieldId.value,
//       );
//     }

//     if (selectedJobType.value != 'all') {
//       results = results.where((job) => job.jobType == selectedJobType.value);
//     }

//     if (selectedWorkMode.value != 'all') {
//       results = results.where((job) => job.workMode == selectedWorkMode.value);
//     }

//     if (searchQuery.value.isNotEmpty) {
//       final query = searchQuery.value.toLowerCase();

//       results = results.where((job) {
//         return job.title.toLowerCase().contains(query) ||
//             job.companyName.toLowerCase().contains(query) ||
//             job.mainFieldName.toLowerCase().contains(query) ||
//             job.subFieldName.toLowerCase().contains(query) ||
//             job.location.toLowerCase().contains(query) ||
//             job.description.toLowerCase().contains(query);
//       });
//     }

//     filteredJobs.value = results.toList();
//   }

//   bool isJobSaved(String jobId) {
//     return savedJobIds.contains(jobId);
//   }

//   Future<void> toggleSaveJob(String jobId) async {
//     try {
//       final uid = _auth.currentUser?.uid;

//       if (uid == null) {
//         Get.snackbar('Login Required', 'Please login to save jobs');
//         return;
//       }

//       final savedJobDocId = '${uid}_$jobId';

//       final savedJobRef = _firestore.collection('savedJobs').doc(savedJobDocId);

//       if (isJobSaved(jobId)) {
//         await savedJobRef.delete();
//       } else {
//         await savedJobRef.set({
//           'seekerId': uid,
//           'jobId': jobId,
//           'savedAt': FieldValue.serverTimestamp(),
//         });
//       }
//     } catch (_) {
//       Get.snackbar('Error', 'Failed to update saved job');
//     }
//   }

//   void listenToNotificationBadge() {
//     final uid = _auth.currentUser?.uid;

//     if (uid == null) return;

//     _notifBadgeSub = _firestore
//         .collection('notifications')
//         .doc(uid)
//         .collection('items')
//         .where('isRead', isEqualTo: false)
//         .snapshots()
//         .map((snap) => snap.docs.length)
//         .listen(
//           (jobCount) => notificationBadgeCount.value = jobCount,
//           onError: (_) => notificationBadgeCount.value = 0,
//         );
//   }

//   Future<void> refreshDashboard() async {
//     await fetchUserData();
//   }

//   @override
//   void onClose() {
//     _jobsSubscription?.cancel();
//     _mainFieldsSubscription?.cancel();
//     _subFieldsSubscription?.cancel();
//     _savedJobsSubscription?.cancel();
//     _notifBadgeSub?.cancel();

//     searchTextController.dispose();

//     super.onClose();
//   }
// }
