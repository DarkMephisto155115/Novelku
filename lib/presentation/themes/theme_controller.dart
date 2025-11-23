import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();
  late final Rx<ThemeMode> _themeMode;
  
  ThemeMode get themeMode => _themeMode.value;
  bool get isDarkMode => _themeMode.value == ThemeMode.dark;
  
  // Constructor dengan initial theme
  ThemeController({ThemeMode initialTheme = ThemeMode.light}) {
    _themeMode = initialTheme.obs;
  }

  @override
  void onInit() {
    super.onInit();
    print('ThemeController onInit - current theme: ${_themeMode.value}');
  }

  Future<void> _saveThemeToPrefs(String theme) async {
    try {
      final prefs = Get.find<SharedPreferences>();
      await prefs.setString('theme', theme);
      print('✅ Theme saved to prefs: $theme');
    } catch (e) {
      print('❌ Error saving theme: $e');
    }
  }

  void toggleTheme() {
    if (_themeMode.value == ThemeMode.light) {
      _themeMode.value = ThemeMode.dark;
      _saveThemeToPrefs('dark');
    } else {
      _themeMode.value = ThemeMode.light;
      _saveThemeToPrefs('light');
    }
    Get.changeThemeMode(_themeMode.value);
    print('Theme toggled to: ${_themeMode.value}');
  }

  void setTheme(ThemeMode mode) {
    _themeMode.value = mode;
    _saveThemeToPrefs(mode == ThemeMode.dark ? 'dark' : 'light');
    Get.changeThemeMode(_themeMode.value);
  }
}