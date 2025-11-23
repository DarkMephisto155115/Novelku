import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_brain/presentation/bindings/initial_binding.dart';
import 'package:terra_brain/presentation/routes/app_pages.dart';
import 'package:terra_brain/presentation/themes/app_themes.dart';
import 'package:terra_brain/presentation/themes/theme_controller.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print("Building MyApp");
    // final ThemeController themeController = Get.find<ThemeController>();
    // print("ThemeController found with theme: ${themeController.themeMode}");
    
    // ⭐ PENTING: Gunakan Obx agar reactive terhadap perubahan theme
    return Obx(() {
      // print("Obx rebuilding - current theme: ${themeController.themeMode}");
      return GetMaterialApp(
        // initialBinding: InitialBindings(),
        title: 'Novelku',
        debugShowCheckedModeBanner: false,
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        themeMode: ThemeController().themeMode,
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
      );
    });
  }
}