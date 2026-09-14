import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hire_me/app/modules/company/application_list/views/widgets/app_confirm_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../application_review/model/application_review_model.dart';
import '../../application_review/model/job_with_application.dart';
import '../../company_main_wrapper/controllers/company_main_wrapper_controller.dart';
import '../../post_job/controllers/company_post_job_controller.dart';
import '../model/company_job_model.dart';

class ApplicationListController extends GetxController {
  final jobs = <JobWithApplicants>[].obs;
  final companyJobs = <CompanyJobModel>[].obs;

  final isLoading = true.obs;
  final isJobsLoading = true.obs;
  final isDeleting = false.obs;

  final jobsCount = 0.obs;
  final applicantsCount = 0.obs;

  final activeTab = 'jobs'.obs;
  final selectedStatus = 'Pending'.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  final _appsCountByJob = <String, int>{};

  final _latestSeekerProfiles = <String, Map<String, dynamic>>{};
  final _seekerProfileSubscriptions =
      <String, StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>>{};

  List<_CompanyApplicationData> _currentApplications = [];

  StreamSubscription? _appSub;
  StreamSubscription? _jobsSub;
  StreamSubscription? _jobsCountSub;
  StreamSubscription? _appsPerJobSub;

  List<JobWithApplicants> get filteredJobs {
    return jobs
        .map((job) {
          final filtered = job.applicants.where((applicant) {
            final status = applicant.status.toLowerCase();

            if (selectedStatus.value == 'Pending') {
              return status != 'accepted' && status != 'rejected';
            }

            return status == selectedStatus.value.toLowerCase();
          }).toList();

          return JobWithApplicants(
            jobId: job.jobId,
            jobTitle: job.jobTitle,
            applicants: filtered,
          );
        })
        .where((job) => job.applicants.isNotEmpty)
        .toList();
  }

  @override
  void onInit() {
    super.onInit();

    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      isLoading.value = false;
      isJobsLoading.value = false;
      return;
    }

