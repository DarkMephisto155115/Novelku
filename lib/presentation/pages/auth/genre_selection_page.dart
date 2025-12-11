import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_brain/presentation/controllers/auth/genre_selection_controller.dart';
import 'package:terra_brain/presentation/models/genre_model.dart';

class GenreSelectionPage extends GetView<GenreSelectionController> {
  const GenreSelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeaderSection(),
              SizedBox(height: 32),

              // Genre Selection Section
              _buildGenreSelectionSection(),
              SizedBox(height: 32),

              // Continue Button
              _buildContinueButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat Datang!',
          style: Get.theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        SizedBox(height: 12),

        // Description
        Text(
          'Pilih 3 genre favoritmu untuk rekomendasi personal',
          style: Get.theme.textTheme.bodyLarge?.copyWith(
            color: Get.theme.textTheme.bodyLarge?.color?.withOpacity(0.8),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildGenreSelectionSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title and Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pilih Genre',
                style: Get.theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Obx(() => Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Get.theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${controller.selectedCount.value}/3 dipilih',
                      style: TextStyle(
                        color: Get.theme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )),
            ],
          ),
          SizedBox(height: 20),

          // Genre Grid
          Expanded(
            child: Obx(
              () => GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: controller.genres.length,
                itemBuilder: (context, index) {
                  final genre = controller.genres[index];
                  return _buildGenreCard(genre);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreCard(Genre genre) {
    final isSelected = genre.isSelected;

    return GestureDetector(
      onTap: () => controller.toggleGenre(genre.id),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isSelected ? Get.theme.primaryColor.withOpacity(0.1) : Get.theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? Get.theme.primaryColor.withOpacity(0.7)
                : Get.theme.dividerColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(genre.emoji, style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text(
              genre.name,
              style: TextStyle(
                color: isSelected
                    ? Get.theme.textTheme.labelSmall?.color
                    : Get.theme.textTheme.bodyMedium?.color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: controller.canProceed ? controller.proceedToHome : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: controller.canProceed
                ? Get.theme.primaryColor
                : Get.theme.primaryColor.withOpacity(0.3),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            'Lanjutkan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
