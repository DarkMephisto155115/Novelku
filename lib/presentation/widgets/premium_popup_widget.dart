import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/premium_controller.dart';
import '../models/premium_future.dart';

class PremiumPopup extends StatelessWidget {
  final String? title;
  final String? description;
  final VoidCallback? onClose;
  final bool showCloseButton;

  const PremiumPopup({
    Key? key,
    this.title,
    this.description,
    this.onClose,
    this.showCloseButton = true,
  }) : super(key: key);

  void _closePopup() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
    onClose?.call();
  }

  @override
  Widget build(BuildContext context) {
    final PremiumController controller = Get.find();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Get.theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== HEADER =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title ?? 'Upgrade ke Premium',
                      style: Get.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  if (showCloseButton)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _closePopup,
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // ===== DESCRIPTION =====
              Text(
                description ??
                    'Nikmati pengalaman membaca tanpa\nbatas dengan Premium!',
                style: Get.textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              // ===== FEATURES =====
              Column(
                children: controller.features
                    .map(_buildFeatureItem)
                    .toList(),
              ),

              const SizedBox(height: 24),

              Divider(
                color: Get.theme.dividerColor.withOpacity(0.3),
                height: 1,
              ),

              const SizedBox(height: 24),

              // ===== PRICE =====
              Center(
                child: Column(
                  children: [
                    Text(
                      controller.monthlyPrice,
                      style: Get.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                        color: Get.theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.perMonthText,
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: Get.textTheme.bodyMedium?.color
                            ?.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ===== ACTION BUTTONS =====
              Column(
                children: [
                  // UPGRADE
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        controller.upgradeToPremium();
                        _closePopup();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        padding:
                        const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Upgrade Sekarang',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // LATER
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        controller
                            .setShowPopupOnNextLaunch(false);
                        _closePopup();
                      },
                      child: Text(
                        'Nanti Saja',
                        style: TextStyle(
                          fontSize: 14,
                          color: Get.textTheme.bodyMedium?.color
                              ?.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(PremiumFeature feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            feature.icon,
            color: Get.theme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature.title,
              style: Get.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
