import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terra_brain/presentation/themes/theme_controller.dart';
import '../models/settings_model.dart';

class SettingsController extends GetxController {
  final Rx<ReadingSettings> settings = ReadingSettings(
    isDarkMode: false,
    fontSize: 'Sedang',
    fontFamily: 'Arial',
    novelNotifications: true,
    autoScroll: false,
  ).obs;

  final List<String> fontSizes = ['Kecil', 'Sedang', 'Besar', 'Sangat Besar'];
  final List<String> fontFamilies = ['Arial', 'Georgia', 'Pangolin'];

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = Get.find<SharedPreferences>();
      settings.value = ReadingSettings(
        isDarkMode: prefs.getBool('isDarkMode') ?? false,
        fontSize: prefs.getString('fontSize') ?? 'Sedang',
        fontFamily: prefs.getString('fontFamily') ?? 'Arial',
        novelNotifications: prefs.getBool('novelNotifications') ?? true,
        autoScroll: prefs.getBool('autoScroll') ?? false,
      );
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = Get.find<SharedPreferences>();
      await prefs.setBool('isDarkMode', settings.value.isDarkMode);
      await prefs.setString('fontSize', settings.value.fontSize);
      await prefs.setString('fontFamily', settings.value.fontFamily);
      await prefs.setBool('novelNotifications', settings.value.novelNotifications);
      await prefs.setBool('autoScroll', settings.value.autoScroll);
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  void toggleDarkMode(bool value) {
    settings.value = settings.value.copyWith(isDarkMode: value);
    // Apply theme change immediately
    Get.find<ThemeController>().setTheme(value ? ThemeMode.dark : ThemeMode.light);
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

  void saveChanges() {
    _saveSettings();
    Get.snackbar(
      'Berhasil',
      'Pengaturan telah disimpan',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
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