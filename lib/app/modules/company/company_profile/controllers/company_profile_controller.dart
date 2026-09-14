import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hire_me/app/routes/app_pages.dart';
import 'package:hire_me/app/services/storage_service.dart';

class CompanyProfileController extends GetxController {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  static const String _logoBucket = 'logos';
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _jobsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _applicationsSub;

  final isLoading = true.obs;
  final isSaving = false.obs;
  final isUploadingLogo = false.obs;

  final companyName = 'Company'.obs;
  final email = ''.obs;
  final phone = ''.obs;
  final location = ''.obs;
  final website = ''.obs;
  final description = ''.obs;
  final logoUrl = ''.obs;

  final totalJobs = 0.obs;
  final totalApplicants = 0.obs;
  final acceptedApplicants = 0.obs;

  final companyNameController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();
  final websiteController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadCompanyProfile();
    listenToCompanyStats();
  }

  Future<void> loadCompanyProfile() async {
    try {
      isLoading.value = true;

      final user = _auth.currentUser;

      if (user == null) {
        isLoading.value = false;
        return;
      }

      email.value = user.email ?? '';

      final companyDoc = await _firestore
          .collection('companies')
          .doc(user.uid)
          .get();

      if (companyDoc.exists && companyDoc.data() != null) {
        _fillCompanyData(companyDoc.data()!, user);
        return;
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        _fillCompanyData(userDoc.data()!, user);
        return;
      }

      companyName.value = user.displayName ?? 'Company';
    } catch (e) {
      debugPrint('Load company profile error: $e');

      Get.snackbar(
        'Error',
        'Failed to load company profile',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _fillCompanyData(Map<String, dynamic> data, firebase_auth.User user) {
    companyName.value =
        data['companyName']?.toString() ??
        data['name']?.toString() ??
        data['fullName']?.toString() ??
        user.displayName ??
        'Company';

    email.value = data['email']?.toString() ?? user.email ?? '';

    phone.value =
        data['phone']?.toString() ?? data['phoneNumber']?.toString() ?? '';

    location.value =
        data['location']?.toString() ?? data['address']?.toString() ?? '';

    website.value =
        data['website']?.toString() ?? data['websiteUrl']?.toString() ?? '';

    description.value =
        data['description']?.toString() ?? data['about']?.toString() ?? '';

    logoUrl.value =
        data['logoUrl']?.toString() ?? data['companyLogoUrl']?.toString() ?? '';
  }

  void listenToCompanyStats() {
    final uid = _auth.currentUser?.uid;

    if (uid == null) return;

    _jobsSub?.cancel();
    _applicationsSub?.cancel();

    _jobsSub = _firestore
        .collection('jobs')
        .where('companyId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
          totalJobs.value = snapshot.docs.where((doc) {
            final data = doc.data();
            return data['isDeleted'] != true;
          }).length;
        });

    _applicationsSub = _firestore
        .collection('applications')
        .where('companyId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
          totalApplicants.value = snapshot.docs.length;

          acceptedApplicants.value = snapshot.docs.where((doc) {
            final status = doc.data()['status']?.toString().toLowerCase() ?? '';
            return status == 'accepted';
          }).length;
        });
  }

  Future<void> pickAndUploadCompanyLogo() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        Get.snackbar(
          'Error',
          'Please login first',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final pickedFile = result.files.single;

      if (pickedFile.path == null || pickedFile.path!.isEmpty) {
        Get.snackbar(
          'Error',
          'Invalid image file',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      isUploadingLogo.value = true;

      final file = File(pickedFile.path!);
      final extension = pickedFile.extension ?? 'jpg';

      final fileName =
          '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.$extension';

      await _supabase.storage
          .from(_logoBucket)
          .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

      final imageUrl = _supabase.storage
          .from(_logoBucket)
          .getPublicUrl(fileName);

      logoUrl.value = imageUrl;

      await _firestore.collection('companies').doc(user.uid).set({
        'logoUrl': imageUrl,
        'companyLogoUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Get.snackbar(
        'Success',
        'Company logo updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('Upload company logo error: $e');

      Get.snackbar(
        'Error',
        'Failed to upload company logo',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUploadingLogo.value = false;
    }
  }

  void prepareEditData() {
    companyNameController.text = companyName.value;
    phoneController.text = phone.value;
    locationController.text = location.value;
    websiteController.text = website.value;
    descriptionController.text = description.value;
  }

  Future<void> updateCompanyProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      Get.snackbar(
        'Error',
        'Please login first',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final newCompanyName = companyNameController.text.trim();
    final newPhone = phoneController.text.trim();
    final newLocation = locationController.text.trim();
    final newWebsite = websiteController.text.trim();
    final newDescription = descriptionController.text.trim();

    if (newCompanyName.isEmpty) {
      Get.snackbar(
        'Error',
        'Company name is required',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSaving.value = true;

    try {
      await _firestore.collection('companies').doc(user.uid).set({
        'companyName': newCompanyName,
        'email': email.value,
        'phone': newPhone,
        'location': newLocation,
        'website': newWebsite,
        'description': newDescription,
        'logoUrl': logoUrl.value,
        'companyLogoUrl': logoUrl.value,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      companyName.value = newCompanyName;
      phone.value = newPhone;
      location.value = newLocation;
      website.value = newWebsite;
      description.value = newDescription;

      Get.back();

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('Update company profile error: $e');

      Get.snackbar(
        'Error',
        'Failed to update profile',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> refreshProfile() async {
    await loadCompanyProfile();
  }

  Future<void> logout() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      final role = StorageService.to.userRole;
      final roleCollection = role == AppUserRole.company.value
          ? 'companies'
          : 'jobSeekers';
      await _firestore.collection(roleCollection).doc(uid).set({
        'fcmToken': FieldValue.delete(),
      }, SetOptions(merge: true));
      await _firestore.collection('users').doc(uid).set({
        'fcmToken': FieldValue.delete(),
      }, SetOptions(merge: true));
      await FirebaseMessaging.instance.deleteToken();
    }
    await StorageService.to.clearAuthSession();
    await _auth.signOut();
    Get.offAllNamed(Routes.authLogin);
  }

  @override
  void onClose() {
    _jobsSub?.cancel();
    _applicationsSub?.cancel();

    companyNameController.dispose();
    phoneController.dispose();
    locationController.dispose();
    websiteController.dispose();
    descriptionController.dispose();

    super.onClose();
  }
}
