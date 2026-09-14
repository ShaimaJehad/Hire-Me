// lib/app/modules/job_seeker/dashboard/widgets/search_widget.dart
import 'package:flutter/material.dart';
import 'package:hire_me/core/utils/app_color.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onChanged;
  final String hint;

  const SearchBarWidget({
    required this.searchController,
    required this.onChanged,
    this.hint = 'Search',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColor.kblue.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: TextField(
          controller: searchController,
          onChanged: onChanged,
          style: TextStyle(fontSize: 15, color: AppColor.kblack),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColor.greyLight, fontSize: 14),
            prefixIcon: Icon(Icons.search_rounded, color: AppColor.greyLight),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }
}

class SearchFilterWidget extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;

  const SearchFilterWidget({
    super.key,
    required this.searchController,
    required this.onChanged,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColor.kwhite,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.kblue.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                onChanged: onChanged,
                style: TextStyle(fontSize: 15, color: AppColor.kblack),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: AppColor.greyLight, fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, color: AppColor.kblue),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: AppColor.kwhite,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.kblue.withValues(alpha: .08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(Icons.tune_rounded, color: AppColor.kblue),
            ),
          ),
        ],
      ),
    );
  }
}
