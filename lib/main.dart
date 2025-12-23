import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terra_brain/firebase_options.dart';
import 'package:terra_brain/presentation/app.dart';
import 'package:terra_brain/presentation/service/notif_handler.dart';
import 'package:terra_brain/presentation/themes/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  Get.put<SharedPreferences>(prefs);

  final String? savedTheme = prefs.getString('theme');
  ThemeMode initialTheme = ThemeMode.light;
  
  if (savedTheme == 'dark') {
    initialTheme = ThemeMode.dark;
  } else if (savedTheme == 'light') {
    initialTheme = ThemeMode.light;
  }

  Get.put<ThemeController>(
    ThemeController(initialTheme: initialTheme),
    permanent: true,
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // await NotificationHandler().initialize();

  runApp(const MyApp());
}