import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terra_brain/presentation/models/premium_future.dart';
import 'package:terra_brain/presentation/service/firestore_cache_service.dart';

class PremiumController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreCacheService _cacheService =
      Get.find<FirestoreCacheService>();
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

      final premium = data?['is_premium'] ?? false;
      isPremium.value = premium;

      await _savePremiumStatus(premium);
    } catch (e) {
      log('Error load premium status: $e');
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
    if (userId.isEmpty) return null;

    final userRef = _firestore.collection('users').doc(userId);
    var document = await _cacheService.docGet(userRef);
    Map<String, dynamic>? data = document.data();

    if (document.metadata.isFromCache) {
      final refreshedDoc = await _cacheService.docGet(
        userRef,
        forceRefresh: true,
      );
      if (!refreshedDoc.metadata.isFromCache) {
        document = refreshedDoc;
        data = document.data();
      }
    }

    return document.exists ? data : null;
  }

  Future<void> _savePremiumStatus(bool premium) async {
      final prefs = Get.find<SharedPreferences>();
      await prefs.setBool('is_premium', premium);
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

  Future<void> upgradeToPremium() async {
    try {
      isPremium.value = true;

      await _savePremiumStatus(true);
      await _updatePremiumToFirestore(true);

      hidePopup();

      Get.snackbar(
        'Premium Activated!',
        'Selamat! Anda sekarang pengguna premium',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Upgrade gagal',
        'Terjadi kesalahan, coba lagi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _updatePremiumToFirestore(bool premium) async {
    if (userId.value.isEmpty) return;

    try {
      await _firestore.collection('users').doc(userId.value).update({
        'is_premium': premium,
        'premium_updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log('Error updating premium to firestore: $e');
      rethrow;
    }
  }

  void setShowPopupOnNextLaunch(bool show) async {
      log("show? $show");
      await prefs.setBool('show_premium_popup_on_launch', show);
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
      await prefs.setInt(
          'last_premium_popup_shown', DateTime.now().millisecondsSinceEpoch);
  }
}
