import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../application_list/model/company_job_model.dart';
import '../../company_main_wrapper/controllers/company_main_wrapper_controller.dart';

class CompanyPostJobController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // Form controllers
  final titleController = TextEditingController();
  final locationController = TextEditingController();
  final minSalaryController = TextEditingController();
  final maxSalaryController = TextEditingController();
  final descriptionController = TextEditingController();
  final requirementsController = TextEditingController();

  // Loading states
  final isLoading = false.obs;
  final isUploadingLogo = false.obs;
  final isMainFieldsLoading = false.obs;
  final isSubFieldsLoading = false.obs;

  // Create/Edit state
  final isEditMode = false.obs;
  final editingJobId = ''.obs;

  // Company data
  final companyLogoUrl = ''.obs;
  String companyName = '';

  // Fields
  final mainFields = <CompanyMainField>[].obs;
  final subFields = <CompanySubField>[].obs;

  // Selected main field
  final selectedMainFieldId = ''.obs;
  final selectedMainFieldName = ''.obs;
  final selectedMainFieldIconUrl = ''.obs;

  // Selected sub field
  final selectedSubFieldId = ''.obs;
  final selectedSubFieldName = ''.obs;
  final selectedSubFieldIconUrl = ''.obs;

  // Job options
  final selectedJobType = 'FullTime'.obs;
  final selectedWorkMode = 'Remote'.obs;

  // Services
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  // Subscriptions
  StreamSubscription<fb_auth.User?>? _authSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _mainFieldsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subFieldsSub;

  static const String _logoBucket = 'logos';
  static const int _maxLogoSizeInBytes = 5 * 1024 * 1024;

  @override
  void onInit() {
    super.onInit();

    _authSub = _auth.authStateChanges().listen((user) {
      _handleAuthStateChanged(user);
    });
  }

  Future<void> _handleAuthStateChanged(fb_auth.User? user) async {
    if (isClosed) return;

    if (user == null) {
      await _cancelFieldSubscriptions();

      if (isClosed) return;

      _resetRemoteData();
      return;
    }

    await loadCompanyData();

    if (isClosed || _auth.currentUser == null) return;

    await fetchMainFields();
  }

  Future<void> _cancelFieldSubscriptions() async {
    final mainFieldsSubscription = _mainFieldsSub;
    final subFieldsSubscription = _subFieldsSub;

    _mainFieldsSub = null;
    _subFieldsSub = null;

    await mainFieldsSubscription?.cancel();
    await subFieldsSubscription?.cancel();
  }

  void _resetRemoteData() {
    mainFields.clear();
    subFields.clear();

    companyName = '';
    companyLogoUrl.value = '';

    _clearMainFieldSelection();
    _clearSubFieldSelection();

    isMainFieldsLoading.value = false;
    isSubFieldsLoading.value = false;
  }

  Future<void> loadCompanyData() async {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      companyName = '';
      companyLogoUrl.value = '';
      return;
    }

    try {
      final companyDoc = await _firestore
          .collection('companies')
          .doc(uid)
          .get();

      if (isClosed || _auth.currentUser?.uid != uid) return;

      if (companyDoc.exists && companyDoc.data() != null) {
        final data = companyDoc.data()!;

        companyName = _readFirstNonEmptyString(data, const [
          'companyName',
          'name',
          'fullName',
        ], fallback: _auth.currentUser?.displayName ?? 'Company');

        companyLogoUrl.value = _readFirstNonEmptyString(data, const [
          'logoUrl',
          'companyLogoUrl',
          'profileImageUrl',
        ]);

        return;
      }

      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (isClosed || _auth.currentUser?.uid != uid) return;

      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;

        companyName = _readFirstNonEmptyString(data, const [
          'companyName',
          'name',
          'fullName',
        ], fallback: _auth.currentUser?.displayName ?? 'Company');

        companyLogoUrl.value = _readFirstNonEmptyString(data, const [
          'logoUrl',
          'companyLogoUrl',
          'profileImageUrl',
        ]);

        return;
      }

      companyName = _auth.currentUser?.displayName ?? 'Company';
      companyLogoUrl.value = '';
    } on FirebaseException catch (e, stackTrace) {
      debugPrint('Company data Firebase error: ${e.code}');
      debugPrint('Company data message: ${e.message}');
      debugPrintStack(stackTrace: stackTrace);

      companyName = _auth.currentUser?.displayName ?? 'Company';
    } catch (e, stackTrace) {
      debugPrint('Error loading company data: $e');
      debugPrintStack(stackTrace: stackTrace);

      companyName = _auth.currentUser?.displayName ?? 'Company';
    }
  }

  String _readFirstNonEmptyString(
    Map<String, dynamic> data,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = data[key]?.toString().trim() ?? '';

      if (value.isNotEmpty) {
        return value;
      }
    }

    return fallback;
  }

  Future<void> fetchMainFields() async {
    if (_auth.currentUser == null || isClosed) {
      isMainFieldsLoading.value = false;
      return;
    }

    isMainFieldsLoading.value = true;

    await _mainFieldsSub?.cancel();
    _mainFieldsSub = null;

    if (_auth.currentUser == null || isClosed) {
      isMainFieldsLoading.value = false;
      return;
    }

    _mainFieldsSub = _firestore
        .collection('mainFields')
        .snapshots()
        .listen(
          (snapshot) {
            if (isClosed || _auth.currentUser == null) return;

            final fields = snapshot.docs.map((doc) {
              return CompanyMainField.fromMap(id: doc.id, data: doc.data());
            }).toList();

            fields.sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
            );

            mainFields.assignAll(fields);

            final currentMainFieldId = selectedMainFieldId.value;

            if (currentMainFieldId.isNotEmpty) {
              CompanyMainField? currentField;

              for (final field in fields) {
                if (field.id == currentMainFieldId) {
                  currentField = field;
                  break;
                }
              }

              if (currentField != null) {
                selectedMainFieldName.value = currentField.name;
                selectedMainFieldIconUrl.value = currentField.iconUrl;
              } else {
                _clearMainFieldSelection();
                _clearSubFieldSelection();
                subFields.clear();
              }
            }

            if (!isEditMode.value &&
                fields.isNotEmpty &&
                selectedMainFieldId.value.isEmpty) {
              selectMainField(fields.first);
            }

            isMainFieldsLoading.value = false;
          },
          onError: (Object error, StackTrace stackTrace) {
            if (isClosed) return;

            isMainFieldsLoading.value = false;

            debugPrint('Main fields stream error: $error');
            debugPrintStack(stackTrace: stackTrace);

            if (_auth.currentUser == null) return;

            if (error is FirebaseException) {
              debugPrint('Firebase code: ${error.code}');
              debugPrint('Firebase message: ${error.message}');

              if (error.code == 'permission-denied') {
                _showError('You do not have permission to load categories');
                return;
              }

              if (error.code == 'unavailable') {
                _showError('Please check your internet connection');
                return;
              }
            }

            _showError('Failed to load categories');
          },
          cancelOnError: false,
        );
  }

  Future<void> fetchSubFields(
    String mainFieldId, {
    String initialSubFieldId = '',
  }) async {
    if (_auth.currentUser == null || isClosed) {
      isSubFieldsLoading.value = false;
      return;
    }

    await _subFieldsSub?.cancel();
    _subFieldsSub = null;

    if (mainFieldId.trim().isEmpty) {
      subFields.clear();
      _clearSubFieldSelection();
      isSubFieldsLoading.value = false;
      return;
    }

    isSubFieldsLoading.value = true;

    _subFieldsSub = _firestore
        .collection('mainFields')
        .doc(mainFieldId)
        .collection('subFields')
        .snapshots()
        .listen(
          (snapshot) {
            if (isClosed || _auth.currentUser == null) return;

            if (selectedMainFieldId.value != mainFieldId) return;

            final fields = snapshot.docs.map((doc) {
              return CompanySubField.fromMap(id: doc.id, data: doc.data());
            }).toList();

            fields.sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
            );

            subFields.assignAll(fields);

            if (fields.isEmpty) {
              _clearSubFieldSelection();
              isSubFieldsLoading.value = false;
              return;
            }

            final preferredSubFieldId = initialSubFieldId.isNotEmpty
                ? initialSubFieldId
                : selectedSubFieldId.value;

            CompanySubField? preferredField;

            if (preferredSubFieldId.isNotEmpty) {
              for (final field in fields) {
                if (field.id == preferredSubFieldId) {
                  preferredField = field;
                  break;
                }
              }
            }

            selectSubField(preferredField ?? fields.first);

            isSubFieldsLoading.value = false;
          },
          onError: (Object error, StackTrace stackTrace) {
            if (isClosed) return;

            isSubFieldsLoading.value = false;

            debugPrint('Sub fields stream error: $error');
            debugPrintStack(stackTrace: stackTrace);

            if (_auth.currentUser == null) return;

            if (error is FirebaseException) {
              debugPrint('Firebase code: ${error.code}');
              debugPrint('Firebase message: ${error.message}');

              if (error.code == 'permission-denied') {
                _showError(
                  'You do not have permission to load specializations',
                );
                return;
              }

              if (error.code == 'unavailable') {
                _showError('Please check your internet connection');
                return;
              }
            }

            _showError('Failed to load specializations');
          },
          cancelOnError: false,
        );
  }

  void loadJobForEdit(CompanyJobModel job) {
    isEditMode.value = true;
    editingJobId.value = job.id;

    titleController.text = job.title;
    locationController.text = job.location;
    minSalaryController.text = job.minSalary?.toString() ?? '';
    maxSalaryController.text = job.maxSalary?.toString() ?? '';
    descriptionController.text = job.description;
    requirementsController.text = job.requirements;

    selectedMainFieldId.value = job.mainFieldId;
    selectedMainFieldName.value = job.mainFieldName;

    selectedJobType.value = job.jobType.isEmpty ? 'FullTime' : job.jobType;
    selectedWorkMode.value = job.workMode.isEmpty ? 'Remote' : job.workMode;

    final dynamic editJob = job;

    selectedMainFieldIconUrl.value = _safeDynamicString(
      () => editJob.mainFieldIconUrl,
    );

    selectedSubFieldId.value = _safeDynamicString(() => editJob.subFieldId);

    selectedSubFieldName.value = _safeDynamicString(() => editJob.subFieldName);

    selectedSubFieldIconUrl.value = _safeDynamicString(
      () => editJob.subFieldIconUrl,
    );

    fetchSubFields(
      job.mainFieldId,
      initialSubFieldId: selectedSubFieldId.value,
    );
  }

  String _safeDynamicString(String Function() read) {
    try {
      return read().trim();
    } catch (_) {
      return '';
    }
  }

  void resetCreateMode() {
    isEditMode.value = false;
    editingJobId.value = '';
    _clearForm();
  }

  void selectMainField(CompanyMainField field) {
    selectedMainFieldId.value = field.id;
    selectedMainFieldName.value = field.name;
    selectedMainFieldIconUrl.value = field.iconUrl;

    _clearSubFieldSelection();
    subFields.clear();

    fetchSubFields(field.id);
  }

  void selectSubField(CompanySubField field) {
    selectedSubFieldId.value = field.id;
    selectedSubFieldName.value = field.name;
    selectedSubFieldIconUrl.value = field.iconUrl;
  }

  void selectJobType(String value) {
    selectedJobType.value = value;
  }

  void selectWorkMode(String value) {
    selectedWorkMode.value = value;
  }

  void _clearMainFieldSelection() {
    selectedMainFieldId.value = '';
    selectedMainFieldName.value = '';
    selectedMainFieldIconUrl.value = '';
  }

  void _clearSubFieldSelection() {
    selectedSubFieldId.value = '';
    selectedSubFieldName.value = '';
    selectedSubFieldIconUrl.value = '';
  }

  Future<void> pickAndUploadCompanyLogo() async {
    if (isUploadingLogo.value) return;

    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      _showError('Please login first');
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final pickedFile = result.files.single;

      if (pickedFile.path == null || pickedFile.path!.trim().isEmpty) {
        _showError('Invalid image file');
        return;
      }

      if (pickedFile.size > _maxLogoSizeInBytes) {
        _showError('The image must be smaller than 5 MB');
        return;
      }

      isUploadingLogo.value = true;

      final file = File(pickedFile.path!);
      final extension = (pickedFile.extension ?? 'jpg').toLowerCase();

      final fileName =
          'companies/$uid/${DateTime.now().millisecondsSinceEpoch}.$extension';

      await _supabase.storage
          .from(_logoBucket)
          .upload(
            fileName,
            file,
            fileOptions: const FileOptions(upsert: true, cacheControl: '3600'),
          );

      final imageUrl = _supabase.storage
          .from(_logoBucket)
          .getPublicUrl(fileName);

      final batch = _firestore.batch();

      final companyReference = _firestore.collection('companies').doc(uid);
      final userReference = _firestore.collection('users').doc(uid);

      final logoData = <String, dynamic>{
        'logoUrl': imageUrl,
        'companyLogoUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      batch.set(companyReference, logoData, SetOptions(merge: true));

      batch.set(userReference, logoData, SetOptions(merge: true));

      await batch.commit();

      if (isClosed || _auth.currentUser?.uid != uid) return;

      companyLogoUrl.value = imageUrl;

      _showSuccess('Company logo uploaded successfully');
    } on FirebaseException catch (e, stackTrace) {
      debugPrint('Logo Firestore error: ${e.code}');
      debugPrint('Logo Firestore message: ${e.message}');
      debugPrintStack(stackTrace: stackTrace);

      _showError('Failed to save company logo');
    } on StorageException catch (e, stackTrace) {
      debugPrint('Supabase logo error: ${e.message}');
      debugPrintStack(stackTrace: stackTrace);

      _showError('Failed to upload company logo');
    } catch (e, stackTrace) {
      debugPrint('Logo upload error: $e');
      debugPrintStack(stackTrace: stackTrace);

      _showError('Failed to upload company logo');
    } finally {
      if (!isClosed) {
        isUploadingLogo.value = false;
      }
    }
  }

  Future<void> submitJob() async {
    if (isLoading.value) return;

    if (isEditMode.value) {
      await updateJob();
    } else {
      await publishJob();
    }
  }

  _SalaryRange? _validateJobForm() {
    if (!(formKey.currentState?.validate() ?? false)) {
      return null;
    }

    if (selectedMainFieldId.value.isEmpty ||
        selectedMainFieldName.value.isEmpty) {
      _showError('Please select category');
      return null;
    }

    if (selectedSubFieldId.value.isEmpty ||
        selectedSubFieldName.value.isEmpty) {
      _showError('Please select specialization');
      return null;
    }

    final minSalary = num.tryParse(minSalaryController.text.trim());
    final maxSalary = num.tryParse(maxSalaryController.text.trim());

    if (minSalary == null || maxSalary == null) {
      _showError('Please enter valid salary');
      return null;
    }

    if (minSalary < 0 || maxSalary < 0) {
      _showError('Salary cannot be negative');
      return null;
    }

    if (minSalary > maxSalary) {
      _showError('Min salary must be less than max salary');
      return null;
    }

    return _SalaryRange(min: minSalary, max: maxSalary);
  }

  Map<String, dynamic> _buildJobData(_SalaryRange salaryRange) {
    final safeCompanyName = companyName.trim().isEmpty
        ? 'Company'
        : companyName.trim();

    return {
      'companyName': safeCompanyName,
      'companyLogoUrl': companyLogoUrl.value.trim(),
      'logoUrl': companyLogoUrl.value.trim(),
      'title': titleController.text.trim(),
      'mainFieldId': selectedMainFieldId.value,
      'mainFieldName': selectedMainFieldName.value,
      'mainFieldIconUrl': selectedMainFieldIconUrl.value,
      'category': selectedMainFieldName.value,
      'subFieldId': selectedSubFieldId.value,
      'subFieldName': selectedSubFieldName.value,
      'subFieldIconUrl': selectedSubFieldIconUrl.value,
      'specialization': selectedSubFieldName.value,
      'jobType': selectedJobType.value,
      'workMode': selectedWorkMode.value,
      'location': locationController.text.trim(),
      'minSalary': salaryRange.min,
      'maxSalary': salaryRange.max,
      'salary':
          '\$${_formatNumber(salaryRange.min)}-${_formatNumber(salaryRange.max)}',
      'description': descriptionController.text.trim(),
      'requirements': requirementsController.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  String _formatNumber(num value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toString();
  }

  Future<void> publishJob() async {
    if (isLoading.value) return;

    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      _showError('Please login first');
      return;
    }

    final salaryRange = _validateJobForm();

    if (salaryRange == null) return;

    isLoading.value = true;

    try {
      await loadCompanyData();

      if (_auth.currentUser?.uid != uid) {
        _showError('Your session has expired');
        return;
      }

      final jobData = _buildJobData(salaryRange);

      jobData.addAll({
        'companyId': uid,
        'status': 'Open',
        'isActive': true,
        'isDeleted': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('jobs').add(jobData);

      if (isClosed) return;

      _clearForm();
      _showSuccess('Job published successfully');

      if (Get.isRegistered<CompanyMainWrapperController>()) {
        Get.find<CompanyMainWrapperController>().goToDashboard();
      }
    } on FirebaseException catch (e, stackTrace) {
      debugPrint('Publish job Firebase error: ${e.code}');
      debugPrint('Publish job message: ${e.message}');
      debugPrintStack(stackTrace: stackTrace);

      if (e.code == 'permission-denied') {
        _showError('You do not have permission to publish jobs');
      } else {
        _showError('Failed to publish job');
      }
    } catch (e, stackTrace) {
      debugPrint('Publish job error: $e');
      debugPrintStack(stackTrace: stackTrace);

      _showError('Failed to publish job');
    } finally {
      if (!isClosed) {
        isLoading.value = false;
      }
    }
  }

  Future<void> updateJob() async {
    if (isLoading.value) return;

    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      _showError('Please login first');
      return;
    }

    if (editingJobId.value.trim().isEmpty) {
      _showError('Job data not found');
      return;
    }

    final salaryRange = _validateJobForm();

    if (salaryRange == null) return;

    isLoading.value = true;

    try {
      await loadCompanyData();

      if (_auth.currentUser?.uid != uid) {
        _showError('Your session has expired');
        return;
      }

      final jobData = _buildJobData(salaryRange);
      jobData['companyId'] = uid;

      await _firestore
          .collection('jobs')
          .doc(editingJobId.value)
          .update(jobData);

      if (isClosed) return;

      isEditMode.value = false;
      editingJobId.value = '';

      _clearForm();
      _showSuccess('Job updated successfully');

      if (Get.isRegistered<CompanyMainWrapperController>()) {
        Get.find<CompanyMainWrapperController>().changePage(0);
      }
    } on FirebaseException catch (e, stackTrace) {
      debugPrint('Update job Firebase error: ${e.code}');
      debugPrint('Update job message: ${e.message}');
      debugPrintStack(stackTrace: stackTrace);

      if (e.code == 'permission-denied') {
        _showError('You do not have permission to update this job');
      } else if (e.code == 'not-found') {
        _showError('The selected job no longer exists');
      } else {
        _showError('Failed to update job');
      }
    } catch (e, stackTrace) {
      debugPrint('Update job error: $e');
      debugPrintStack(stackTrace: stackTrace);

      _showError('Failed to update job');
    } finally {
      if (!isClosed) {
        isLoading.value = false;
      }
    }
  }

  void _clearForm() {
    formKey.currentState?.reset();

    titleController.clear();
    locationController.clear();
    minSalaryController.clear();
    maxSalaryController.clear();
    descriptionController.clear();
    requirementsController.clear();

    selectedJobType.value = 'FullTime';
    selectedWorkMode.value = 'Remote';

    _clearSubFieldSelection();
    subFields.clear();

    if (mainFields.isNotEmpty) {
      selectMainField(mainFields.first);
    } else {
      _clearMainFieldSelection();
    }
  }

  void _showSuccess(String message) {
    if (isClosed) return;

    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF22C55E),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  void _showError(String message) {
    if (isClosed) return;

    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFEF4444),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _mainFieldsSub?.cancel();
    _subFieldsSub?.cancel();

    _authSub = null;
    _mainFieldsSub = null;
    _subFieldsSub = null;

    titleController.dispose();
    locationController.dispose();
    minSalaryController.dispose();
    maxSalaryController.dispose();
    descriptionController.dispose();
    requirementsController.dispose();

    super.onClose();
  }
}

