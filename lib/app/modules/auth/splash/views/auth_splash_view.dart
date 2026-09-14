import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import '../../../../../core/utils/app_assets.dart';

import '../controllers/auth_splash_controller.dart';

class AuthSplashView extends GetView<AuthSplashController> {
  const AuthSplashView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 500,
            bottom: 0,
            left: -155,
            child: SvgPicture.asset(Assets.imagesObjects, width: 450.0),
          ),
          Center(child: Image.asset(Assets.imagesLogo, width: 500.0)),
        ],
      ),
    );
  }
}
