import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../themes/theme_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() async {
    final prefs = await SharedPreferences.getInstance();
    Get.put(prefs, permanent: true);

    final savedTheme = prefs.getString('theme') ?? 'light';
    Get.put(
      ThemeController(initialTheme: savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light),
      permanent: true,
    );
  }
}
