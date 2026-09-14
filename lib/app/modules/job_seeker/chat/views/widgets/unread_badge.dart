import 'package:flutter/widgets.dart';

import '../../../../../../core/utils/app_color.dart';

class UnreadBadge extends StatelessWidget {
  final int count;
  const UnreadBadge({required this.count, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(color: AppColor.kblue, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        count.toString(),
        style: const TextStyle(
          color: AppColor.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
