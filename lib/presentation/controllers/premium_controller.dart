import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terra_brain/presentation/models/premium_future.dart';

class PremiumController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final prefs = Get.find<SharedPreferences>();

  final RxBool isPremium = false.obs;
  final RxBool showPremiumPopup = false.obs;
  final RxString userId = ''.obs;
  final RxBool isLoggedIn = false.obs;

  final List<PremiumFeature> features = [
    PremiumFeature(
      id: '1',
      title: 'Akses ke semua novel premium',
      icon: Icons.auto_stories,
    ),
    PremiumFeature(
      id: '2',
      title: 'Baca tanpa iklan',
      icon: Icons.block,
    ),
    PremiumFeature(
      id: '3',
      title: 'Akses early chapter baru',
      icon: Icons.access_time_filled,
    ),
    PremiumFeature(
      id: '4',
      title: 'Download untuk dibaca offline',
      icon: Icons.download,
    ),
    PremiumFeature(
      id: '5',
      title: 'Badge premium eksklusif',
      icon: Icons.verified,
    ),
  ];

  final String monthlyPrice = 'Rp 29.000';
  final String perMonthText = 'per bulan';

  @override
  void onInit() {
    super.onInit();
    _getStatusLogin().then((_) {
      _loadPremiumStatus();
    });
  }

  Future<void> _loadPremiumStatus() async {
    try {
      final data = await getDataFirestore(userId.value);

      if (data != null) {
        isPremium.value = data['is_premium'] ?? false;
      } else {
        isPremium.value = false;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _getStatusLogin() async {
    try {
      isLoggedIn.value = prefs.getBool('isLoggedIn') ?? false;
      if (isLoggedIn.value) {
        userId.value = prefs.getString('userId') ?? '';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getDataFirestore(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> document =
          await _firestore.collection('users').doc(userId).get();
      if (document.exists) {
        return document.data()!;
      } else {
        print("Data tidak ditemukan dari id: $userId");
        return null;
      }
    } catch (e) {
      print("Error fetching data: $e");
      return null;
    }
  }

  Future<void> _savePremiumStatus(bool premium) async {
    try {
      final prefs = Get.find<SharedPreferences>();
      await prefs.setBool('is_premium', premium);
    } catch (e) {
      print('Error saving premium status: $e');
    }
  }

  void showPopup() {
    showPremiumPopup.value = true;
  }

  void hidePopup() {
    showPremiumPopup.value = false;

    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  void upgradeToPremium() {
    isPremium.value = true;
    _savePremiumStatus(true);
    hidePopup();

    Get.snackbar(
      'Premium Activated!',
      'Selamat! Anda sekarang pengguna premium',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
  }

  void setShowPopupOnNextLaunch(bool show) async {
    try {
      log("show? $show");
      await prefs.setBool('show_premium_popup_on_launch', show);
    } catch (e) {
      print('Error setting show popup: $e');
      rethrow;
    }
  }

  bool shouldShowPopupOnLaunch() {
    try {
      final isPremium = prefs.getBool('is_premium') ?? false;
      final showOnLaunch =
          prefs.getBool('show_premium_popup_on_launch') ?? true;

      // Cek jika user sudah premium atau sudah memilih "Nanti Saja"
      if (isPremium) return false;

      // Cek kapan terakhir kali popup ditampilkan
      final lastShown = prefs.getInt('last_premium_popup_shown') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      final oneWeekInMillis = 7 * 24 * 60 * 60 * 1000;

      // Tampilkan popup maksimal sekali seminggu
      if (now - lastShown < oneWeekInMillis) {
        return false;
      }

      return showOnLaunch;
    } catch (e) {
      return false;
    }
  }

  void recordPopupShown() async {
    try {
      await prefs.setInt(
          'last_premium_popup_shown', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error recording popup shown: $e');
      rethrow;
    }
  }
}
