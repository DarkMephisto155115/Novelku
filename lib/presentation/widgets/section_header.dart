import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/write/writing_controller.dart';


class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const SectionHeader({super.key, required this.title, this.trailing});


  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDarkMode = Get.find<WritingController>().themeController.isDarkMode;
      final textColor = isDarkMode ? Colors.white : Colors.black;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
              ],
            ),
            if (trailing != null) trailing!,
          ],
        ),
      );
    });
  }
}