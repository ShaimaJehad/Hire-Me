import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hire_me/app/modules/job_seeker/profile/models/user_model.dart';
import 'package:hire_me/core/utils/app_color.dart';
import 'package:hire_me/core/utils/app_text_style.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: SafeArea(
        child: SizedBox.expand(
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(color: AppColor.kblue),
                    );
                  }

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildProfileCard(),
                        const SizedBox(height: 10),
                        _buildAboutCard(),
                        const SizedBox(height: 10),
                        _buildExperienceCard(),
                        const SizedBox(height: 10),
                        _buildEducationCard(),
                        const SizedBox(height: 10),
                        _buildSkillsCard(),
                        const SizedBox(height: 10),
                        Obx(
                          () => controller.languages.isNotEmpty
                              ? Column(
                                  children: [
                                    _buildLanguagesCard(),
                                    const SizedBox(height: 10),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),
                        Obx(
                          () => controller.links.isNotEmpty
                              ? Column(
                                  children: [
                                    _buildLinksCard(),
                                    const SizedBox(height: 10),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 178,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Obx(
                    () => Container(
                      height: 110,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB0BEC5),
                        image: controller.coverImage.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(
                                  '${controller.coverImage}?t=${controller.coverCacheBust.value}',
                                ),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: controller.isUploadingCover.value
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: controller.pickAndUploadCover,
                                  child: _cameraIconButton(),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),

                Positioned(
                  top: 52,
                  left: 16,
                  child: Obx(() {
                    final selected = controller.selectedOpenTo.value;

                    return SizedBox(
                      width: 120,
                      height: 126,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: controller.pickAndUploadImage,
                            child: Container(
                              width: 112,
                              height: 112,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: selected != null
                                    ? controller.ringColor
                                    : Colors.white,
                              ),
                              child: Center(
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: controller.isUploadingImage.value
                                      ? CircularProgressIndicator(
                                          color: AppColor.kblue,
                                        )
                                      : CircleAvatar(
                                          radius: 48,
                                          backgroundColor: const Color(
                                            0xFFE8EDF9,
                                          ),
                                          backgroundImage:
                                              controller.userImage.isNotEmpty
                                              ? NetworkImage(
                                                  '${controller.userImage}?t=${controller.imageCacheBust.value}',
                                                )
                                              : null,
                                          child: controller.userImage.isEmpty
                                              ? Icon(
                                                  Icons.person_rounded,
                                                  size: 38,
                                                  color: AppColor.kblue,
                                                )
                                              : null,
                                        ),
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            bottom: 18,
                            right: 0,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: controller.pickAndUploadImage,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: AppColor.kblue,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 17,
                                ),
                              ),
                            ),
                          ),

                          if (selected != null)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: controller.ringColor,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    controller.badgeLabel,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Obx(
                      () => Text(
                        controller.userName.isEmpty
                            ? 'Your Name'
                            : controller.userName.toUpperCase(),
                        style: CustomTextstyle.interMedium,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Color(0xFF8A8A9A)),
                      onPressed: controller.logout,
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Obx(
                  () => controller.userTitle.isEmpty
                      ? const SizedBox.shrink()
                      : Text(
                          controller.userTitle,
                          style: CustomTextstyle.interRegular400,
                        ),
                ),

                const SizedBox(height: 2),

                Obx(
                  () => controller.userUniversity.isEmpty
                      ? const SizedBox.shrink()
                      : Text(
                          controller.userUniversity,
                          style: CustomTextstyle.interRegular400,
                        ),
                ),

                const SizedBox(height: 2),

                Obx(
                  () => controller.userLocation.isEmpty
                      ? const SizedBox.shrink()
                      : Text(
                          controller.userLocation,
                          style: CustomTextstyle.roboto300,
                        ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Flexible(
                      child: Obx(
                        () => ElevatedButton(
                          onPressed: controller.showOpenToBottomSheet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                controller.selectedOpenTo.value != null
                                ? controller.ringColor
                                : AppColor.kblue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (controller.isOpenToWork) ...[
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                              ],
                              Flexible(
                                child: Text(
                                  controller.selectedOpenToText.isNotEmpty
                                      ? controller.selectedOpenToText
                                      : 'Open to',
                                  style: CustomTextstyle.interRegular500,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    OutlinedButton(
                      onPressed: controller.showAddSectionBottomSheet,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        side: BorderSide(color: AppColor.lightThemeGrey),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        'Add section',
                        style: CustomTextstyle.interRegular500Grey,
                      ),
                    ),

                    const SizedBox(width: 8),

                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        side: BorderSide(color: AppColor.lightThemeGrey),
                        minimumSize: const Size(36, 36),
                        padding: EdgeInsets.zero,
                      ),
                      child: Icon(
                        Icons.more_horiz,
                        color: AppColor.lightThemeGrey,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return _sectionCard(
      title: 'About',
      icon: Icons.person_outline_rounded,
      onEdit: controller.showEditAboutDialog,
      child: Obx(
        () => controller.userAbout.isEmpty
            ? const Text(
                'Add about yourself...',
                style: TextStyle(fontSize: 13, color: Color(0xFF8A8A9A)),
              )
            : Text(
                controller.userAbout,
                style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E)),
              ),
      ),
    );
  }

  Widget _buildExperienceCard() {
    return _sectionCard(
      title: 'Experience',
      icon: Icons.calendar_today_outlined,
      onEdit: null,
      child: Obx(
        () => Column(
          children: [
            ...controller.experience.asMap().entries.map(
              (e) => _experienceItem(e.value, e.key),
            ),
            _addButton('Add experience', controller.showAddExperienceDialog),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationCard() {
    return _sectionCard(
      title: 'Education',
      icon: Icons.school_outlined,
      onEdit: null,
      child: Obx(
        () => Column(
          children: [
            ...controller.education.asMap().entries.map(
              (e) => _educationItem(e.value, e.key),
            ),
            _addButton('Add Education', controller.showAddEducationDialog),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsCard() {
    return _sectionCard(
      title: 'Skills',
      icon: Icons.description_outlined,
      onEdit: null,
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (controller.skills.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.skills
                    .asMap()
                    .entries
                    .map((e) => _skillChip(e.value, e.key))
                    .toList(),
              ),
            if (controller.skills.isNotEmpty) const SizedBox(height: 10),
            _addButton('Add Skills', controller.showAddSkillDialog),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguagesCard() {
    return _sectionCard(
      title: 'Languages',
      icon: Icons.language_rounded,
      onEdit: null,
      child: Obx(
        () => Column(
          children: [
            ...controller.languages.asMap().entries.map(
              (e) => _languageItem(e.value, e.key),
            ),
            _addButton('Add Language', controller.showAddLanguageDialog),
          ],
        ),
      ),
    );
  }

  Widget _buildLinksCard() {
    return _sectionCard(
      title: 'Links',
      icon: Icons.link_rounded,
      onEdit: null,
      child: Obx(
        () => Column(
          children: [
            ...controller.links.asMap().entries.map(
              (e) => _linkItem(e.value, e.key),
            ),
            _addButton('Add Link', controller.showAddLinkDialog),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    VoidCallback? onEdit,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppColor.kblue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
              if (onEdit != null)
                GestureDetector(
                  onTap: onEdit,
                  child: const Icon(
                    Icons.edit_outlined,
                    color: Color(0xFF8A8A9A),
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _educationItem(EducationModel e, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _iconBox(Icons.school_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.school,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  '${e.degree} · ${e.field}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8A8A9A),
                  ),
                ),
                Text(
                  '${e.startYear} - ${e.endYear}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8A8A9A),
                  ),
                ),
              ],
            ),
          ),
          _itemActions(
            onEdit: () => controller.showEditEducationDialog(index),
            onDelete: () => controller.deleteEducation(index),
          ),
        ],
      ),
    );
  }

  Widget _experienceItem(ExperienceModel e, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _iconBox(Icons.work_outline_rounded),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.position,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  e.company,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8A8A9A),
                  ),
                ),
                Text(
                  '${e.startDate} - ${e.endDate}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8A8A9A),
                  ),
                ),
              ],
            ),
          ),
          _itemActions(
            onEdit: () => controller.showEditExperienceDialog(index),
            onDelete: () => controller.deleteExperience(index),
          ),
        ],
      ),
    );
  }

  Widget _languageItem(LanguageModel e, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          _iconBox(Icons.language_rounded),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  e.level,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8A8A9A),
                  ),
                ),
              ],
            ),
          ),
          _itemActions(
            onEdit: () => controller.showEditLanguageDialog(index),
            onDelete: () => controller.deleteLanguage(index),
          ),
        ],
      ),
    );
  }

  Widget _linkItem(LinkModel e, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          _iconBox(_linkIcon(e.type)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.type,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  e.url,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1A3794),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _itemActions(
            onEdit: () => controller.showEditLinkDialog(index),
            onDelete: () => controller.deleteLink(index),
          ),
        ],
      ),
    );
  }

  IconData _linkIcon(String type) {
    switch (type) {
      case 'GitHub':
        return Icons.code_rounded;
      case 'LinkedIn':
        return Icons.work_outline_rounded;
      case 'Portfolio':
        return Icons.web_rounded;
      default:
        return Icons.link_rounded;
    }
  }

  Widget _skillChip(String skill, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDF9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skill,
            style: TextStyle(
              fontSize: 13,
              color: AppColor.kblue,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => controller.removeSkill(index),
            child: Icon(Icons.close, size: 14, color: AppColor.kblue),
          ),
        ],
      ),
    );
  }

  Widget _addButton(String label, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: AppColor.kblue),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      icon: Icon(Icons.add, size: 18, color: AppColor.kblue),
      label: Text(label, style: TextStyle(color: AppColor.kblue, fontSize: 13)),
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDF9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: AppColor.kblue, size: 22),
    );
  }

  Widget _itemActions({
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onEdit,
          child: const Icon(
            Icons.edit_outlined,
            size: 18,
            color: Color(0xFF8A8A9A),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onDelete,
          child: const Icon(
            Icons.delete_outline,
            size: 18,
            color: Color(0xFFEF4444),
          ),
        ),
      ],
    );
  }

  Widget _cameraIconButton() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.camera_alt_outlined, size: 18, color: AppColor.kblue),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:hire_me/app/modules/job_seeker/profile/models/user_model.dart';
