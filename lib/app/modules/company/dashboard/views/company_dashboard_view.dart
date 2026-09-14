import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/app_color.dart';
import '../../../../routes/app_pages.dart';
import '../../application_list/controllers/application_list_controller.dart';
import '../../company_main_wrapper/controllers/company_main_wrapper_controller.dart';
import '../controllers/company_dashboard_controller.dart';

class CompanyDashboardView extends GetView<CompanyDashboardController> {
  const CompanyDashboardView({super.key});

  void _goToPostedJobs() {
    if (Get.isRegistered<ApplicationListController>()) {
      Get.find<ApplicationListController>().switchTab('jobs');
    }

    if (Get.isRegistered<CompanyMainWrapperController>()) {
      Get.find<CompanyMainWrapperController>().changePage(0);
    }
  }

  void _goToApplicants() {
    if (Get.isRegistered<ApplicationListController>()) {
      Get.find<ApplicationListController>().switchTab('applications');
    }

    if (Get.isRegistered<CompanyMainWrapperController>()) {
      Get.find<CompanyMainWrapperController>().changePage(0);
    }
  }

  void _goToPostJob() {
    if (Get.isRegistered<CompanyMainWrapperController>()) {
      Get.find<CompanyMainWrapperController>().goToPostJob();
    }
  }

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
          'Dashboard',
          style: TextStyle(
            color: AppColor.kwhite,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Obx(
            () => Badge(
              isLabelVisible: controller.unreadCount > 0,
              label: Text('${controller.unreadCount}'),
              textStyle: const TextStyle(color: Colors.white, fontSize: 10),
              textColor: Colors.white,
              backgroundColor: Colors.red,
              smallSize: 18,
              child: GestureDetector(
                onTap: () => Get.toNamed(Routes.companyNotifications),
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: AppColor.kwhite,
                  size: 26,
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: AppColor.kblue),
          );
        }

        return RefreshIndicator(
          color: AppColor.kblue,
          onRefresh: controller.refreshDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _welcomeCard(),
                const SizedBox(height: 16),
                _quickActions(),
                const SizedBox(height: 18),
                _buildJobsOverviewCard(),
                const SizedBox(height: 22),
                _sectionHeader(
                  title: 'Recent Posted Jobs',
                  onMoreTap: _goToPostedJobs,
                ),
                const SizedBox(height: 12),
                _buildRecentJobs(),
                const SizedBox(height: 22),
                _sectionHeader(
                  title: 'Recent Applicants',
                  onMoreTap: _goToApplicants,
                ),
                const SizedBox(height: 12),
                _buildRecentApplicants(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _welcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: AppColor.kblue,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColor.kblue.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColor.kwhite.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.business_center_rounded,
              color: AppColor.kwhite,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage Your Jobs',
                  style: TextStyle(
                    color: AppColor.kwhite,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Track posted jobs, applicants, and hiring activity.',
                  style: TextStyle(
                    color: AppColor.kwhite.withValues(alpha: 0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActions() {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            icon: Icons.add_rounded,
            title: 'Post a Job',
            onTap: _goToPostJob,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionButton(
            icon: Icons.list_alt_rounded,
            title: 'My Jobs',
            onTap: _goToPostedJobs,
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 14),
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
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColor.kblue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColor.kblue, size: 21),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColor.kblack,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobsOverviewCard() {
    final total = controller.totalJobs.value;
    final open = controller.openJobs.value;

    final openPercent = total == 0 ? 0.75 : open / total;
    final closedPercent = total == 0 ? 0.25 : 1.0 - openPercent;

    final openText = '${(openPercent * 100).round()}%';
    final closedText = '${(closedPercent * 100).round()}%';

    return Container(
      width: double.infinity,
      height: 185,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        color: AppColor.kwhite,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColor.kblack.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 24,
            child: Text(
              'Jobs Overview',
              style: TextStyle(
                color: AppColor.kblack,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 28,
                  right: 28,
                  top: -6,
                  child: SizedBox(
                    height: 110,
                    child: CustomPaint(
                      painter: _CompanyHalfChartPainter(
                        percent: openPercent,
                        blueColor: AppColor.kblue,
                        lightColor: const Color(0xffC9D8F0),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 42,
                  bottom: 0,
                  child: _chartLegend(
                    color: AppColor.kblue,
                    percent: openText,
                    label: 'Open',
                  ),
                ),
                Positioned(
                  right: 36,
                  bottom: 0,
                  child: _chartLegend(
                    color: const Color(0xffC9D8F0),
                    percent: closedText,
                    label: 'Closed',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartLegend({
    required Color color,
    required String percent,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 17,
          height: 17,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              percent,
              style: TextStyle(
                color: AppColor.kblack,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: AppColor.greyLight,
                fontSize: 9.5,
                fontWeight: FontWeight.w500,
                height: 1.1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sectionHeader({
    required String title,
    required VoidCallback onMoreTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColor.kblack,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        GestureDetector(
          onTap: onMoreTap,
          child: Text(
            'More',
            style: TextStyle(
              color: AppColor.kblue,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentJobs() {
    if (controller.recentJobs.isEmpty) {
      return _emptyCard(
        icon: Icons.work_outline_rounded,
        title: 'No posted jobs yet',
        subtitle: 'Your latest posted jobs will appear here.',
      );
    }

    return Column(
      children: controller.recentJobs.map((job) {
        return _recentJobCard(job);
      }).toList(),
    );
  }

  Widget _recentJobCard(CompanyRecentJob job) {
    final isOpen = job.status.toLowerCase() == 'open';

    return Container(
      height: 72,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
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
      child: Row(
        children: [
          _recentJobFieldLogo(job),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  job.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColor.kblack,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: AppColor.kblue,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        job.location.isEmpty ? 'No location' : job.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColor.greyLight,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.groups_outlined,
                      color: AppColor.kblue,
                      size: 12,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${job.applicantCount}',
                      style: TextStyle(
                        color: AppColor.greyLight,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: isOpen ? const Color(0xffE8F7EE) : const Color(0xffF1F1F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              job.status,
              style: TextStyle(
                color: isOpen ? const Color(0xff1E9E55) : AppColor.greyLight,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentJobFieldLogo(CompanyRecentJob job) {
    final iconUrl = job.subFieldIconUrl.isNotEmpty
        ? job.subFieldIconUrl
        : job.mainFieldIconUrl;

    return Container(
      width: 46,
      height: 46,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: AppColor.kblue.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: iconUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: iconUrl,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) {
                  return Icon(
                    Icons.work_outline_rounded,
                    color: AppColor.kblue,
                    size: 24,
                  );
                },
              )
            : Icon(Icons.work_outline_rounded, color: AppColor.kblue, size: 24),
      ),
    );
  }

  Widget _buildRecentApplicants() {
    if (controller.recentApplicants.isEmpty) {
      return _emptyCard(
        icon: Icons.groups_outlined,
        title: 'No applicants yet',
        subtitle: 'New applicants will appear here.',
      );
    }

    return Column(
      children: controller.recentApplicants.map((applicant) {
        return _applicantCard(applicant);
      }).toList(),
    );
  }

  Widget _applicantCard(CompanyRecentApplicant applicant) {
    return Container(
      height: 72,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
      child: Row(
        children: [
          _avatar(applicant.imageUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    applicant.applicantName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColor.kblack,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.work_outline_rounded,
                        color: AppColor.kblue,
                        size: 11,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          applicant.jobTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColor.greyLight,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w500,
                            height: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: AppColor.kblue,
                        size: 11,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          applicant.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColor.greyLight,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w400,
                            height: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 42,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  controller.formatDate(applicant.createdAt),
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: AppColor.greyLight,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColor.greyLight,
                  size: 13,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: const Color(0xffDEE8F8),
          borderRadius: BorderRadius.circular(27),
        ),
        child: Icon(Icons.person_rounded, color: AppColor.kblue, size: 29),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(27),
      child: Image.network(
        imageUrl,
        width: 54,
        height: 54,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xffDEE8F8),
              borderRadius: BorderRadius.circular(27),
            ),
            child: Icon(Icons.person_rounded, color: AppColor.kblue, size: 29),
          );
        },
      ),
    );
  }

  Widget _emptyCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
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
        children: [
          Icon(icon, color: AppColor.kblue, size: 30),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: AppColor.kblack,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColor.greyLight,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyHalfChartPainter extends CustomPainter {
  final double percent;
  final Color blueColor;
  final Color lightColor;

  _CompanyHalfChartPainter({
    required this.percent,
    required this.blueColor,
    required this.lightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 8);
    final radius = size.width * 0.34;
    const strokeWidth = 25.0;

    final rect = Rect.fromCircle(center: center, radius: radius);

    final lightPaint = Paint()
      ..color = lightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final bluePaint = Paint()
      ..color = blueColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    const startAngle = math.pi;
    const totalSweep = math.pi;

    final safePercent = percent.clamp(0.0, 1.0);
    final blueSweep = totalSweep * safePercent;

    canvas.drawArc(rect, startAngle, totalSweep, false, lightPaint);

    canvas.drawArc(rect, startAngle, blueSweep, false, bluePaint);

    final dotAngle = startAngle + blueSweep;
    final dotOffset = Offset(
      center.dx + radius * math.cos(dotAngle),
      center.dy + radius * math.sin(dotAngle),
    );

    final dotPaint = Paint()
      ..color = blueColor
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(dotOffset, 12, dotPaint);
    canvas.drawCircle(dotOffset, 12, dotBorderPaint);
  }

  @override
  bool shouldRepaint(covariant _CompanyHalfChartPainter oldDelegate) {
    return oldDelegate.percent != percent ||
        oldDelegate.blueColor != blueColor ||
        oldDelegate.lightColor != lightColor;
  }
}
// import 'dart:math' as math;

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../../../../core/utils/app_color.dart';
// import '../../../../routes/app_pages.dart';
// import '../../application_list/controllers/application_list_controller.dart';
// import '../../company_main_wrapper/controllers/company_main_wrapper_controller.dart';
// import '../controllers/company_dashboard_controller.dart';

// class CompanyDashboardView extends GetView<CompanyDashboardController> {
//   const CompanyDashboardView({super.key});

//   void _goToPostedJobs() {
//     if (Get.isRegistered<ApplicationListController>()) {
//       Get.find<ApplicationListController>().switchTab('jobs');
//     }

//     if (Get.isRegistered<CompanyMainWrapperController>()) {
//       Get.find<CompanyMainWrapperController>().changePage(0);
//     }
//   }

//   void _goToApplicants() {
//     if (Get.isRegistered<ApplicationListController>()) {
//       Get.find<ApplicationListController>().switchTab('applications');
//     }

//     if (Get.isRegistered<CompanyMainWrapperController>()) {
//       Get.find<CompanyMainWrapperController>().changePage(0);
//     }
//   }

//   void _goToPostJob() {
//     if (Get.isRegistered<CompanyMainWrapperController>()) {
//       Get.find<CompanyMainWrapperController>().goToPostJob();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xffF5F7FA),
//       appBar: AppBar(
//         backgroundColor: AppColor.kblue,
//         elevation: 0,
//         centerTitle: true,
//         automaticallyImplyLeading: false,
//         title: Text(
//           'Dashboard',
//           style: TextStyle(
//             color: AppColor.kwhite,
//             fontSize: 18,
//             fontWeight: FontWeight.w800,
//           ),
//         ),
//         actions: [
//           Obx(
//             () => Badge(
//               isLabelVisible: controller.unreadCount > 0,
//               label: Text('${controller.unreadCount}'),
//               textStyle: const TextStyle(color: Colors.white, fontSize: 10),
//               textColor: Colors.white,
//               backgroundColor: Colors.red,
//               smallSize: 18,
//               child: GestureDetector(
//                 onTap: () => Get.toNamed(Routes.companyNotifications),
//                 child: Icon(
//                   Icons.notifications_none_rounded,
//                   color: AppColor.kwhite,
//                   size: 26,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 18),
//         ],
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return Center(
//             child: CircularProgressIndicator(color: AppColor.kblue),
//           );
//         }

//         return RefreshIndicator(
//           color: AppColor.kblue,
//           onRefresh: controller.refreshDashboard,
//           child: SingleChildScrollView(
//             physics: const AlwaysScrollableScrollPhysics(),
//             padding: const EdgeInsets.fromLTRB(16, 18, 16, 110),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _welcomeCard(),
//                 const SizedBox(height: 16),
//                 _quickActions(),
//                 const SizedBox(height: 18),
//                 _buildJobsOverviewCard(),
//                 const SizedBox(height: 22),
//                 _sectionHeader(
//                   title: 'Recent Posted Jobs',
//                   onMoreTap: _goToPostedJobs,
//                 ),
//                 const SizedBox(height: 12),
//                 _buildRecentJobs(),
//                 const SizedBox(height: 22),
//                 _sectionHeader(
//                   title: 'Recent Applicants',
//                   onMoreTap: _goToApplicants,
//                 ),
//                 const SizedBox(height: 12),
//                 _buildRecentApplicants(),
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }

//   Widget _welcomeCard() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
//       decoration: BoxDecoration(
//         color: AppColor.kblue,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: AppColor.kblue.withValues(alpha: 0.18),
//             blurRadius: 16,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 52,
//             height: 52,
//             decoration: BoxDecoration(
//               color: AppColor.kwhite.withValues(alpha: 0.14),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.business_center_rounded,
//               color: AppColor.kwhite,
//               size: 28,
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Manage Your Jobs',
//                   style: TextStyle(
//                     color: AppColor.kwhite,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 Text(
//                   'Track posted jobs, applicants, and hiring activity.',
//                   style: TextStyle(
//                     color: AppColor.kwhite.withValues(alpha: 0.85),
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                     height: 1.3,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _quickActions() {
//     return Row(
//       children: [
//         Expanded(
//           child: _actionButton(
//             icon: Icons.add_rounded,
//             title: 'Post a Job',
//             onTap: _goToPostJob,
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: _actionButton(
//             icon: Icons.list_alt_rounded,
//             title: 'My Jobs',
//             onTap: _goToPostedJobs,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _actionButton({
//     required IconData icon,
//     required String title,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 58,
//         padding: const EdgeInsets.symmetric(horizontal: 14),
//         decoration: BoxDecoration(
//           color: AppColor.kwhite,
//           borderRadius: BorderRadius.circular(10),
//           boxShadow: [
//             BoxShadow(
//               color: AppColor.kblack.withValues(alpha: 0.06),
//               blurRadius: 12,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 34,
//               height: 34,
//               decoration: BoxDecoration(
//                 color: AppColor.kblue.withValues(alpha: 0.08),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(icon, color: AppColor.kblue, size: 21),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Text(
//                 title,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   color: AppColor.kblack,
//                   fontSize: 13,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildJobsOverviewCard() {
//     final total = controller.totalJobs.value;
//     final open = controller.openJobs.value;

//     final openPercent = total == 0 ? 0.75 : open / total;
//     final closedPercent = total == 0 ? 0.25 : 1.0 - openPercent;

//     final openText = '${(openPercent * 100).round()}%';
//     final closedText = '${(closedPercent * 100).round()}%';

//     return Container(
//       width: double.infinity,
//       height: 185,
//       padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
//       decoration: BoxDecoration(
//         color: AppColor.kwhite,
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: [
//           BoxShadow(
//             color: AppColor.kblack.withValues(alpha: 0.08),
//             blurRadius: 12,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             height: 24,
//             child: Text(
//               'Jobs Overview',
//               style: TextStyle(
//                 color: AppColor.kblack,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w800,
//                 height: 1,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 Positioned(
//                   left: 28,
//                   right: 28,
//                   top: -6,
//                   child: SizedBox(
//                     height: 110,
//                     child: CustomPaint(
//                       painter: _CompanyHalfChartPainter(
//                         percent: openPercent,
//                         blueColor: AppColor.kblue,
//                         lightColor: const Color(0xffC9D8F0),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   left: 42,
//                   bottom: 0,
//                   child: _chartLegend(
//                     color: AppColor.kblue,
//                     percent: openText,
//                     label: 'Open',
//                   ),
//                 ),
//                 Positioned(
//                   right: 36,
//                   bottom: 0,
//                   child: _chartLegend(
//                     color: const Color(0xffC9D8F0),
//                     percent: closedText,
//                     label: 'Closed',
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _chartLegend({
//     required Color color,
//     required String percent,
//     required String label,
//   }) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           width: 17,
//           height: 17,
//           decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//         ),
//         const SizedBox(width: 5),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               percent,
//               style: TextStyle(
//                 color: AppColor.kblack,
//                 fontSize: 11,
//                 fontWeight: FontWeight.w700,
//                 height: 1,
//               ),
//             ),
//             Text(
//               label,
//               style: TextStyle(
//                 color: AppColor.greyLight,
//                 fontSize: 9.5,
//                 fontWeight: FontWeight.w500,
//                 height: 1.1,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _sectionHeader({
//     required String title,
//     required VoidCallback onMoreTap,
//   }) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           title,
//           style: TextStyle(
//             color: AppColor.kblack,
//             fontSize: 18,
//             fontWeight: FontWeight.w800,
//           ),
//         ),
//         GestureDetector(
//           onTap: onMoreTap,
//           child: Text(
//             'More',
//             style: TextStyle(
//               color: AppColor.kblue,
//               fontSize: 13,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildRecentJobs() {
//     if (controller.recentJobs.isEmpty) {
//       return _emptyCard(
//         icon: Icons.work_outline_rounded,
//         title: 'No posted jobs yet',
//         subtitle: 'Your latest posted jobs will appear here.',
//       );
//     }

//     return Column(
//       children: controller.recentJobs.map((job) {
//         return _recentJobCard(job);
//       }).toList(),
//     );
//   }

//   Widget _recentJobCard(CompanyRecentJob job) {
//     final isOpen = job.status.toLowerCase() == 'open';

//     return Container(
//       height: 72,
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
//       decoration: BoxDecoration(
//         color: AppColor.kwhite,
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: [
//           BoxShadow(
//             color: AppColor.kblack.withValues(alpha: 0.06),
//             blurRadius: 12,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 46,
//             height: 46,
//             decoration: BoxDecoration(
//               color: AppColor.kblue.withValues(alpha: 0.08),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.work_outline_rounded,
//               color: AppColor.kblue,
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   job.title,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: AppColor.kblack,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.location_on_outlined,
//                       color: AppColor.kblue,
//                       size: 12,
//                     ),
//                     const SizedBox(width: 4),
//                     Expanded(
//                       child: Text(
//                         job.location.isEmpty ? 'No location' : job.location,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           color: AppColor.greyLight,
//                           fontSize: 10,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Icon(
//                       Icons.groups_outlined,
//                       color: AppColor.kblue,
//                       size: 12,
//                     ),
//                     const SizedBox(width: 3),
//                     Text(
//                       '${job.applicantCount}',
//                       style: TextStyle(
//                         color: AppColor.greyLight,
//                         fontSize: 10,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 8),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
//             decoration: BoxDecoration(
//               color: isOpen ? const Color(0xffE8F7EE) : const Color(0xffF1F1F1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               job.status,
//               style: TextStyle(
//                 color: isOpen ? const Color(0xff1E9E55) : AppColor.greyLight,
//                 fontSize: 10,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRecentApplicants() {
//     if (controller.recentApplicants.isEmpty) {
//       return _emptyCard(
//         icon: Icons.groups_outlined,
//         title: 'No applicants yet',
//         subtitle: 'New applicants will appear here.',
//       );
//     }

//     return Column(
//       children: controller.recentApplicants.map((applicant) {
//         return _applicantCard(applicant);
//       }).toList(),
//     );
//   }

//   Widget _applicantCard(CompanyRecentApplicant applicant) {
//     return Container(
//       height: 72,
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: AppColor.kwhite,
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: [
//           BoxShadow(
//             color: AppColor.kblack.withValues(alpha: 0.06),
//             blurRadius: 12,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           _avatar(applicant.imageUrl),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.only(top: 3),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     applicant.applicantName,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       color: AppColor.kblack,
//                       fontSize: 14,
//                       fontWeight: FontWeight.w800,
//                       height: 1.1,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.work_outline_rounded,
//                         color: AppColor.kblue,
//                         size: 11,
//                       ),
//                       const SizedBox(width: 4),
//                       Expanded(
//                         child: Text(
//                           applicant.jobTitle,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             color: AppColor.greyLight,
//                             fontSize: 9.5,
//                             fontWeight: FontWeight.w500,
//                             height: 1,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.location_on_outlined,
//                         color: AppColor.kblue,
//                         size: 11,
//                       ),
//                       const SizedBox(width: 4),
//                       Expanded(
//                         child: Text(
//                           applicant.location,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             color: AppColor.greyLight,
//                             fontSize: 9.5,
//                             fontWeight: FontWeight.w400,
//                             height: 1,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(width: 6),
//           SizedBox(
//             width: 42,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   controller.formatDate(applicant.createdAt),
//                   textAlign: TextAlign.end,
//                   style: TextStyle(
//                     color: AppColor.greyLight,
//                     fontSize: 9.5,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const Spacer(),
//                 Icon(
//                   Icons.arrow_forward_ios_rounded,
//                   color: AppColor.greyLight,
//                   size: 13,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _avatar(String imageUrl) {
//     if (imageUrl.isEmpty) {
//       return Container(
//         width: 54,
//         height: 54,
//         decoration: BoxDecoration(
//           color: const Color(0xffDEE8F8),
//           borderRadius: BorderRadius.circular(27),
//         ),
//         child: Icon(Icons.person_rounded, color: AppColor.kblue, size: 29),
//       );
//     }

//     return ClipRRect(
//       borderRadius: BorderRadius.circular(27),
//       child: Image.network(
//         imageUrl,
//         width: 54,
//         height: 54,
//         fit: BoxFit.cover,
//         errorBuilder: (context, error, stackTrace) {
//           return Container(
//             width: 54,
//             height: 54,
//             decoration: BoxDecoration(
//               color: const Color(0xffDEE8F8),
//               borderRadius: BorderRadius.circular(27),
//             ),
//             child: Icon(Icons.person_rounded, color: AppColor.kblue, size: 29),
//           );
//         },
//       ),
//     );
//   }

//   Widget _emptyCard({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//   }) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
//       decoration: BoxDecoration(
//         color: AppColor.kwhite,
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: [
//           BoxShadow(
//             color: AppColor.kblack.withValues(alpha: 0.06),
//             blurRadius: 12,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: AppColor.kblue, size: 30),
//           const SizedBox(height: 10),
//           Text(
//             title,
//             style: TextStyle(
//               color: AppColor.kblack,
//               fontSize: 14,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             subtitle,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: AppColor.greyLight,
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _CompanyHalfChartPainter extends CustomPainter {
//   final double percent;
//   final Color blueColor;
//   final Color lightColor;

//   _CompanyHalfChartPainter({
//     required this.percent,
//     required this.blueColor,
//     required this.lightColor,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height - 8);
//     final radius = size.width * 0.34;
//     const strokeWidth = 25.0;

//     final rect = Rect.fromCircle(center: center, radius: radius);

//     final lightPaint = Paint()
//       ..color = lightColor
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = strokeWidth
//       ..strokeCap = StrokeCap.butt;

//     final bluePaint = Paint()
//       ..color = blueColor
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = strokeWidth
//       ..strokeCap = StrokeCap.butt;

//     const startAngle = math.pi;
//     const totalSweep = math.pi;

//     final safePercent = percent.clamp(0.0, 1.0);
//     final blueSweep = totalSweep * safePercent;

//     canvas.drawArc(rect, startAngle, totalSweep, false, lightPaint);

//     canvas.drawArc(rect, startAngle, blueSweep, false, bluePaint);

//     final dotAngle = startAngle + blueSweep;
//     final dotOffset = Offset(
//       center.dx + radius * math.cos(dotAngle),
//       center.dy + radius * math.sin(dotAngle),
//     );

//     final dotPaint = Paint()
//       ..color = blueColor
//       ..style = PaintingStyle.fill;

//     final dotBorderPaint = Paint()
//       ..color = Colors.white
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 4;

//     canvas.drawCircle(dotOffset, 12, dotPaint);
//     canvas.drawCircle(dotOffset, 12, dotBorderPaint);
//   }

//   @override
//   bool shouldRepaint(covariant _CompanyHalfChartPainter oldDelegate) {
//     return oldDelegate.percent != percent ||
//         oldDelegate.blueColor != blueColor ||
//         oldDelegate.lightColor != lightColor;
//   }
// }
