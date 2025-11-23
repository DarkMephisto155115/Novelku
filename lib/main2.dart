import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terra_brain/firebase_options.dart';
import 'package:terra_brain/presentation/routes/app_pages.dart';
import 'package:terra_brain/presentation/service/notif_handler.dart';
import 'package:terra_brain/presentation/themes/app_themes.dart';
import 'package:terra_brain/presentation/themes/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print("1. Starting app initialization");
  
  // 1. Initialize SharedPreferences
  print("2. Initializing SharedPreferences");
  final prefs = await SharedPreferences.getInstance();
  Get.put<SharedPreferences>(prefs, permanent: true);
  print("   ✅ SharedPreferences ready");

  // 2. Load theme dari SharedPreferences
  print("3. Loading saved theme");
  final savedTheme = prefs.getString('theme') ?? 'light';
  final initialTheme = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
  print("   ✅ Theme loaded: $savedTheme");

  // 3. Initialize Firebase
  print("4. Initializing Firebase");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("   ✅ Firebase ready");

  // 4. Initialize Notifications
  print("5. Initializing Notifications");
  await NotificationHandler().initialize();
  print("   ✅ Notifications ready");

  // 5. Initialize ThemeController dengan initial theme
  print("6. Initializing ThemeController");
  final themeController = Get.put<ThemeController>(
    ThemeController(initialTheme: initialTheme),
    permanent: true,
  );
  print("   ✅ ThemeController ready");

  print("7. Running app");
  
  // Langsung runApp tanpa MyApp widget
  runApp(
    Obx(() {
      print("Obx rebuilding - current theme: ${themeController.themeMode}");
      return GetMaterialApp(
        title: 'Novelku',
        debugShowCheckedModeBanner: false,
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        themeMode: themeController.themeMode,
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
      );
    }),
  );
}