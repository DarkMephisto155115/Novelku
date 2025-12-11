import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terra_brain/presentation/controllers/premium_controller.dart';
import 'package:terra_brain/presentation/themes/theme_data.dart';
import '../../routes/app_pages.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});

  final PremiumController premiumController = Get.find<PremiumController>();

  Future<void> checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      // await Future.delayed(const Duration(seconds: 1));
      Get.offAllNamed(Routes.HOME);
    } else {
      await Future.delayed(const Duration(seconds: 4));
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  @override
  Widget build(BuildContext context) {
    checkLoginStatus();
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppThemeData.primaryColor, AppThemeData.pinkColor],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    "Selamat Datang di Novelku",
                    textStyle: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    speed: const Duration(milliseconds: 100),
                  ),
                ],
              ),
              Image.asset(
                'assets/icons/novelku_logo.png',
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
