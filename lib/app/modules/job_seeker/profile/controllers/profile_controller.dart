import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hire_me/app/modules/job_seeker/profile/models/user_model.dart';
import 'package:hire_me/app/routes/app_pages.dart';
import 'package:hire_me/app/services/storage_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileController extends GetxController {
  // ── State ─────────────────────────────────────────────
  final userModel = Rxn<UserModel>();
  final isLoading = false.obs;
  final isUploadingImage = false.obs;
  final isUploadingCover = false.obs;
  final selectedOpenTo = Rxn<String>();
  final imageCacheBust = 0.obs;
  final coverCacheBust = 0.obs;

  // ── Firebase + Supabase ───────────────────────────────
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _supabase = Supabase.instance.client;
  final _picker = ImagePicker();

  // ── Getters ───────────────────────────────────────────
  String get userName => userModel.value?.name ?? '';
  String get userTitle => userModel.value?.title ?? '';
  String get userUniversity => userModel.value?.university ?? '';
  String get userLocation => userModel.value?.location ?? '';
  String get userAbout => userModel.value?.about ?? '';
  String get userImage => userModel.value?.profileImage ?? '';
  String get coverImage => userModel.value?.coverImage ?? '';
  List<EducationModel> get education => userModel.value?.education ?? [];
  List<ExperienceModel> get experience => userModel.value?.experience ?? [];
  List<String> get skills => userModel.value?.skills ?? [];
  List<LanguageModel> get languages => userModel.value?.languages ?? [];
  List<LinkModel> get links => userModel.value?.links ?? [];
  bool get isOpenToWork => selectedOpenTo.value != null;
  String get selectedOpenToText => selectedOpenTo.value ?? '';
  String get badgeLabel {
    return selectedOpenTo.value ?? '';
  }

  Color get ringColor {
    switch (selectedOpenTo.value) {
      case 'Open to Work':
        return const Color(0xFF4CAF50);
      case 'Open to Freelance':
        return const Color(0xFF2196F3);
      case 'Open to Internship':
        return const Color(0xFFFF9800);
      default:
        return Colors.white;
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  // ── Load Profile ──────────────────────────────────────
  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      final uid = _auth.currentUser!.uid;
      final doc = await _firestore.collection('jobSeekers').doc(uid).get();

      if (doc.exists) {
        userModel.value = UserModel.fromMap(doc.data()!);

        if (userModel.value?.name.isEmpty ?? true) {
          final userDoc = await _firestore.collection('users').doc(uid).get();
          final name = userDoc.data()?['name'] ?? '';
          if (name.isNotEmpty) {
            await _updateField('name', name);
            userModel.value = userModel.value?.copyWith(name: name);
          }
        }

        final saved = doc.data()?['openTo'] as String?;
        selectedOpenTo.value = saved;
      } else {
        final userDoc = await _firestore.collection('users').doc(uid).get();
        final name = userDoc.data()?['name'] ?? '';
        final newUser = UserModel(
          uid: uid,
          email: _auth.currentUser?.email ?? '',
          role: AppUserRole.jobSeeker.value,
          name: name,
        );
        await _firestore.collection('jobSeekers').doc(uid).set(newUser.toMap());
        userModel.value = newUser;
      }
    } catch (e) {
      _showError('Failed to load profile');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Open To Work ──────────────────────────────────────
  void showOpenToBottomSheet() {
    final allOptions = [
      'Open to Work',
      'Open to Freelance',
      'Open to Internship',
    ];
    final tempSelected = Rxn<String>(selectedOpenTo.value);

    Get.bottomSheet(
      Obx(
        () => Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Open to',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Let recruiters know what opportunities you're looking for",
                style: TextStyle(fontSize: 13, color: Color(0xFF8A8A9A)),
              ),
              const SizedBox(height: 20),
              ...allOptions.map((option) {
                final isSelected = tempSelected.value == option;
                return GestureDetector(
                  onTap: () => tempSelected.value = isSelected ? null : option,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE8EDF9)
                          : const Color(0xFFF5F7FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF1A3794)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(
                                    0xFF1A3794,
                                  ).withValues(alpha: 0.12)
                                : const Color(0xFFE8EDF9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _optionIcon(option),
                            color: isSelected
                                ? const Color(0xFF1A3794)
                                : const Color(0xFF8A8A9A),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          option,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected
                                ? const Color(0xFF1A3794)
                                : const Color(0xFF1A1A2E),
                          ),
                        ),
                        const Spacer(),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: isSelected
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF1A3794),
                                  size: 22,
                                  key: ValueKey('check'),
                                )
                              : const Icon(
                                  Icons.circle_outlined,
                                  color: Color(0xFFCCCCCC),
                                  size: 22,
                                  key: ValueKey('empty'),
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    await _saveOpenTo(tempSelected.value);
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3794),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> _saveOpenTo(String? selected) async {
    selectedOpenTo.value = selected;
    await _updateField('openTo', selected);
  }

  IconData _optionIcon(String option) {
    switch (option) {
      case 'Open to Work':
        return Icons.work_outline_rounded;
      case 'Open to Freelance':
        return Icons.laptop_outlined;
      case 'Open to Internship':
        return Icons.school_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  // ── Add Section Bottom Sheet ──────────────────────────
  void showAddSectionBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Add section',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 20),

            // Languages
            _sectionOption(
              icon: Icons.language_rounded,
              label: 'Languages',
              subtitle: 'Add languages you speak',
              onTap: () {
                Get.back();
                showAddLanguageDialog();
              },
            ),
            const SizedBox(height: 12),

            // Links
            _sectionOption(
              icon: Icons.link_rounded,
              label: 'Links',
              subtitle: 'LinkedIn, GitHub, Portfolio...',
              onTap: () {
                Get.back();
                showAddLinkDialog();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _sectionOption({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EDF9),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF1A3794), size: 22),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8A8A9A),
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Color(0xFF8A8A9A),
            ),
          ],
        ),
      ),
    );
  }

  // ── Languages ─────────────────────────────────────────
  void showAddLanguageDialog() => _openLanguageDialog();
  void showEditLanguageDialog(int index) =>
      _openLanguageDialog(index: index, existing: languages[index]);

  Future<void> deleteLanguage(int index) async {
    final updated = [...languages]..removeAt(index);
    await _updateField('languages', updated.map((e) => e.toMap()).toList());
    userModel.value = userModel.value?.copyWith(languages: updated);
  }

  void _openLanguageDialog({int? index, LanguageModel? existing}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final levels = ['Beginner', 'Intermediate', 'Fluent', 'Native'];
    final selectedLevel =
        (existing?.level.isNotEmpty == true ? existing!.level : levels[0]).obs;

    Get.dialog(
      AlertDialog(
        title: Text(index == null ? 'Add Language' : 'Edit Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogField(nameCtrl, 'Language (e.g. Arabic, English)'),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Level',
                style: TextStyle(fontSize: 13, color: Color(0xFF8A8A9A)),
              ),
            ),
            const SizedBox(height: 6),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: levels.map((lvl) {
                  final isSelected = selectedLevel.value == lvl;
                  return GestureDetector(
                    onTap: () => selectedLevel.value = lvl,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1A3794)
                            : const Color(0xFFE8EDF9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        lvl,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF1A3794),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              final lang = LanguageModel(
                name: nameCtrl.text.trim(),
                level: selectedLevel.value,
              );
              final updated = [...languages];
              index == null ? updated.add(lang) : updated[index] = lang;
              await _updateField(
                'languages',
                updated.map((e) => e.toMap()).toList(),
              );
              userModel.value = userModel.value?.copyWith(languages: updated);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A3794),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Links ─────────────────────────────────────────────
  void showAddLinkDialog() => _openLinkDialog();
  void showEditLinkDialog(int index) =>
      _openLinkDialog(index: index, existing: links[index]);

  Future<void> deleteLink(int index) async {
    final updated = [...links]..removeAt(index);
    await _updateField('links', updated.map((e) => e.toMap()).toList());
    userModel.value = userModel.value?.copyWith(links: updated);
  }

  void _openLinkDialog({int? index, LinkModel? existing}) {
    final urlCtrl = TextEditingController(text: existing?.url ?? '');
    final types = ['LinkedIn', 'GitHub', 'Portfolio', 'Other'];
    final selectedType =
        (existing?.type.isNotEmpty == true ? existing!.type : types[0]).obs;

    Get.dialog(
      AlertDialog(
        title: Text(index == null ? 'Add Link' : 'Edit Link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Type',
                style: TextStyle(fontSize: 13, color: Color(0xFF8A8A9A)),
              ),
            ),
            const SizedBox(height: 6),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: types.map((t) {
                  final isSelected = selectedType.value == t;
                  return GestureDetector(
                    onTap: () => selectedType.value = t,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1A3794)
                            : const Color(0xFFE8EDF9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        t,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF1A3794),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            _dialogField(urlCtrl, 'https://...'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (urlCtrl.text.trim().isEmpty) return;
              final link = LinkModel(
                type: selectedType.value,
                url: urlCtrl.text.trim(),
              );
              final updated = [...links];
              index == null ? updated.add(link) : updated[index] = link;
              await _updateField(
                'links',
                updated.map((e) => e.toMap()).toList(),
              );
              userModel.value = userModel.value?.copyWith(links: updated);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A3794),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Upload Profile Image ──────────────────────────────
  Future<void> pickAndUploadImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked == null) return;

    isUploadingImage.value = true;
    try {
      final uid = _auth.currentUser!.uid;
      final fileName = 'profile_$uid.jpg';
      await _supabase.storage
          .from('profile-images')
          .upload(
            fileName,
            File(picked.path),
            fileOptions: const FileOptions(upsert: true),
          );
      final imageUrl = _supabase.storage
          .from('profile-images')
          .getPublicUrl(fileName);
      await _updateField('profileImage', imageUrl);
      userModel.value = userModel.value?.copyWith(profileImage: imageUrl);
      imageCacheBust.value = DateTime.now().millisecondsSinceEpoch;
      _showSuccess('Profile photo updated!');
    } catch (e) {
      _showError('Failed to upload photo: $e');
    } finally {
      isUploadingImage.value = false;
    }
  }

  // ── Upload Cover Image ────────────────────────────────
  Future<void> pickAndUploadCover() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked == null) return;

    isUploadingCover.value = true;
    try {
      final uid = _auth.currentUser!.uid;
      final fileName = 'cover_$uid.jpg';
      await _supabase.storage
          .from('profile-images')
          .upload(
            fileName,
            File(picked.path),
            fileOptions: const FileOptions(upsert: true),
          );
      final coverUrl = _supabase.storage
          .from('profile-images')
          .getPublicUrl(fileName);
      await _updateField('coverImage', coverUrl);
      userModel.value = userModel.value?.copyWith(coverImage: coverUrl);
      coverCacheBust.value = DateTime.now().millisecondsSinceEpoch;
      _showSuccess('Cover photo updated!');
    } catch (e) {
      _showError('Failed to upload cover: $e');
    } finally {
      isUploadingCover.value = false;
    }
  }

  // ── About ─────────────────────────────────────────────
  void showEditAboutDialog() {
    final ctrl = TextEditingController(text: userAbout);
    _showEditDialog(
      title: 'Edit About',
      fields: [_dialogField(ctrl, 'About yourself...', maxLines: 4)],
      onSave: () async {
        await _updateField('about', ctrl.text.trim());
        userModel.value = userModel.value?.copyWith(about: ctrl.text.trim());
      },
    );
  }

  // ── Education ─────────────────────────────────────────
  void showAddEducationDialog() => _openEducationDialog();
  void showEditEducationDialog(int index) =>
      _openEducationDialog(index: index, existing: education[index]);

  Future<void> deleteEducation(int index) async {
    final updated = [...education]..removeAt(index);
    await _updateField('education', updated.map((e) => e.toMap()).toList());
    userModel.value = userModel.value?.copyWith(education: updated);
  }

  void _openEducationDialog({int? index, EducationModel? existing}) {
    final schoolCtrl = TextEditingController(text: existing?.school ?? '');
    final degreeCtrl = TextEditingController(text: existing?.degree ?? '');
    final fieldCtrl = TextEditingController(text: existing?.field ?? '');
    final startCtrl = TextEditingController(text: existing?.startYear ?? '');
    final endCtrl = TextEditingController(text: existing?.endYear ?? '');

    _showEditDialog(
      title: index == null ? 'Add Education' : 'Edit Education',
      fields: [
        _dialogField(schoolCtrl, 'School / University'),
        _dialogField(degreeCtrl, 'Degree'),
        _dialogField(fieldCtrl, 'Field of Study'),
        _dialogField(startCtrl, 'Start Year'),
        _dialogField(endCtrl, 'End Year'),
      ],
      onSave: () async {
        if (schoolCtrl.text.isEmpty) return;
        final edu = EducationModel(
          school: schoolCtrl.text,
          degree: degreeCtrl.text,
          field: fieldCtrl.text,
          startYear: startCtrl.text,
          endYear: endCtrl.text,
        );
        final updated = [...education];
        index == null ? updated.add(edu) : updated[index] = edu;
        await _updateField('education', updated.map((e) => e.toMap()).toList());
        userModel.value = userModel.value?.copyWith(education: updated);
      },
    );
  }

  // ── Experience ────────────────────────────────────────
  void showAddExperienceDialog() => _openExperienceDialog();
  void showEditExperienceDialog(int index) =>
      _openExperienceDialog(index: index, existing: experience[index]);

  Future<void> deleteExperience(int index) async {
    final updated = [...experience]..removeAt(index);
    await _updateField('experience', updated.map((e) => e.toMap()).toList());
    userModel.value = userModel.value?.copyWith(experience: updated);
  }

  void _openExperienceDialog({int? index, ExperienceModel? existing}) {
    final companyCtrl = TextEditingController(text: existing?.company ?? '');
    final positionCtrl = TextEditingController(text: existing?.position ?? '');
    final startCtrl = TextEditingController(text: existing?.startDate ?? '');
    final endCtrl = TextEditingController(text: existing?.endDate ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');

    _showEditDialog(
      title: index == null ? 'Add Experience' : 'Edit Experience',
      fields: [
        _dialogField(companyCtrl, 'Company'),
        _dialogField(positionCtrl, 'Position'),
        _dialogField(startCtrl, 'Start Date'),
        _dialogField(endCtrl, 'End Date'),
        _dialogField(descCtrl, 'Description', maxLines: 3),
      ],
      onSave: () async {
        if (companyCtrl.text.isEmpty) return;
        final exp = ExperienceModel(
          company: companyCtrl.text,
          position: positionCtrl.text,
          startDate: startCtrl.text,
          endDate: endCtrl.text,
          description: descCtrl.text,
        );
        final updated = [...experience];
        index == null ? updated.add(exp) : updated[index] = exp;
        await _updateField(
          'experience',
          updated.map((e) => e.toMap()).toList(),
        );
        userModel.value = userModel.value?.copyWith(experience: updated);
      },
    );
  }

  // ── Skills ────────────────────────────────────────────
  void showAddSkillDialog() {
    final skillCtrl = TextEditingController();
    _showEditDialog(
      title: 'Add Skill',
      fields: [_dialogField(skillCtrl, 'Skill name')],
      onSave: () async {
        if (skillCtrl.text.trim().isEmpty) return;
        final updated = [...skills, skillCtrl.text.trim()];
        await _updateField('skills', updated);
        userModel.value = userModel.value?.copyWith(skills: updated);
      },
    );
  }

  Future<void> removeSkill(int index) async {
    final updated = [...skills]..removeAt(index);
    await _updateField('skills', updated);
    userModel.value = userModel.value?.copyWith(skills: updated);
  }

  // ── Logout ────────────────────────────────────────────
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

  // ── Shared Dialog Helper ──────────────────────────────
  void _showEditDialog({
    required String title,
    required List<Widget> fields,
    required Future<void> Function() onSave,
  }) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: fields),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await onSave();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A3794),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _syncProfileWithApplications(Map<String, dynamic> data) async {
    final uid = _auth.currentUser?.uid;

    if (uid == null) return;

    final snapshot = await _firestore
        .collection('applications')
        .where('seekerId', isEqualTo: uid)
        .get();

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.set(doc.reference, data, SetOptions(merge: true));
    }

    await batch.commit();
  }

  Future<void> _updateField(String field, dynamic value) async {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      _showError('Please login first');
      return;
    }

    await _firestore.collection('jobSeekers').doc(uid).set({
      field: value,
    }, SetOptions(merge: true));

    await _firestore.collection('users').doc(uid).set({
      field: value,
    }, SetOptions(merge: true));

    final fieldsToSync = {'name', 'title', 'location', 'profileImage', 'about'};

    if (fieldsToSync.contains(field)) {
      final appField = <String, dynamic>{};

      if (field == 'name') {
        appField['applicantName'] = value;
        appField['seekerName'] = value;
        appField['name'] = value;
      }

      if (field == 'title') {
        appField['applicantTitle'] = value;
        appField['title'] = value;
      }

      if (field == 'location') {
        appField['applicantLocation'] = value;
        appField['location'] = value;
      }

      if (field == 'profileImage') {
        appField['applicantImage'] = value;
        appField['profileImage'] = value;
        appField['imageUrl'] = value;
        appField['avatarUrl'] = value;
      }

      if (field == 'about') {
        appField['applicantAbout'] = value;
        appField['about'] = value;
      }

      if (appField.isNotEmpty) {
        appField['applicantUpdatedAt'] = FieldValue.serverTimestamp();
        await _syncProfileWithApplications(appField);
      }
    }
  }

  Widget _dialogField(
    TextEditingController ctrl,
    String hint, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  void _showError(String msg) => Get.snackbar(
    'Error',
    msg,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: const Color(0xFFEF4444),
    colorText: Colors.white,
    margin: const EdgeInsets.all(16),
    borderRadius: 12,
  );

  void _showSuccess(String msg) => Get.snackbar(
    'Success',
    msg,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: const Color(0xFF22C55E),
    colorText: Colors.white,
    margin: const EdgeInsets.all(16),
    borderRadius: 12,
  );
}
