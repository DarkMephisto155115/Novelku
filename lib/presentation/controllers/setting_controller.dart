import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terra_brain/presentation/routes/app_pages.dart';
import 'package:terra_brain/presentation/themes/theme_controller.dart';
import 'package:terra_brain/presentation/models/reading_model.dart'
    as reading_model;
import '../models/settings_model.dart';
import 'reading_controller.dart';

class SettingsController extends GetxController {
  final Rx<ReadingSettings> settings = ReadingSettings(
    // isDarkMode: false,
    fontSize: 'Sedang',
    fontFamily: 'Arial',
    novelNotifications: true,
    autoScroll: false,
  ).obs;

  final List<String> fontSizes = ['Kecil', 'Sedang', 'Besar', 'Sangat Besar'];
  final List<String> fontFamilies = ['Arial', 'Georgia', 'Pangolin'];
  final RxBool draftDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    final themeController = Get.find<ThemeController>();
    draftDarkMode.value = themeController.isDarkMode;
  }

  Future<void> _loadSettings() async {
      final prefs = Get.find<SharedPreferences>();
      settings.value = ReadingSettings(
        fontSize: prefs.getString('fontSize') ?? 'Sedang',
        fontFamily: prefs.getString('fontFamily') ?? 'Arial',
        novelNotifications: prefs.getBool('novelNotifications') ?? true,
        autoScroll: prefs.getBool('autoScroll') ?? false,
      );
  }

  Future<void> _saveSettings() async {
      final prefs = Get.find<SharedPreferences>();
      await prefs.setString('fontSize', settings.value.fontSize);
      await prefs.setString('fontFamily', settings.value.fontFamily);
      await prefs.setBool(
          'novelNotifications', settings.value.novelNotifications);
      await prefs.setBool('autoScroll', settings.value.autoScroll);
  }

  void toggleDarkMode(bool value) {
    draftDarkMode.value = value;
  }

  void setFontSize(String size) {
    settings.value = settings.value.copyWith(fontSize: size);
  }

  void setFontFamily(String font) {
    settings.value = settings.value.copyWith(fontFamily: font);
  }

  void toggleNovelNotifications(bool value) {
    settings.value = settings.value.copyWith(novelNotifications: value);
  }

  void toggleAutoScroll(bool value) {
    settings.value = settings.value.copyWith(autoScroll: value);
  }

  void saveChanges() async {
    final themeController = Get.find<ThemeController>();
    themeController.setTheme(
      draftDarkMode.value ? ThemeMode.dark : ThemeMode.light,
    );
    _saveSettings();

    _syncReadingTheme();

    Get.snackbar(
      'Berhasil',
      'Pengaturan telah disimpan',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    await Future.delayed(const Duration(milliseconds: 500));

    Get.offAllNamed(AppPages.INITIAL);
  }

  void _syncReadingTheme() {
    try {
      final readingController = Get.find<ReadingController>();
      final newTheme = draftDarkMode.value
          ? reading_model.ReadingTheme.dark
          : reading_model.ReadingTheme.light;
      readingController.updateTheme(newTheme);
    } catch (e) {
      if (kDebugMode) print('Reading controller not initialized: $e');
    }
  }

  // Helper methods for live preview
  double get fontSizeValue {
    switch (settings.value.fontSize) {
      case 'Kecil':
        return 14.0;
      case 'Sedang':
        return 16.0;
      case 'Besar':
        return 18.0;
      case 'Sangat Besar':
        return 20.0;
      default:
        return 16.0;
    }
  }

  String get fontFamilyValue {
    return settings.value.fontFamily;
  }
}
