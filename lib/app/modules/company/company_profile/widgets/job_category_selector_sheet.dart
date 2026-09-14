import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hire_me/app/modules/company/post_job/controllers/company_post_job_controller.dart';

import 'package:hire_me/core/utils/app_color.dart';

class JobCategorySelectorSheet extends StatelessWidget {
  final List<CompanyMainField> categories;
  final String selectedCategoryId;
  final void Function(CompanyMainField category) onSelect;

  const JobCategorySelectorSheet({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelect,
  });

  static void show({
    required List<CompanyMainField> categories,
    required String selectedCategoryId,
    required void Function(CompanyMainField category) onSelect,
  }) {
    Get.bottomSheet(
      JobCategorySelectorSheet(
        categories: categories,
        selectedCategoryId: selectedCategoryId,
        onSelect: onSelect,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

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
            _sheetHandle(),
            const SizedBox(height: 18),
            _sheetHeader(),
            const SizedBox(height: 18),
            _categoriesList(),
          ],
        ),
      ),
    );
  }

  Widget _sheetHandle() {
    return Container(
      width: 42,
      height: 4,
      decoration: BoxDecoration(
        color: AppColor.greyLight.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }

  Widget _sheetHeader() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColor.kblue.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.category_outlined, color: AppColor.kblue, size: 23),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Select Category',
            style: TextStyle(
              color: AppColor.kblack,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _categoriesList() {
    return Flexible(
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: categories.length,
        separatorBuilder: (_, _) => Divider(
          height: 1,
          thickness: 0.8,
          color: AppColor.kblack.withValues(alpha: 0.05),
          indent: 54,
        ),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.id == selectedCategoryId;

          return _CategoryTile(
            category: category,
            isSelected: isSelected,
            onTap: () {
              Get.back();
              onSelect(category);
            },
          );
        },
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CompanyMainField category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.category,
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
              child: Icon(
                Icons.work_outline_rounded,
                color: isSelected ? AppColor.kwhite : AppColor.kblue,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                category.name,
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
