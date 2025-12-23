import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_brain/presentation/routes/app_pages.dart';
import 'package:terra_brain/presentation/themes/app_themes.dart';
import 'package:terra_brain/presentation/themes/theme_controller.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(() {
      return GetMaterialApp(
        title: 'Novelku',
        debugShowCheckedModeBanner: false,
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        themeMode: themeController.themeMode,
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
      );
    });
  }
}