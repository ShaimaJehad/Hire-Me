import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hire_me/core/utils/app_color.dart';
import '../../controllers/job_seeker_dashboard_controller.dart';

class SubFieldsWidget extends GetView<JobSeekerDashboardController> {
  const SubFieldsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedSubId = controller.selectedSubFieldId.value;

      if (controller.selectedMainFieldId.value == 'all') {
        return const SizedBox.shrink();
      }

      if (controller.isSubFieldsLoading.value) {
        return const SizedBox(
          height: 58,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.subFields.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 12),
            child: Text(
              'Choose specialization',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Colors.black.withValues(alpha: 0.78),
              ),
            ),
          ),

          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: controller.subFields.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _subFieldChip(
                    title: 'All',
                    iconUrl: '',
                    isSelected: selectedSubId == 'all',
                    onTap: () => controller.selectSubField('all'),
                  );
                }

                final field = controller.subFields[index - 1];

                return _subFieldChip(
                  title: field.name,
                  iconUrl: field.iconUrl,
                  isSelected: selectedSubId == field.id,
                  onTap: () => controller.selectSubField(field.id),
                );
              },
            ),
          ),

          const SizedBox(height: 10),
        ],
      );
    });
  }

  Widget _subFieldChip({
    required String title,
    required String iconUrl,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDEE8F8) : AppColor.kwhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColor.kblue : Colors.grey.shade100,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _icon(iconUrl, isSelected),
            const SizedBox(width: 7),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColor.kblue : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _icon(String iconUrl, bool isSelected) {
    if (iconUrl.isEmpty) {
      return Icon(Icons.work_outline_rounded, size: 26, color: AppColor.kblue);
    }

    return SizedBox(
      width: 32,
      height: 38,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: CachedNetworkImage(
          imageUrl: iconUrl,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) =>
              Icon(Icons.work_outline_rounded, size: 26, color: AppColor.kblue),
        ),
      ),
    );
  }
}
