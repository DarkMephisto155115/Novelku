import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_brain/presentation/controllers/profile/setting_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Pengaturan',
          style: Get.theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Get.theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tema Section
              _buildThemeSection(controller),
              SizedBox(height: 24),

              // Font Size Section
              _buildFontSizeSection(controller),
              SizedBox(height: 24),

              // Font Family Section
              _buildFontFamilySection(controller),
              SizedBox(height: 24),

              // Live Preview Section
              _buildLivePreviewSection(controller),
              SizedBox(height: 24),

              // Other Settings Section
              _buildOtherSettingsSection(controller),
              SizedBox(height: 32),

              // Save Button
              _buildSaveButton(controller),
              SizedBox(height: 20),

              // Analytics Debug Button
              _buildAnalyticsDebugButton(),
              SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildThemeSection(SettingsController controller) {
    return Card(
      color: Get.theme.cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tema',
              style: Get.theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mode Gelap',
                        style: Get.theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Nyaman dibaca di malam hari',
                        style: Get.theme.textTheme.bodySmall?.copyWith(
                          color: Get.theme.textTheme.bodyMedium?.color
                              ?.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Obx(
                  () => Switch(
                    value: controller.draftDarkMode.value,
                    onChanged: controller.toggleDarkMode,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeSection(SettingsController controller) {
    return Card(
      color: Get.theme.cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ukuran Font',
              style: Get.theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity, // paksa card ikut full width
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.fontSizes.map((size) {
                  final isSelected = controller.settings.value.fontSize == size;
                  return ChoiceChip(
                    label: Text(size),
                    selected: isSelected,
                    onSelected: (selected) => controller.setFontSize(size),
                    backgroundColor: Get.theme.cardColor,
                    selectedColor: Get.theme.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Get.theme.textTheme.bodyMedium?.color,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected
                            ? Get.theme.primaryColor
                            : Get.theme.dividerColor.withOpacity(0.3),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontFamilySection(SettingsController controller) {
    return Card(
      color: Get.theme.cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jenis Font',
              style: Get.theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: controller.settings.value.fontFamily,
              onChanged: (value) => controller.setFontFamily(value!),
              decoration: InputDecoration(
                filled: true,
                fillColor: Get.theme.inputDecorationTheme.fillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: controller.fontFamilies.map((font) {
                return DropdownMenuItem(
                  value: font,
                  child: Text(
                    font,
                    style: TextStyle(
                      fontFamily: _getFontFamily(font),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLivePreviewSection(SettingsController controller) {
    return Card(
      color: Get.theme.cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Live Preview',
              style: Get.theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Get.theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Get.theme.dividerColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bab 1: Awal Perjalanan',
                    style: Get.theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: controller.fontSizeValue,
                      fontFamily:
                          _getFontFamily(controller.settings.value.fontFamily),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Di sebuah desa kecil yang terletak di kaki gunung, hiduplah seorang pemuda bernama Arya. Sejak kecil, ia selalu bermimpi untuk menjelajahi dunia yang luas di luar desanya.',
                    style: Get.theme.textTheme.bodyMedium?.copyWith(
                      fontSize: controller.fontSizeValue,
                      fontFamily:
                          _getFontFamily(controller.settings.value.fontFamily),
                      height: 1.6,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Suatu pagi, ketika matahari baru saja terbit, Arya memutuskan bahwa saatnya telah tiba untuk memulai petualangannya.',
                    style: Get.theme.textTheme.bodyMedium?.copyWith(
                      fontSize: controller.fontSizeValue,
                      fontFamily:
                          _getFontFamily(controller.settings.value.fontFamily),
                      height: 1.6,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherSettingsSection(SettingsController controller) {
    return Card(
      color: Get.theme.cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lainnya',
              style: Get.theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            // Novel Notifications
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notifikasi Novel Baru',
                        style: Get.theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Dapatkan pemberitahuan chapter terbaru',
                        style: Get.theme.textTheme.bodySmall?.copyWith(
                          color: Get.theme.textTheme.bodyMedium?.color
                              ?.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Obx(() => Switch(
                      value: controller.settings.value.novelNotifications,
                      onChanged: controller.toggleNovelNotifications,
                      activeColor: Get.theme.primaryColor,
                    )),
              ],
            ),

            Divider(height: 32),

            // Auto-scroll
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Auto-scroll',
                        style: Get.theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Scroll otomatis saat membaca',
                        style: Get.theme.textTheme.bodySmall?.copyWith(
                          color: Get.theme.textTheme.bodyMedium?.color
                              ?.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Obx(() => Switch(
                      value: controller.settings.value.autoScroll,
                      onChanged: controller.toggleAutoScroll,
                      activeColor: Get.theme.primaryColor,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(SettingsController controller) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: Get.theme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          'Simpan Perubahan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _getFontFamily(String fontName) {
    switch (fontName) {
      case 'Arial':
        return 'Arial';
      case 'Georgia':
        return 'Georgia';
      case 'Pangolin':
        return 'Pangolin';
      default:
        return 'Arial';
    }
  }

  Widget _buildAnalyticsDebugButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Get.toNamed('/analytics_debug'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          'Analytics Debug Panel',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
