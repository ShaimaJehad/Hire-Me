import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/app_color.dart';
import '../../../../../core/utils/app_text_style.dart';
import '../controllers/job_seeker_notifications_controller.dart';
import '../models/notification_model.dart';

class JobSeekerNotificationsView
    extends GetView<JobSeekerNotificationsController> {
  const JobSeekerNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        backgroundColor: AppColor.kblue,
        foregroundColor: AppColor.kwhite,
        title: Text(
          'Notifications',
          style: CustomTextstyle.poppinsSemiBoldWhite,
        ),
        elevation: 0,
        actions: [
          Obx(
            () => controller.unreadCount > 0
                ? TextButton(
                    onPressed: controller.markAllAsRead,
                    child: Text(
                      'Mark all as read',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.notifications.isEmpty) {
          return _buildEmptyState();
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final notification = controller.notifications[index];
            return _NotificationTile(
              notification: notification,
              onTap: () => controller.markAsRead(notification.id),
            );
          },
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: AppColor.greyLight,
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: CustomTextstyle.poppins500Grey.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll notify you when something arrives',
            style: CustomTextstyle.poppins500Grey.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: notification.isRead
              ? AppColor.kwhite
              : const Color(0xFFEEF3FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIcon(),
              const SizedBox(width: 12),
              Expanded(child: _buildContent()),
              if (!notification.isRead) _buildUnreadDot(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _iconColor().withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(_mapIcon(notification.icon), color: _iconColor(), size: 22),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          notification.title,
          style: CustomTextstyle.poppinsSemiBold500.copyWith(
            fontSize: 14,
            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          notification.body,
          style: CustomTextstyle.poppins500Grey.copyWith(fontSize: 12),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          _formatTime(notification.timestamp),
          style: CustomTextstyle.poppins500Grey.copyWith(fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildUnreadDot() {
    return Container(
      margin: const EdgeInsets.only(left: 8, top: 6),
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: AppColor.kblue, shape: BoxShape.circle),
    );
  }

  Color _iconColor() {
    switch (notification.icon) {
      case 'check_circle':
        return AppColor.kblue;
      case 'work':
        return const Color(0xFFF16E12);
      case 'message':
        return AppColor.kblue;
      case 'visibility':
        return const Color(0xFF388E3C);
      case 'person':
        return const Color(0xFF7B1FA2);
      default:
        return AppColor.kblue;
    }
  }

  IconData _mapIcon(String icon) {
    switch (icon) {
      case 'check_circle':
        return Icons.check_circle_outline;
      case 'work':
        return Icons.work_outline;
      case 'message':
        return Icons.message_outlined;
      case 'visibility':
        return Icons.visibility_outlined;
      case 'person':
        return Icons.person_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }
}
