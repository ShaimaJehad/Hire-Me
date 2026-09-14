import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hire_me/core/utils/app_color.dart';

class BottomSheetHandle extends StatelessWidget {
  const BottomSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 45,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class FilterSectionWidget extends StatelessWidget {
  const FilterSectionWidget({
    super.key,
    required this.title,
    required this.items,
    required this.selectedValue,
    required this.onItemTap,
  });

  final String title;
  final List<String> items;
  final String selectedValue;
  final ValueChanged<String> onItemTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w700, color: AppColor.eblack),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: items.map((item) {
            final selected = selectedValue == item;

            return FilterChipWidget(
              label: _formatFilterLabel(item),
              selected: selected,
              onTap: () => onItemTap(item),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatFilterLabel(String value) {
    switch (value) {
      case 'all':
        return 'All';

      case 'FullTime':
        return 'Full Time';

      case 'PartTime':
        return 'Part Time';

      case 'Freelance':
        return 'Freelance';

      case 'OnSite':
        return 'On Site';

      case 'Remote':
        return 'Remote';

      case 'Hybrid':
        return 'Hybrid';

      default:
        return _formatReadableText(value);
    }
  }

  String _formatReadableText(String value) {
    final words = value
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .trim()
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) {
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .toList();

    return words.join(' ');
  }
}

class FilterChipWidget extends StatelessWidget {
  const FilterChipWidget({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColor.kblue : const Color(0xffF5F7FA),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? AppColor.kblue : Colors.grey.shade200,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColor.kwhite : AppColor.greydark,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class FieldFilterSectionWidget extends StatelessWidget {
  const FieldFilterSectionWidget({
    super.key,
    required this.title,
    required this.items,
    required this.selectedValue,
    required this.onAllTap,
    required this.onItemTap,
  });

  final String title;
  final List<dynamic> items;
  final String selectedValue;
  final VoidCallback onAllTap;
  final ValueChanged<String> onItemTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w700, color: AppColor.eblack),
        ),

        const SizedBox(height: 10),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FieldChipWidget(
              label: 'All',
              iconUrl: '',
              selected: selectedValue == 'all',
              onTap: onAllTap,
            ),

            ...items.map((field) {
              final String id = field.id;
              final String name = field.name;
              final String iconUrl = field.iconUrl;

              return FieldChipWidget(
                label: name,
                iconUrl: iconUrl,
                selected: selectedValue == id,
                onTap: () => onItemTap(id),
              );
            }),
          ],
        ),
      ],
    );
  }
}

class FieldChipWidget extends StatelessWidget {
  const FieldChipWidget({
    super.key,
    required this.label,
    required this.iconUrl,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String iconUrl;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColor.kblue : const Color(0xffF5F7FA),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? AppColor.kblue : Colors.grey.shade200,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _icon(),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColor.kwhite : AppColor.greydark,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _icon() {
    if (iconUrl.isEmpty) {
      return Icon(
        Icons.work_outline_rounded,
        size: 16,
        color: selected ? AppColor.kwhite : AppColor.kblue,
      );
    }

    return SizedBox(
      width: 20,
      height: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: CachedNetworkImage(
          imageUrl: iconUrl,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) {
            return Icon(
              Icons.work_outline_rounded,
              size: 16,
              color: selected ? AppColor.kwhite : AppColor.kblue,
            );
          },
        ),
      ),
    );
  }
}
