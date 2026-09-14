import 'package:flutter/material.dart';
import '../../../../../../core/utils/app_color.dart';

class SendButton extends StatelessWidget {
  final bool hasText;
  final VoidCallback onTap;
  const SendButton({required this.hasText, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: hasText ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: hasText ? AppColor.kblue : AppColor.divider,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.send_rounded,
          color: hasText ? AppColor.white : AppColor.textSecondary,
          size: 20,
        ),
      ),
    );
  }
}
