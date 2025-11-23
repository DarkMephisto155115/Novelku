import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terra_brain/firebase_options.dart';
import 'package:terra_brain/presentation/app.dart';
import 'package:terra_brain/presentation/service/notif_handler.dart';
import 'package:terra_brain/presentation/themes/theme_controller.dart';

void main() async {
  print("start app");
  log("message");
  WidgetsFlutterBinding.ensureInitialized();

  print("shared preference");
  // await Get.putAsync(() => SharedPreferences.getInstance());

  await Get.putAsync<SharedPreferences>(
      () async => await SharedPreferences.getInstance());

  await Get.putAsync<ThemeController>(() async {
    final prefs = Get.find<SharedPreferences>();
    final savedTheme = prefs.getString('theme') ?? 'light';
    return ThemeController(
        initialTheme: savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light);
  });

  print("firebase init");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // print("put theme controller");
  // Get.put<ThemeController>(ThemeController(), permanent: true);

  await Future.delayed(Duration(milliseconds: 100));

  await NotificationHandler().initialize();

  runApp(const MyApp());
}
