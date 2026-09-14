import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hire_me/app/routes/app_pages.dart';
import 'package:hire_me/core/utils/app_color.dart';

import '../controllers/jobseekercongratulations_controller.dart';

class JobSeekerCongratulationsView
    extends GetView<JobSeekerCongratulationsController> {
  const JobSeekerCongratulationsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        backgroundColor: AppColor.kblue,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.offAllNamed(
            Routes.mainWrapper,
            arguments: {'initialIndex': 2},
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Apply job',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8EDF9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.celebration_rounded,
                  size: 64,
                  color: AppColor.kblue,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Congratulations',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColor.kblue,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Congratulations, your application\nhas been submitted successfully',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A2E),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: 190,
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Get.offAllNamed(
                    Routes.mainWrapper,
                    arguments: {'initialIndex': 3},
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.kblue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: const Text(
                    'View Applications',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';

// import 'package:get/get.dart';
// import 'package:hire_me/app/routes/app_pages.dart';
// import 'package:hire_me/core/utils/app_color.dart';

// import '../controllers/jobseekercongratulations_controller.dart';

// class JobSeekerCongratulationsView
//     extends GetView<JobSeekerCongratulationsController> {
//   const JobSeekerCongratulationsView({super.key});
//   @override
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FF),
//       appBar: AppBar(
//         backgroundColor: AppColor.kblue,
//         elevation: 0,
//         leading: GestureDetector(
//           onTap: () => Get.offAllNamed(Routes.JOB_SEEKER_DASHBOARD),
//           child: const Icon(Icons.arrow_back, color: Colors.white),
//         ),
//         title: const Text(
//           'Apply job',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             fontSize: 18,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 32),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 width: 120,
//                 height: 120,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFE8EDF9),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   Icons.celebration_rounded,
//                   size: 64,
//                   color: AppColor.kblue,
//                 ),
//               ),

//               const SizedBox(height: 32),

//               Text(
//                 'Congratulations',
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: AppColor.kblue,
//                 ),
//               ),

//               const SizedBox(height: 16),

//               const Text(
//                 'Congratulations, your application\nhas been submitted successfully',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                   color: Color(0xFF1A1A2E),
//                   height: 1.5,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
