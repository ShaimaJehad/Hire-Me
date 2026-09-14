import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hire_me/core/utils/app_color.dart';

import '../../controllers/job_seeker_dashboard_controller.dart';

class MainFieldsWidget extends GetView<JobSeekerDashboardController> {
  const MainFieldsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(25, 4, 25, 15),
          child: Text(
            'Discover jobs by field',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Colors.black.withValues(alpha: 0.82),
            ),
          ),
        ),

        Obx(() {
          if (controller.isMainFieldsLoading.value) {
            return const SizedBox(
              height: 130,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (controller.mainFields.isEmpty) {
            return const SizedBox(
              height: 100,
              child: Center(child: Text('No fields found')),
            );
          }

          final selectedId = controller.selectedMainFieldId.value;

          return SizedBox(
            height: 125,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: controller.mainFields.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _fieldItem(
                    title: 'All',
                    iconUrl: '',
                    isSelected: selectedId == 'all',
                    onTap: () => controller.selectMainField('all'),
                  );
                }

                final field = controller.mainFields[index - 1];

                return _fieldItem(
                  title: field.name,
                  iconUrl: field.iconUrl,
                  isSelected: selectedId == field.id,
                  onTap: () => controller.selectMainField(field.id),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _fieldItem({
    required String title,
    required String iconUrl,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 82,
              height: 72,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFDEE8F8) : AppColor.kwhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColor.kblue : Colors.grey.shade100,
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.035),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: iconUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: iconUrl,
                      fit: BoxFit.contain,
                      errorWidget: (context, url, error) => Icon(
                        Icons.work_outline_rounded,
                        color: AppColor.kblue,
                        size: 30,
                      ),
                    )
                  : Icon(
                      Icons.work_outline_rounded,
                      color: AppColor.kblue,
                      size: 30,
                    ),
            ),

            const SizedBox(height: 9),

            SizedBox(
              width: 88,
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColor.kblue : Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
