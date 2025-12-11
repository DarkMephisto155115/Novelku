import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terra_brain/presentation/controllers/premium_controller.dart';
import 'package:terra_brain/presentation/widgets/premium_popup_widget.dart';

class PremiumPopupManager {
  static void showPremiumPopup({
    String? title,
    String? description,
    bool showCloseButton = true,
  }) {
    final controller = Get.find<PremiumController>();

    // Jangan tampilkan jika sudah premium
    if (controller.isPremium.value) return;

    controller.showPopup();

    // Record that popup was shown
    controller.recordPopupShown();

    Get.dialog(
      PremiumPopup(
        title: title,
        description: description,
        showCloseButton: showCloseButton,
        onClose: () => controller.hidePopup(),
      ),
      barrierDismissible: false,
    );
  }

  static void checkAndShowPopupOnLaunch() {
    final controller = Get.find<PremiumController>();

    Future.delayed(
      Duration(seconds: 2),
      () {
        if (controller.shouldShowPopupOnLaunch()) {
          showPremiumPopup(
            title: 'Upgrade ke Premium',
            description:
                'Nikmati pengalaman membaca tanpa\nbatas dengan Premium!',
            showCloseButton: true,
          );
        }
      },
    );
  }

  static void showPopupBeforeReading() {
    final controller = Get.find<PremiumController>();

    if (controller.isPremium.value) return;

    // Cek jika user sudah memilih "Nanti Saja" hari ini
    final prefs = Get.find<SharedPreferences>();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastSkipDate = prefs.getString('last_premium_skip_date') ?? '';

    if (lastSkipDate == today) return;

    Future.delayed(
      Duration(milliseconds: 500),
      () {
        showPremiumPopup(
          title: 'Akses Baca Tanpa Batas',
          description:
              'Upgrade ke Premium untuk membaca\nnovel tanpa iklan dan batasan!',
          showCloseButton: true,
        );
      },
    );
  }
}