class CompanyMainField {
  final String id;
  final String name;
  final String iconUrl;

  const CompanyMainField({
    required this.id,
    required this.name,
    required this.iconUrl,
  });

  factory CompanyMainField.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final name = data['name']?.toString().trim();
    final title = data['title']?.toString().trim();
    final iconUrl = data['iconUrl']?.toString().trim();
    final imageUrl = data['imageUrl']?.toString().trim();

    return CompanyMainField(
      id: id,
      name: (name != null && name.isNotEmpty)
          ? name
          : (title != null && title.isNotEmpty)
          ? title
          : 'Unknown',
      iconUrl: (iconUrl != null && iconUrl.isNotEmpty)
          ? iconUrl
          : imageUrl ?? '',
    );
  }
}

class CompanySubField {
  final String id;
  final String name;
  final String iconUrl;

  const CompanySubField({
    required this.id,
    required this.name,
    required this.iconUrl,
  });

  factory CompanySubField.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final name = data['name']?.toString().trim();
    final title = data['title']?.toString().trim();
    final iconUrl = data['iconUrl']?.toString().trim();
    final imageUrl = data['imageUrl']?.toString().trim();

    return CompanySubField(
      id: id,
      name: (name != null && name.isNotEmpty)
          ? name
          : (title != null && title.isNotEmpty)
          ? title
          : 'Unknown',
      iconUrl: (iconUrl != null && iconUrl.isNotEmpty)
          ? iconUrl
          : imageUrl ?? '',
    );
  }
}

class _SalaryRange {
  final num min;
  final num max;

  const _SalaryRange({required this.min, required this.max});
}
