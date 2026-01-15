import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();

  late final Rx<ThemeMode> _themeMode;
  ThemeMode get themeMode => _themeMode.value;
  bool get isDarkMode => _themeMode.value == ThemeMode.dark;

  ThemeController() {
    _themeMode = ThemeMode.system.obs;
  }

  @override
  void onInit() {
    super.onInit();

    final prefs = Get.find<SharedPreferences>();
    final savedTheme = prefs.getString('theme');

    if (savedTheme != null) {
      _themeMode.value =
          savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    } else {
      _themeMode.value =
          Get.isDarkMode ? ThemeMode.dark : ThemeMode.light;
    }

    Get.changeThemeMode(_themeMode.value);
    // print('🎨 Active theme: ${_themeMode.value}');
  }

  void toggleTheme() {
    if (_themeMode.value == ThemeMode.dark) {
      setTheme(ThemeMode.light);
    } else {
      setTheme(ThemeMode.dark);
    }
  }

  void setTheme(ThemeMode mode) async {
    _themeMode.value = mode;
    Get.changeThemeMode(mode);

    final prefs = Get.find<SharedPreferences>();
    await prefs.setString(
      'theme',
      mode == ThemeMode.dark ? 'dark' : 'light',
    );

    // print('💾 Theme saved: $mode');
  }
}