// import 'package:hire_me/core/utils/app_color.dart';
// import 'package:hire_me/core/utils/app_text_style.dart';
// import '../controllers/profile_controller.dart';

// class ProfileView extends GetView<ProfileController> {
//   const ProfileView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FF),
//       body: SafeArea(
//         child: SizedBox.expand(
//           child: Stack(
//             children: [
//               // CurvedAppBar(
//               //   title: '',
//               //   // title: 'Profile',
//               //   // actions: [
//               //   //   IconButton(
//               //   //     icon: const Icon(Icons.logout, color: Colors.white),
//               //   //     onPressed: controller.logout,
//               //   //   ),
//               //   // ],
//               // ),
//               Positioned(
//                 top: 0,
//                 left: 0,
//                 right: 0,
//                 bottom: 0,
//                 child: Obx(() {
//                   if (controller.isLoading.value) {
//                     return Center(
//                       child: CircularProgressIndicator(color: AppColor.kblue),
//                     );
//                   }
//                   return SingleChildScrollView(
//                     child: Column(
//                       children: [
//                         _buildProfileCard(),
//                         const SizedBox(height: 10),
//                         _buildAboutCard(),
//                         const SizedBox(height: 10),
//                         _buildExperienceCard(),
//                         const SizedBox(height: 10),
//                         _buildEducationCard(),
//                         const SizedBox(height: 10),
//                         _buildSkillsCard(),
//                         const SizedBox(height: 10),
//                         Obx(
//                           () => controller.languages.isNotEmpty
//                               ? Column(
//                                   children: [
//                                     _buildLanguagesCard(),
//                                     const SizedBox(height: 10),
//                                   ],
//                                 )
//                               : const SizedBox.shrink(),
//                         ),
//                         Obx(
//                           () => controller.links.isNotEmpty
//                               ? Column(
//                                   children: [
//                                     _buildLinksCard(),
//                                     const SizedBox(height: 10),
//                                   ],
//                                 )
//                               : const SizedBox.shrink(),
//                         ),
//                         const SizedBox(height: 20),
//                       ],
//                     ),
//                   );
//                 }),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProfileCard() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       margin: const EdgeInsets.all(8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Stack(
//             clipBehavior: Clip.none,
//             children: [
//               ClipRRect(
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(12),
//                   topRight: Radius.circular(12),
//                 ),
//                 child: Obx(
//                   () => Container(
//                     height: 110,
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFB0BEC5),
//                       image: controller.coverImage.isNotEmpty
//                           ? DecorationImage(
//                               image: NetworkImage(
//                                 '${controller.coverImage}?t=${controller.coverCacheBust}',
//                               ),
//                               fit: BoxFit.cover,
//                             )
//                           : null,
//                     ),
//                     child: controller.isUploadingCover.value
//                         ? const Center(
//                             child: CircularProgressIndicator(
//                               color: Colors.white,
//                             ),
//                           )
//                         : Align(
//                             alignment: Alignment.topRight,
//                             child: Padding(
//                               padding: const EdgeInsets.all(10),
//                               child: GestureDetector(
//                                 onTap: controller.pickAndUploadCover,
//                                 child: _cameraIconButton(),
//                               ),
//                             ),
//                           ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 bottom: -60,
//                 left: 16,
//                 child: Obx(() {
//                   final selected = controller.selectedOpenTo.value;
//                   return GestureDetector(
//                     behavior: HitTestBehavior.translucent,
//                     onTap: () => controller
//                         .pickAndUploadImage(), // ← tap على الصورة كلها
//                     child: SizedBox(
//                       width: 120,
//                       height: 116,
//                       child: Stack(
//                         clipBehavior: Clip.none,
//                         children: [
//                           Container(
//                             width: 112,
//                             height: 112,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: selected != null
//                                   ? controller.ringColor
//                                   : Colors.white,
//                             ),
//                             child: Center(
//                               child: Container(
//                                 width: 100,
//                                 height: 100,
//                                 decoration: const BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: Colors.white,
//                                 ),
//                                 child: controller.isUploadingImage.value
//                                     ? CircularProgressIndicator(
//                                         color: AppColor.kblue,
//                                       )
//                                     : CircleAvatar(
//                                         radius: 48,
//                                         backgroundColor: const Color(
//                                           0xFFE8EDF9,
//                                         ),
//                                         backgroundImage:
//                                             controller.userImage.isNotEmpty
//                                             ? NetworkImage(
//                                                 '${controller.userImage}?t=${controller.imageCacheBust}',
//                                               )
//                                             : null,
//                                         child: controller.userImage.isEmpty
//                                             ? Icon(
//                                                 Icons.person_rounded,
//                                                 size: 38,
//                                                 color: AppColor.kblue,
//                                               )
//                                             : null,
//                                       ),
//                               ),
//                             ),
//                           ),
//                           Positioned(
//                             bottom: 20,
//                             right: 0,
//                             child: Container(
//                               width: 26,
//                               height: 26,
//                               decoration: BoxDecoration(
//                                 color: AppColor.kblue,
//                                 shape: BoxShape.circle,
//                                 border: Border.all(
//                                   color: Colors.white,
//                                   width: 2,
//                                 ),
//                               ),
//                               child: const Icon(
//                                 Icons.add,
//                                 color: Colors.white,
//                                 size: 14,
//                               ),
//                             ),
//                           ),
//                           if (selected != null)
//                             Positioned(
//                               bottom: 0,
//                               left: 0,
//                               right: 0,
//                               child: Center(
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 8,
//                                     vertical: 3,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: controller.ringColor,
//                                     borderRadius: BorderRadius.circular(20),
//                                     border: Border.all(
//                                       color: Colors.white,
//                                       width: 1.5,
//                                     ),
//                                   ),
//                                   child: Text(
//                                     controller.badgeLabel,
//                                     style: const TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 9,
//                                       fontWeight: FontWeight.w700,
//                                       letterSpacing: 0.3,
//                                     ),
//                                     overflow: TextOverflow.ellipsis,
//                                     maxLines: 1,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }),
//               ),
//             ],
//           ),
//           const SizedBox(height: 48),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Obx(
//                       () => Text(
//                         controller.userName.isEmpty
//                             ? 'Your Name'
//                             : controller.userName.toUpperCase(),
//                         style: CustomTextstyle.interMedium,
//                       ),
//                     ),
//                     const Spacer(),
//                     IconButton(
//                       icon: const Icon(Icons.logout, color: Color(0xFF8A8A9A)),
//                       onPressed: controller.logout,
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 Obx(
//                   () => controller.userTitle.isEmpty
//                       ? const SizedBox.shrink()
//                       : Text(
//                           controller.userTitle,
//                           style: CustomTextstyle.interRegular400,
//                         ),
//                 ),
//                 const SizedBox(height: 2),
//                 Obx(
//                   () => controller.userUniversity.isEmpty
//                       ? const SizedBox.shrink()
//                       : Text(
//                           controller.userUniversity,
//                           style: CustomTextstyle.interRegular400,
//                         ),
//                 ),
//                 const SizedBox(height: 2),
//                 Obx(
//                   () => controller.userLocation.isEmpty
//                       ? const SizedBox.shrink()
//                       : Text(
//                           controller.userLocation,
//                           style: CustomTextstyle.roboto300,
//                         ),
//                 ),
//                 const SizedBox(height: 14),
//                 Row(
//                   children: [
//                     Flexible(
//                       child: Obx(
//                         () => ElevatedButton(
//                           onPressed: controller.showOpenToBottomSheet,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor:
//                                 controller.selectedOpenTo.value != null
//                                 ? controller.ringColor
//                                 : AppColor.kblue,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 14,
//                               vertical: 8,
//                             ),
//                             elevation: 0,
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               if (controller.isOpenToWork) ...[
//                                 const Icon(
//                                   Icons.check_circle,
//                                   color: Colors.white,
//                                   size: 14,
//                                 ),
//                                 const SizedBox(width: 4),
//                               ],
//                               Flexible(
//                                 child: Text(
//                                   controller.selectedOpenToText.isNotEmpty
//                                       ? controller.selectedOpenToText
//                                       : 'Open to',
//                                   style: CustomTextstyle.interRegular500,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     OutlinedButton(
//                       onPressed: controller.showAddSectionBottomSheet,
//                       style: OutlinedButton.styleFrom(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         side: BorderSide(color: AppColor.lightThemeGrey),
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 8,
//                         ),
//                       ),
//                       child: Text(
//                         'Add section',
//                         style: CustomTextstyle.interRegular500Grey,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     OutlinedButton(
//                       onPressed: () {},
//                       style: OutlinedButton.styleFrom(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         side: BorderSide(color: AppColor.lightThemeGrey),
//                         minimumSize: const Size(36, 36),
//                         padding: EdgeInsets.zero,
//                       ),
//                       child: Icon(
//                         Icons.more_horiz,
//                         color: AppColor.lightThemeGrey,
//                         size: 20,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAboutCard() {
//     return _sectionCard(
//       title: 'About',
//       icon: Icons.person_outline_rounded,
//       onEdit: controller.showEditAboutDialog,
//       child: Obx(
//         () => controller.userAbout.isEmpty
//             ? const Text(
//                 'Add about yourself...',
//                 style: TextStyle(fontSize: 13, color: Color(0xFF8A8A9A)),
//               )
//             : Text(
//                 controller.userAbout,
//                 style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E)),
//               ),
//       ),
//     );
//   }

//   Widget _buildExperienceCard() {
//     return _sectionCard(
//       title: 'Experience',
//       icon: Icons.calendar_today_outlined,
//       onEdit: null,
//       child: Obx(
//         () => Column(
//           children: [
//             ...controller.experience.asMap().entries.map(
//               (e) => _experienceItem(e.value, e.key),
//             ),
//             _addButton('Add experience', controller.showAddExperienceDialog),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEducationCard() {
//     return _sectionCard(
//       title: 'Education',
//       icon: Icons.school_outlined,
//       onEdit: null,
//       child: Obx(
//         () => Column(
//           children: [
//             ...controller.education.asMap().entries.map(
//               (e) => _educationItem(e.value, e.key),
//             ),
//             _addButton('Add Education', controller.showAddEducationDialog),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSkillsCard() {
//     return _sectionCard(
//       title: 'Skills',
//       icon: Icons.description_outlined,
//       onEdit: null,
//       child: Obx(
//         () => Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (controller.skills.isNotEmpty)
//               Wrap(
//                 spacing: 8,
//                 runSpacing: 8,
//                 children: controller.skills
//                     .asMap()
//                     .entries
//                     .map((e) => _skillChip(e.value, e.key))
//                     .toList(),
//               ),
//             if (controller.skills.isNotEmpty) const SizedBox(height: 10),
//             _addButton('Add Skills', controller.showAddSkillDialog),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLanguagesCard() {
//     return _sectionCard(
//       title: 'Languages',
//       icon: Icons.language_rounded,
//       onEdit: null,
//       child: Obx(
//         () => Column(
//           children: [
//             ...controller.languages.asMap().entries.map(
//               (e) => _languageItem(e.value, e.key),
//             ),
//             _addButton('Add Language', controller.showAddLanguageDialog),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLinksCard() {
//     return _sectionCard(
//       title: 'Links',
//       icon: Icons.link_rounded,
//       onEdit: null,
//       child: Obx(
//         () => Column(
//           children: [
//             ...controller.links.asMap().entries.map(
//               (e) => _linkItem(e.value, e.key),
//             ),
//             _addButton('Add Link', controller.showAddLinkDialog),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _sectionCard({
//     required String title,
//     required IconData icon,
//     required Widget child,
//     VoidCallback? onEdit,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       margin: const EdgeInsets.symmetric(horizontal: 12),
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Icon(icon, color: AppColor.kblue, size: 20),
//                   const SizedBox(width: 8),
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF1A1A2E),
//                     ),
//                   ),
//                 ],
//               ),
//               if (onEdit != null)
//                 GestureDetector(
//                   onTap: onEdit,
//                   child: const Icon(
//                     Icons.edit_outlined,
//                     color: Color(0xFF8A8A9A),
//                     size: 20,
//                   ),
//                 ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           child,
//         ],
//       ),
//     );
//   }

//   Widget _educationItem(EducationModel e, int index) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _iconBox(Icons.school_outlined),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   e.school,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF1A1A2E),
//                   ),
//                 ),
//                 Text(
//                   '${e.degree} · ${e.field}',
//                   style: const TextStyle(
//                     fontSize: 13,
//                     color: Color(0xFF8A8A9A),
//                   ),
//                 ),
//                 Text(
//                   '${e.startYear} - ${e.endYear}',
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: Color(0xFF8A8A9A),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           _itemActions(
//             onEdit: () => controller.showEditEducationDialog(index),
//             onDelete: () => controller.deleteEducation(index),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _experienceItem(ExperienceModel e, int index) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _iconBox(Icons.work_outline_rounded),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   e.position,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF1A1A2E),
//                   ),
//                 ),
//                 Text(
//                   e.company,
//                   style: const TextStyle(
//                     fontSize: 13,
//                     color: Color(0xFF8A8A9A),
//                   ),
//                 ),
//                 Text(
//                   '${e.startDate} - ${e.endDate}',
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: Color(0xFF8A8A9A),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           _itemActions(
//             onEdit: () => controller.showEditExperienceDialog(index),
//             onDelete: () => controller.deleteExperience(index),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _languageItem(LanguageModel e, int index) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         children: [
//           _iconBox(Icons.language_rounded),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   e.name,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF1A1A2E),
//                   ),
//                 ),
//                 Text(
//                   e.level,
//                   style: const TextStyle(
//                     fontSize: 13,
//                     color: Color(0xFF8A8A9A),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           _itemActions(
//             onEdit: () => controller.showEditLanguageDialog(index),
//             onDelete: () => controller.deleteLanguage(index),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _linkItem(LinkModel e, int index) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         children: [
//           _iconBox(_linkIcon(e.type)),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   e.type,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF1A1A2E),
//                   ),
//                 ),
//                 Text(
//                   e.url,
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: Color(0xFF1A3794),
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//           _itemActions(
//             onEdit: () => controller.showEditLinkDialog(index),
//             onDelete: () => controller.deleteLink(index),
//           ),
//         ],
//       ),
//     );
//   }

//   IconData _linkIcon(String type) {
//     switch (type) {
//       case 'GitHub':
//         return Icons.code_rounded;
//       case 'LinkedIn':
//         return Icons.work_outline_rounded;
//       case 'Portfolio':
//         return Icons.web_rounded;
//       default:
//         return Icons.link_rounded;
//     }
//   }

//   Widget _skillChip(String skill, int index) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
//       decoration: BoxDecoration(
//         color: const Color(0xFFE8EDF9),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             skill,
//             style: TextStyle(
//               fontSize: 13,
//               color: AppColor.kblue,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(width: 6),
//           GestureDetector(
//             onTap: () => controller.removeSkill(index),
//             child: Icon(Icons.close, size: 14, color: AppColor.kblue),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _addButton(String label, VoidCallback onTap) {
//     return OutlinedButton.icon(
//       onPressed: onTap,
//       style: OutlinedButton.styleFrom(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         side: BorderSide(color: AppColor.kblue),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       ),
//       icon: Icon(Icons.add, size: 18, color: AppColor.kblue),
//       label: Text(label, style: TextStyle(color: AppColor.kblue, fontSize: 13)),
//     );
//   }

//   Widget _iconBox(IconData icon) => Container(
//     width: 40,
//     height: 40,
//     decoration: BoxDecoration(
//       color: const Color(0xFFE8EDF9),
//       borderRadius: BorderRadius.circular(8),
//     ),
//     child: Icon(icon, color: AppColor.kblue, size: 22),
//   );

//   Widget _itemActions({
//     required VoidCallback onEdit,
//     required VoidCallback onDelete,
//   }) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         GestureDetector(
//           onTap: onEdit,
//           child: const Icon(
//             Icons.edit_outlined,
//             size: 18,
//             color: Color(0xFF8A8A9A),
//           ),
//         ),
//         const SizedBox(width: 8),
//         GestureDetector(
//           onTap: onDelete,
//           child: const Icon(
//             Icons.delete_outline,
//             size: 18,
//             color: Color(0xFFEF4444),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _cameraIconButton() => Container(
//     padding: const EdgeInsets.all(6),
//     decoration: BoxDecoration(
//       color: Colors.white.withValues(alpha: 0.8),
//       shape: BoxShape.circle,
//     ),
//     child: Icon(Icons.camera_alt_outlined, size: 18, color: AppColor.kblue),
//   );
// }
