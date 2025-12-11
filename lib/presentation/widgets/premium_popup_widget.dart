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

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PremiumController>();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(24),
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
              // Header dengan close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title ?? 'Upgrade ke Premium',
                      style: Get.theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  if (showCloseButton)
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: onClose ?? () => controller.hidePopup(),
                    ),
                ],
              ),
              SizedBox(height: 16),

              // Description
              Text(
                description ?? 'Nikmati pengalaman membaca tanpa\nbatas dengan Premium!',
                style: Get.theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24),

              // Features List
              Column(
                children: controller.features.map((feature) => _buildFeatureItem(feature)).toList(),
              ),
              SizedBox(height: 24),

              Divider(
                color: Get.theme.dividerColor.withOpacity(0.3),
                height: 1,
              ),
              SizedBox(height: 24),

              // Price
              Center(
                child: Column(
                  children: [
                    Text(
                      controller.monthlyPrice,
                      style: Get.theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                        color: Get.theme.primaryColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      controller.perMonthText,
                      style: Get.theme.textTheme.bodyMedium?.copyWith(
                        color: Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Buttons
              Column(
                children: [
                  // Upgrade Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.upgradeToPremium,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Upgrade Sekarang',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),

                  // Later Button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        controller.setShowPopupOnNextLaunch(false);
                        controller.hidePopup();
                        // onClose?.call() ?? controller.hidePopup();
                        // onClose?.call();
                        // if(onClose != null){
                        //   onClose?.call();
                        // } else {
                        //   controller.hidePopup();
                        // }
                      },
                      child: Text(
                        'Nanti Saja',
                        style: TextStyle(
                          fontSize: 14,
                          color: Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
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
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            feature.icon,
            color: Get.theme.primaryColor,
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              feature.title,
              style: Get.theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}