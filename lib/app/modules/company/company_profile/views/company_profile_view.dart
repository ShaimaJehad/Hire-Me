import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/app_color.dart';
import '../controllers/company_profile_controller.dart';

class CompanyProfileView extends GetView<CompanyProfileController> {
  const CompanyProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        backgroundColor: AppColor.kblue,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Company Profile',
          style: TextStyle(
            color: AppColor.kwhite,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: AppColor.kblue),
          );
        }

        return RefreshIndicator(
          color: AppColor.kblue,
          onRefresh: controller.refreshProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 110),
            child: Column(
              children: [
                _profileHeader(),
                const SizedBox(height: 16),
                _editProfileButton(),
                const SizedBox(height: 16),
                _statsRow(),
                const SizedBox(height: 18),
                _sectionTitle('Company Information'),
                const SizedBox(height: 10),
                _infoCard(),
                const SizedBox(height: 22),
                _logoutButton(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _profileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 22),
      decoration: BoxDecoration(
        color: AppColor.kwhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColor.kblack.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _companyLogo(),
          const SizedBox(height: 14),
          Text(
            controller.companyName.value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColor.kblack,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            controller.email.value.isEmpty
                ? 'No email available'
                : controller.email.value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColor.greyLight,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: AppColor.kblue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Company Account',
              style: TextStyle(
                color: AppColor.kblue,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _companyLogo() {
    return Obx(() {
      final imageUrl = controller.logoUrl.value;
      final isUploading = controller.isUploadingLogo.value;

      return GestureDetector(
        onTap: isUploading ? null : controller.pickAndUploadCompanyLogo,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: const Color(0xffDEE8F8),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColor.kblue.withValues(alpha: 0.25),
                  width: 1.4,
                ),
              ),
              child: ClipOval(
                child: imageUrl.isEmpty
                    ? Icon(
                        Icons.business_rounded,
                        color: AppColor.kblue,
                        size: 44,
                      )
                    : Image.network(
                        imageUrl,
                        key: ValueKey(imageUrl),
                        width: 92,
                        height: 92,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;

                          return Center(
                            child: CircularProgressIndicator(
                              color: AppColor.kblue,
                              strokeWidth: 2.2,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Company logo image error: $error');

                          return Icon(
                            Icons.business_rounded,
                            color: AppColor.kblue,
                            size: 44,
                          );
                        },
                      ),
              ),
            ),
            if (isUploading)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColor.kblack.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.4,
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              right: -2,
              bottom: 2,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColor.kblue,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColor.kwhite, width: 2),
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: AppColor.kwhite,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _editProfileButton() {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton.icon(
        onPressed: () {
          controller.prepareEditData();
          _showEditProfileSheet();
        },
        icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
        label: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.kblue,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _statsRow() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.business_center_outlined,
            title: 'Jobs',
            value: controller.totalJobs.value.toString(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            icon: Icons.groups_outlined,
            title: 'Applicants',
            value: controller.totalApplicants.value.toString(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            icon: Icons.check_circle_outline_rounded,
            title: 'Accepted',
            value: controller.acceptedApplicants.value.toString(),
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      height: 86,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: AppColor.kwhite,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColor.kblack.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColor.kblue, size: 22),
          const SizedBox(height: 5),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColor.kblack,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            constraints: const BoxConstraints(minWidth: 28, minHeight: 18),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColor.kblue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColor.kwhite,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          color: AppColor.kblack,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.kwhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColor.kblack.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _infoTile(
            icon: Icons.email_outlined,
            title: 'Email',
            value: controller.email.value,
          ),
          _divider(),
          _infoTile(
            icon: Icons.phone_outlined,
            title: 'Phone',
            value: controller.phone.value,
          ),
          _divider(),
          _infoTile(
            icon: Icons.location_on_outlined,
            title: 'Location',
            value: controller.location.value,
          ),
          _divider(),
          _infoTile(
            icon: Icons.language_rounded,
            title: 'Website',
            value: controller.website.value,
          ),
          _divider(),
          _infoTile(
            icon: Icons.description_outlined,
            title: 'About Company',
            value: controller.description.value,
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
    int maxLines = 1,
  }) {
    final displayValue = value.trim().isEmpty ? 'Not added yet' : value.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        crossAxisAlignment: maxLines > 1
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColor.kblue.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColor.kblue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColor.greyLight,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  displayValue,
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColor.kblack,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 0.8,
      color: AppColor.kblack.withValues(alpha: 0.05),
      indent: 66,
      endIndent: 16,
    );
  }

  Widget _logoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: controller.logout,
        icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
        label: const Text(
          'Logout',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEF4444),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showEditProfileSheet() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: 18,
          bottom: MediaQuery.of(Get.context!).viewInsets.bottom + 24,
        ),
        decoration: BoxDecoration(
          color: AppColor.kwhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColor.greyLight.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Edit Company Profile',
                style: TextStyle(
                  color: AppColor.kblack,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              _editField(
                label: 'Company Name',
                controller: controller.companyNameController,
                icon: Icons.business_outlined,
              ),
              const SizedBox(height: 12),
              _editField(
                label: 'Phone',
                controller: controller.phoneController,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _editField(
                label: 'Location',
                controller: controller.locationController,
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 12),
              _editField(
                label: 'Website',
                controller: controller.websiteController,
                icon: Icons.language_rounded,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),
              _editField(
                label: 'About Company',
                controller: controller.descriptionController,
                icon: Icons.description_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: controller.isSaving.value
                        ? null
                        : controller.updateCompanyProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.kblue,
                      disabledBackgroundColor: AppColor.kblue.withValues(
                        alpha: 0.5,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isSaving.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.3,
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _editField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColor.kblue, size: 20),
        filled: true,
        fillColor: const Color(0xffF5F7FA),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.kblue, width: 1.2),
        ),
      ),
    );
  }
}