    _listenToApplications(uid);
    _listenToCompanyJobs(uid);
    _listenToJobsCount(uid);
    _listenToAppsPerJobCount(uid);
  }

  void switchTab(String tab) {
    activeTab.value = tab;
  }

  void showJobsTab() {
    switchTab('jobs');
  }

  void showApplicationsTab() {
    switchTab('applications');
  }

  void _listenToApplications(String companyId) {
    _appSub?.cancel();

    _appSub = _firestore
        .collection('applications')
        .where('companyId', isEqualTo: companyId)
        .snapshots()
        .listen(
          (snapshot) {
            if (isClosed) return;

            _currentApplications = snapshot.docs
                .where((doc) {
                  final data = doc.data();

                  return data['isDeleted'] != true &&
                      data['jobDeleted'] != true;
                })
                .map((doc) {
                  return _CompanyApplicationData(id: doc.id, data: doc.data());
                })
                .toList();

            _syncSeekerProfileListeners();
            _rebuildApplicationsList();

            isLoading.value = false;
          },
          onError: (e) {
            debugPrint('ApplicationList stream error: $e');
            if (!isClosed) isLoading.value = false;
          },
        );
  }

  void _syncSeekerProfileListeners() {
    final neededSeekerIds = _currentApplications
        .map((app) => _extractSeekerId(app.data))
        .where((id) => id.isNotEmpty)
        .toSet();

    final oldIds = _seekerProfileSubscriptions.keys.toList();

    for (final seekerId in oldIds) {
      if (!neededSeekerIds.contains(seekerId)) {
        _seekerProfileSubscriptions[seekerId]?.cancel();
        _seekerProfileSubscriptions.remove(seekerId);
        _latestSeekerProfiles.remove(seekerId);
      }
    }

    for (final seekerId in neededSeekerIds) {
      if (_seekerProfileSubscriptions.containsKey(seekerId)) continue;

      _seekerProfileSubscriptions[seekerId] = _firestore
          .collection('jobSeekers')
          .doc(seekerId)
          .snapshots()
          .listen(
            (doc) {
              if (doc.exists && doc.data() != null) {
                _latestSeekerProfiles[seekerId] = doc.data()!;
              } else {
                _latestSeekerProfiles[seekerId] = {};
              }

              _rebuildApplicationsList();
            },
            onError: (e) {
              debugPrint('Seeker profile stream error: $e');
              _latestSeekerProfiles[seekerId] = {};
              _rebuildApplicationsList();
            },
          );
    }
  }

  void _rebuildApplicationsList() {
    final grouped = <String, List<ApplicationReviewModel>>{};
    final jobTitles = <String, String>{};

    for (final app in _currentApplications) {
      final data = app.data;

      final jobId = _firstNotEmpty([data['jobId']]);

      final jobTitle = _firstNotEmpty([
        data['jobTitle'],
        data['title'],
      ], fallback: 'Unknown Job');

      if (jobId.isEmpty) continue;

      final seekerId = _extractSeekerId(data);
      final seekerData = _latestSeekerProfiles[seekerId] ?? {};

      jobTitles[jobId] = jobTitle;

      grouped
          .putIfAbsent(jobId, () => [])
          .add(
            ApplicationReviewModel(
              id: app.id,
              jobSeekerId: seekerId,
              name: _firstNotEmpty([
                seekerData['name'],
                seekerData['fullName'],
                data['seekerName'],
                data['applicantName'],
                data['name'],
              ], fallback: 'Unknown'),
              jobTitle: jobTitle,
              location: _firstNotEmpty([
                seekerData['location'],
                data['applicantLocation'],
                data['location'],
              ], fallback: 'Location not added'),
              email: _firstNotEmpty([
                seekerData['email'],
                data['email'],
                data['applicantEmail'],
              ], fallback: 'Email not added'),
              skills: _dataToText(seekerData['skills'] ?? data['skills'] ?? ''),
              experience: _dataToText(
                seekerData['experience'] ?? data['experience'] ?? '',
              ),
              education: _dataToText(
                seekerData['education'] ?? data['education'] ?? '',
              ),
              cvUrl: _firstNotEmpty([data['cvUrl']]),
              avatarUrl: _firstNotEmpty([
                seekerData['profileImage'],
                data['avatarUrl'],
                data['applicantImage'],
                data['profileImage'],
                data['imageUrl'],
              ]),
              status: _firstNotEmpty([data['status']], fallback: 'Pending'),
              appliedAt: _firstNotEmpty([data['appliedAt']]),
              updatedAt: _firstNotEmpty([data['updatedAt']]),
              applicantFcmToken: _firstNotEmpty([data['applicantFcmToken']]),
              jobId: jobId,
            ),
          );
    }

    final result = grouped.entries.map((entry) {
      return JobWithApplicants(
        jobId: entry.key,
        jobTitle: jobTitles[entry.key] ?? 'Unknown Job',
        applicants: entry.value,
      );
    }).toList();

    jobs.value = result;
  }

  String _extractSeekerId(Map<String, dynamic> data) {
    return _firstNotEmpty([
      data['seekerId'],
      data['jobSeekerId'],
      data['applicantId'],
      data['userId'],
    ]);
  }

  String _firstNotEmpty(List<dynamic> values, {String fallback = ''}) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';

      if (text.isNotEmpty) {
        return text;
      }
    }

    return fallback;
  }

  String _dataToText(dynamic value) {
    if (value == null) return '';

    if (value is String) {
      return value.trim();
    }

    if (value is List) {
      return value
          .map((item) {
            if (item is Map) {
              return item.values
                  .where((v) => v != null && v.toString().trim().isNotEmpty)
                  .map((v) => v.toString())
                  .join(' - ');
            }

            return item.toString();
          })
          .where((text) => text.trim().isNotEmpty)
          .join(', ');
    }

    if (value is Map) {
      return value.values
          .where((v) => v != null && v.toString().trim().isNotEmpty)
          .map((v) => v.toString())
          .join(', ');
    }

    return value.toString();
  }

  void _listenToCompanyJobs(String companyId) {
    _jobsSub?.cancel();

    _jobsSub = _firestore
        .collection('jobs')
        .where('companyId', isEqualTo: companyId)
        .snapshots()
        .listen(
          (snapshot) {
            if (isClosed) return;

            final loaded = snapshot.docs
                .map((doc) {
                  final model = CompanyJobModel.fromMap(doc.id, doc.data());

                  return CompanyJobModel(
                    id: model.id,
                    title: model.title,
                    location: model.location,
                    salary: model.salary,
                    jobType: model.jobType,
                    workMode: model.workMode,
                    status: model.status,
                    createdAt: model.createdAt,
                    mainFieldId: model.mainFieldId,
                    mainFieldName: model.mainFieldName,
                    applicantCount: _appsCountByJob[doc.id] ?? 0,
                    minSalary: model.minSalary,
                    maxSalary: model.maxSalary,
                    description: model.description,
                    requirements: model.requirements,
                    isDeleted: model.isDeleted,
                    logoUrl: model.logoUrl,
                    mainFieldIconUrl: model.mainFieldIconUrl,
                    subFieldIconUrl: model.subFieldIconUrl,
                  );
                })
                .where((job) => !job.isDeleted)
                .toList();

            loaded.sort((a, b) {
              final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
              final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;

              return bTime.compareTo(aTime);
            });

            companyJobs.value = loaded;
            isJobsLoading.value = false;
          },
          onError: (e) {
            debugPrint('CompanyJobs stream error: $e');
            if (!isClosed) isJobsLoading.value = false;
          },
        );
  }

  void _listenToJobsCount(String companyId) {
    _jobsCountSub?.cancel();

    _jobsCountSub = _firestore
        .collection('jobs')
        .where('companyId', isEqualTo: companyId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.where((doc) {
            final data = doc.data();
            return data['isDeleted'] != true;
          }).length;
        })
        .listen((jobCount) {
          jobsCount.value = jobCount;
        });
  }

  void _listenToAppsPerJobCount(String companyId) {
    _appsPerJobSub?.cancel();

    _appsPerJobSub = _firestore
        .collection('applications')
        .where('companyId', isEqualTo: companyId)
        .snapshots()
        .listen((snapshot) {
          if (isClosed) return;

          final activeDocs = snapshot.docs.where((doc) {
            final data = doc.data();

            return data['isDeleted'] != true && data['jobDeleted'] != true;
          }).toList();

          _appsCountByJob.clear();

          for (final doc in activeDocs) {
            final jobId = doc.data()['jobId']?.toString() ?? '';

            if (jobId.isEmpty) continue;

            _appsCountByJob[jobId] = (_appsCountByJob[jobId] ?? 0) + 1;
          }

          applicantsCount.value = activeDocs.length;

          if (companyJobs.isNotEmpty) {
            companyJobs.value = companyJobs.map((job) {
              return CompanyJobModel(
                id: job.id,
                title: job.title,
                location: job.location,
                salary: job.salary,
                jobType: job.jobType,
                workMode: job.workMode,
                status: job.status,
                createdAt: job.createdAt,
                mainFieldId: job.mainFieldId,
                mainFieldName: job.mainFieldName,
                applicantCount: _appsCountByJob[job.id] ?? 0,
                minSalary: job.minSalary,
                maxSalary: job.maxSalary,
                description: job.description,
                requirements: job.requirements,
                isDeleted: job.isDeleted,
                logoUrl: job.logoUrl,
                mainFieldIconUrl: job.mainFieldIconUrl,
                subFieldIconUrl: job.subFieldIconUrl,
              );
            }).toList();
          }
        });
  }

  void editJob(CompanyJobModel job) {
    final postJobController = Get.isRegistered<CompanyPostJobController>()
        ? Get.find<CompanyPostJobController>()
        : Get.put(CompanyPostJobController());

    postJobController.loadJobForEdit(job);

    if (Get.isRegistered<CompanyMainWrapperController>()) {
      Get.find<CompanyMainWrapperController>().goToPostJob();
    }
  }

  Future<void> confirmCloseJob(CompanyJobModel job) async {
    final confirmed = await showAppConfirmDialog(
      icon: Icons.lock_outline_rounded,
      title: 'Close Job',
      message:
          'This job will be closed and hidden from job seekers, but applications will remain saved.',
      confirmText: 'Close',
      confirmColor: const Color(0xFFEF4444),
    );

    if (confirmed == true) {
      await closeJob(job.id);
    }
  }

  Future<void> closeJob(String jobId) async {
    try {
      await _firestore.collection('jobs').doc(jobId).update({
        'status': 'Closed',
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Success',
        'Job closed successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to close job',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> confirmDeleteJob(CompanyJobModel job) async {
    final confirmed = await showAppConfirmDialog(
      icon: Icons.delete_outline_rounded,
      title: 'Delete Job',
      message:
          'This will permanently delete the job, all applications, related chats, and notifications. This action cannot be undone.',
      confirmText: 'Delete',
      confirmColor: const Color(0xFFEF4444),
    );

    if (confirmed == true) {
      await deleteJob(job.id);
    }
  }

  Future<void> deleteJob(String jobId) async {
    try {
      isDeleting.value = true;

      final appsSnapshot = await _firestore
          .collection('applications')
          .where('jobId', isEqualTo: jobId)
          .get();

      final seekerIds = <String>{};
      final appIds = <String>[];
      final cvUrls = <String>[];
      String? companyId;

      for (final doc in appsSnapshot.docs) {
        final data = doc.data();

        final seekerId = _firstNotEmpty([
          data['seekerId'],
          data['jobSeekerId'],
          data['applicantId'],
          data['userId'],
        ]);

        if (seekerId.isNotEmpty) seekerIds.add(seekerId);

        appIds.add(doc.id);
        companyId ??= data['companyId']?.toString();

        final cvUrl = data['cvUrl']?.toString();

        if (cvUrl != null && cvUrl.isNotEmpty) cvUrls.add(cvUrl);
      }

      final savedJobsSnapshot = await _firestore
          .collection('savedJobs')
          .where('jobId', isEqualTo: jobId)
          .get();

      if (cvUrls.isNotEmpty) {
        try {
          final cvPaths = cvUrls.map((url) {
            return Uri.parse(url).pathSegments.last;
          }).toList();

          await _supabase.storage.from('cv').remove(cvPaths);
        } catch (_) {}
      }

      final deletes = <void Function(WriteBatch)>[
        for (final appId in appIds)
          (batch) =>
              batch.delete(_firestore.collection('applications').doc(appId)),
        for (final doc in savedJobsSnapshot.docs)
          (batch) =>
              batch.delete(_firestore.collection('savedJobs').doc(doc.id)),
        (batch) => batch.delete(_firestore.collection('jobs').doc(jobId)),
      ];

      for (var i = 0; i < deletes.length; i += 500) {
        final batch = _firestore.batch();

        final end = (i + 500).clamp(0, deletes.length);

        for (var j = i; j < end; j++) {
          deletes[j](batch);
        }

        await batch.commit();
      }

      final db = FirebaseDatabase.instance.ref();

      if (companyId != null && companyId.isNotEmpty) {
        for (final seekerId in seekerIds) {
          final chatId = '${companyId}_$seekerId';
          final chatSnapshot = await db.child('chats/$chatId').get();

          if (chatSnapshot.exists) {
            await db.child('chats/$chatId/messages').remove();
            await db.child('chats/$chatId').remove();
          }
        }
      }

      final allUserIds = <String>{...seekerIds};

      if (companyId != null && companyId.isNotEmpty) {
        allUserIds.add(companyId);
      }

      for (final userId in allUserIds) {
        for (var i = 0; i < appIds.length; i += 10) {
          final chunk = appIds.skip(i).take(10).toList();

          if (chunk.isEmpty) continue;

          final notifSnapshot = await _firestore
              .collection('notifications')
              .doc(userId)
              .collection('items')
              .where('applicationId', whereIn: chunk)
              .get();

          if (notifSnapshot.docs.isEmpty) continue;

          final notifBatch = _firestore.batch();

          for (final doc in notifSnapshot.docs) {
            notifBatch.delete(doc.reference);
          }

          await notifBatch.commit();
        }
      }

      Get.snackbar(
        'Success',
        'Job deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete job: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isDeleting.value = false;
    }
  }

  void _cancelSeekerProfileListeners() {
    for (final sub in _seekerProfileSubscriptions.values) {
      sub.cancel();
    }

    _seekerProfileSubscriptions.clear();
    _latestSeekerProfiles.clear();
  }

  @override
  void onClose() {
    _appSub?.cancel();
    _jobsSub?.cancel();
    _jobsCountSub?.cancel();
    _appsPerJobSub?.cancel();
    _cancelSeekerProfileListeners();
    super.onClose();
  }
}

class _CompanyApplicationData {
  final String id;
  final Map<String, dynamic> data;

  _CompanyApplicationData({required this.id, required this.data});
}
