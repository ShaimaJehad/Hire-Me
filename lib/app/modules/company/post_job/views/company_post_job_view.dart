import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hire_me/core/utils/app_color.dart';
import 'package:hire_me/core/utils/app_text_style.dart';

import '../controllers/company_post_job_controller.dart';

class CompanyPostJobView extends GetView<CompanyPostJobController> {
  final bool showBackButton;

  const CompanyPostJobView({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCompanyLogo(),
                    const SizedBox(height: 22),

                    _label(icon: Icons.work_outline_rounded, text: 'Job Title'),
                    const SizedBox(height: 8),
                    _textField(
                      controller: controller.titleController,
                      hint: 'e.g Flutter Developer',
                      validatorText: 'Please enter job title',
                    ),

                    const SizedBox(height: 18),

                    _label(icon: Icons.category_outlined, text: 'Category'),
                    const SizedBox(height: 8),
                    _buildCategoryDropdown(),

                    const SizedBox(height: 18),

                    _label(
                      icon: Icons.account_tree_outlined,
                      text: 'Specialization',
                    ),
                    const SizedBox(height: 8),
                    _buildSubFieldDropdown(),

                    const SizedBox(height: 18),

                    _label(icon: Icons.work_history_outlined, text: 'Job Type'),
                    const SizedBox(height: 10),
                    _buildJobTypeSelector(),

                    const SizedBox(height: 18),

                    _label(icon: Icons.computer_rounded, text: 'Work Mode'),
                    const SizedBox(height: 10),
                    _buildWorkModeSelector(),

                    const SizedBox(height: 18),

                    _label(icon: Icons.location_on_outlined, text: 'Location'),
                    const SizedBox(height: 8),
                    _textField(
                      controller: controller.locationController,
                      hint: 'Gaza, Palestine',
                      validatorText: 'Please enter location',
                    ),

                    const SizedBox(height: 18),

                    _label(
                      icon: Icons.attach_money_rounded,
                      text: 'Salary Range',
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _textField(
                            controller: controller.minSalaryController,
                            hint: 'Min Salary',
                            keyboardType: TextInputType.number,
                            validatorText: 'Required',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _textField(
                            controller: controller.maxSalaryController,
                            hint: 'Max Salary',
                            keyboardType: TextInputType.number,
                            validatorText: 'Required',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    _label(
                      icon: Icons.description_outlined,
                      text: 'Job Description',
                    ),
                    const SizedBox(height: 8),
                    _textField(
                      controller: controller.descriptionController,
                      hint: 'Describe the role, responsibilities and more',
                      maxLines: 5,
                      validatorText: 'Please enter job description',
                    ),

                    const SizedBox(height: 18),

                    _label(icon: Icons.list_alt_rounded, text: 'Requirements'),
                    const SizedBox(height: 8),
                    _textField(
                      controller: controller.requirementsController,
                      hint: 'Add requirements or skills',
                      maxLines: 3,
                      validatorText: 'Please enter requirements',
                    ),

                    const SizedBox(height: 30),

                    _publishButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 76,
      width: double.infinity,
      color: AppColor.kblue,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          showBackButton
              ? GestureDetector(
                  onTap: () => Get.back(),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColor.kwhite,
                    size: 20,
                  ),
                )
              : const SizedBox(width: 20),
          Expanded(
            child: Obx(
              () => Text(
                controller.isEditMode.value ? 'Edit Job' : 'Post a Job',
                textAlign: TextAlign.center,
                style: CustomTextstyle.poppinsSemiBoldWhite.copyWith(
                  fontSize: 18,
                  color: AppColor.kwhite,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildCompanyLogo() {
    return Center(
      child: Column(
        children: [
          Obx(
            () => GestureDetector(
              onTap: controller.isUploadingLogo.value
                  ? null
                  : controller.pickAndUploadCompanyLogo,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xffDEE8F8),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColor.kblue.withValues(alpha: 0.25),
                  ),
                ),
                child: ClipOval(
                  child: controller.isUploadingLogo.value
                      ? Center(
                          child: CircularProgressIndicator(
                            color: AppColor.kblue,
                            strokeWidth: 2,
                          ),
                        )
                      : controller.companyLogoUrl.value.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: controller.companyLogoUrl.value,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              _logoPlaceholder(),
                        )
                      : _logoPlaceholder(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Company logo',
            style: TextStyle(
              color: AppColor.eblack,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _logoPlaceholder() {
    return Icon(Icons.camera_alt_outlined, color: AppColor.kblue, size: 30);
  }

  Widget _label({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColor.kblue),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: AppColor.eblack,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required String validatorText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return validatorText;
        }
        return null;
      },
      style: TextStyle(color: AppColor.eblack, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColor.greyLight, fontSize: 12),
        filled: true,
        fillColor: AppColor.kwhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(
            color: AppColor.eblack.withValues(alpha: 0.04),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: AppColor.kblue),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Obx(() {
      if (controller.isMainFieldsLoading.value) {
        return _loadingField();
      }

      if (controller.mainFields.isEmpty) {
        return _emptyField('No categories found');
      }

      final selectedName = controller.selectedMainFieldName.value.isEmpty
          ? 'Select category'
          : controller.selectedMainFieldName.value;

      return GestureDetector(
        onTap: _showMainFieldSheet,
        child: _selectorBox(
          text: selectedName,
          iconUrl: controller.selectedMainFieldIconUrl.value,
          isPlaceholder: controller.selectedMainFieldName.value.isEmpty,
        ),
      );
    });
  }

  Widget _buildSubFieldDropdown() {
    return Obx(() {
      if (controller.selectedMainFieldId.value.isEmpty) {
        return _emptyField('Select category first');
      }

      if (controller.isSubFieldsLoading.value) {
        return _loadingField();
      }

      if (controller.subFields.isEmpty) {
        return _emptyField('No specializations found');
      }

      final selectedName = controller.selectedSubFieldName.value.isEmpty
          ? 'Select specialization'
          : controller.selectedSubFieldName.value;

      return GestureDetector(
        onTap: _showSubFieldSheet,
        child: _selectorBox(
          text: selectedName,
          iconUrl: controller.selectedSubFieldIconUrl.value,
          isPlaceholder: controller.selectedSubFieldName.value.isEmpty,
        ),
      );
    });
  }

  Widget _loadingField() {
    return Container(
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColor.kwhite,
        borderRadius: BorderRadius.circular(7),
      ),
      child: SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(color: AppColor.kblue, strokeWidth: 2),
      ),
    );
  }

  Widget _emptyField(String text) {
    return Container(
      height: 52,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColor.kwhite,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: AppColor.eblack.withValues(alpha: 0.04)),
      ),
      child: Text(
        text,
        style: TextStyle(color: AppColor.greyLight, fontSize: 13),
      ),
    );
  }

  Widget _selectorBox({
    required String text,
    required String iconUrl,
    required bool isPlaceholder,
  }) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColor.kwhite,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: AppColor.eblack.withValues(alpha: 0.04)),
      ),
      child: Row(
        children: [
          _fieldIcon(iconUrl),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isPlaceholder ? AppColor.greyLight : AppColor.eblack,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColor.greyLight,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _fieldIcon(String iconUrl) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: AppColor.kblue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: iconUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: iconUrl,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Icon(
                  Icons.work_outline_rounded,
                  color: AppColor.kblue,
                  size: 17,
                ),
              ),
            )
          : Icon(Icons.work_outline_rounded, color: AppColor.kblue, size: 17),
    );
  }

  void _showMainFieldSheet() {
    Get.bottomSheet(
      _BottomSheetContainer(
        title: 'Select Category',
        icon: Icons.category_outlined,
        child: Obx(
          () => ListView.separated(
            shrinkWrap: true,
            itemCount: controller.mainFields.length,
            separatorBuilder: (_, _) => _sheetDivider(),
            itemBuilder: (context, index) {
              final field = controller.mainFields[index];
              final isSelected =
                  field.id == controller.selectedMainFieldId.value;

              return _SheetTile(
                title: field.name,
                iconUrl: field.iconUrl,
                isSelected: isSelected,
                onTap: () {
                  Get.back();
                  controller.selectMainField(field);
                },
              );
            },
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showSubFieldSheet() {
    Get.bottomSheet(
      _BottomSheetContainer(
        title: 'Select Specialization',
        icon: Icons.account_tree_outlined,
        child: Obx(
          () => ListView.separated(
            shrinkWrap: true,
            itemCount: controller.subFields.length,
            separatorBuilder: (_, _) => _sheetDivider(),
            itemBuilder: (context, index) {
              final field = controller.subFields[index];
              final isSelected =
                  field.id == controller.selectedSubFieldId.value;

              return _SheetTile(
                title: field.name,
                iconUrl: field.iconUrl,
                isSelected: isSelected,
                onTap: () {
                  Get.back();
                  controller.selectSubField(field);
                },
              );
            },
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _sheetDivider() {
    return Divider(
      height: 1,
      thickness: 0.8,
      color: AppColor.kblack.withValues(alpha: 0.05),
      indent: 54,
    );
  }

  Widget _buildJobTypeSelector() {
    return Obx(
      () => Row(
        children: [
          _pill(
            text: 'Full Time',
            value: 'FullTime',
            groupValue: controller.selectedJobType.value,
            onTap: controller.selectJobType,
          ),
          const SizedBox(width: 8),
          _pill(
            text: 'Part Time',
            value: 'PartTime',
            groupValue: controller.selectedJobType.value,
            onTap: controller.selectJobType,
          ),
          const SizedBox(width: 8),
          _pill(
            text: 'Freelance',
            value: 'Freelance',
            groupValue: controller.selectedJobType.value,
            onTap: controller.selectJobType,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkModeSelector() {
    return Obx(
      () => Row(
        children: [
          _pill(
            text: 'On Site',
            value: 'OnSite',
            groupValue: controller.selectedWorkMode.value,
            onTap: controller.selectWorkMode,
          ),
          const SizedBox(width: 8),
          _pill(
            text: 'Remote',
            value: 'Remote',
            groupValue: controller.selectedWorkMode.value,
            onTap: controller.selectWorkMode,
          ),
          const SizedBox(width: 8),
          _pill(
            text: 'Hybrid',
            value: 'Hybrid',
            groupValue: controller.selectedWorkMode.value,
            onTap: controller.selectWorkMode,
          ),
        ],
      ),
    );
  }

  Widget _pill({
    required String text,
    required String value,
    required String groupValue,
    required void Function(String value) onTap,
  }) {
    final isSelected = value == groupValue;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColor.kblue : AppColor.kwhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColor.kblue),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? AppColor.kwhite : AppColor.kblue,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _publishButton() {
    return Obx(
      () => Center(
        child: SizedBox(
          width: 170,
          height: 42,
          child: ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.submitJob,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.kblue,
              disabledBackgroundColor: AppColor.greyLight,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            child: controller.isLoading.value
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: AppColor.kwhite,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    controller.isEditMode.value ? 'Update Job' : 'Publish Job',
                    style: TextStyle(
                      color: AppColor.kwhite,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _BottomSheetContainer extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _BottomSheetContainer({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
      decoration: BoxDecoration(
        color: AppColor.kwhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: AppColor.kblack.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColor.greyLight.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColor.kblue.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColor.kblue, size: 23),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: AppColor.kblack,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  final String title;
  final String iconUrl;
  final bool isSelected;
  final VoidCallback onTap;

  const _SheetTile({
    required this.title,
    required this.iconUrl,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColor.kblue
                    : AppColor.kblue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: iconUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: iconUrl,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Icon(
                          Icons.work_outline_rounded,
                          color: isSelected ? AppColor.kwhite : AppColor.kblue,
                          size: 21,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.work_outline_rounded,
                      color: isSelected ? AppColor.kwhite : AppColor.kblue,
                      size: 21,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColor.kblack,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: AppColor.kblue, size: 22)
            else
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColor.greyLight,
                size: 15,
              ),
          ],
        ),
      ),
    );
  }
}
