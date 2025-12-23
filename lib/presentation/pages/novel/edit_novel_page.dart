import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_brain/presentation/controllers/novel/edit_novel_controller.dart';
import 'package:terra_brain/presentation/models/genre_model.dart';
import 'package:terra_brain/presentation/models/novel_model.dart';

class EditNovelPage extends GetView<EditNovelController> {
  const EditNovelPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Edit Novel',
          style: Get.theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Get.theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: Obx(
        () {
          if (controller.isLoading.value && controller.novel.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.value.isNotEmpty && controller.novel.value == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: Get.theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Kembali'),
                  ),
                ],
              ),
            );
          }

          if (controller.novel.value == null) {
            log('value novel: ${controller.novel.value}');
            return const Center(child: Text('Data novel tidak ditemukan'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNovelInfoSection(),
                  const SizedBox(height: 24),
                  _buildGenreStatusSection(),
                  const SizedBox(height: 24),
                  _buildChaptersSection(),
                  const SizedBox(height: 32),
                  _buildActionButtons(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNovelInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informasi Novel',
          style: Get.theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        SizedBox(height: 16),

        // Cover Upload
        _buildCoverUpload(controller),
        SizedBox(height: 20),

        // Title
        _buildTitleField(),
        SizedBox(height: 16),

        // Description
        _buildDescriptionField(),
      ],
    );
  }

  Widget _buildCoverPreview(EditNovelController controller) {
    const String kDefaultCoverAsset = 'assets/images/book.jpg';
    return Obx(() {
      Widget image;

      if (controller.newCoverImage.value != null) {
        image = Image.file(
          controller.newCoverImage.value!,
          fit: BoxFit.cover,
        );
      } else if (controller.coverUrl.isNotEmpty) {
        image = Image.network(
          controller.coverUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Image.asset(
              kDefaultCoverAsset,
              fit: BoxFit.cover,
            );
          },
        );
      } else {
        image = Image.asset(
          kDefaultCoverAsset,
          fit: BoxFit.cover,
        );
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 2 / 3,
          child: image,
        ),
      );
    });
  }

  Widget _buildCoverUpload(EditNovelController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cover Novel',
          style: Get.theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ukuran rekomendasi: 800x1200px',
          style: Get.theme.textTheme.bodySmall?.copyWith(
            color: Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 12),
        _buildCoverPreview(controller),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: controller.pickNewCoverImage,
            icon: const Icon(Icons.upload, size: 20),
            label: const Text('Unggah Cover Baru'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.cardColor,
              foregroundColor: Get.theme.textTheme.bodyLarge?.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Get.theme.dividerColor),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Judul Novel',
          style: Get.theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller.titleController,
          onChanged: controller.updateTitle,
          decoration: InputDecoration(
            hintText: 'Masukkan judul novel',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          style: Get.theme.textTheme.bodyLarge,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Judul novel harus diisi';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deskripsi',
          style: Get.theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller.descriptionController,
          onChanged: controller.updateDescription,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Deskripsikan novel Anda...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: EdgeInsets.all(16),
            alignLabelWithHint: true,
          ),
          style: Get.theme.textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildGenreStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori',
          style: Get.theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildGenreDropdown(),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildStatusDropdown(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenreDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Genre',
          style: Get.theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Get.theme.dividerColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Obx(
            () => DropdownButtonHideUnderline(
              child: DropdownButton<Genre>(
                value:
                    controller.genres.contains(controller.selectedGenre.value)
                        ? controller.selectedGenre.value
                        : null,
                items: controller.genres.map((genre) {
                  return DropdownMenuItem<Genre>(
                    value: genre,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('${genre.name}'),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) controller.updateGenre(value);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: Get.theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Get.theme.dividerColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Obx(
            () => DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.selectedStatus.value,
                items: controller.status.map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(status),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.updateOngoingStatus(value);
                  }
                },
                isExpanded: true,
                padding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChaptersSection() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Bab (${controller.chapters.length})',
                  style: Get.theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              SizedBox(
                height: 50,
                width: 160,
                child: ElevatedButton.icon(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.openAddChapter,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Tambah Bab'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (controller.chapters.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              alignment: Alignment.center,
              child: Text(
                'Belum ada bab.\nTambahkan bab pertama.',
                textAlign: TextAlign.center,
                style: Get.theme.textTheme.bodyMedium?.copyWith(
                  color:
                      Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
            )
          else if (controller.errorMessage.value.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Icon(Icons.error_outline, size: 32, color: Colors.red),
                  const SizedBox(height: 8),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: Get.theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children:
                  controller.chapters.map((c) => _buildChapterCard(c)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildChapterCard(Chapter chapter) {
    final isPublished = chapter.isPublished == 'published';

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      color: Get.theme.cardColor,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Text(
                  '#${chapter.chapter} ${chapter.title}',
                  style: Get.theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                // Status Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPublished
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isPublished ? Colors.green : Colors.orange,
                    ),
                  ),
                  child: Text(
                    isPublished ? 'Published' : 'Draft',
                    style: TextStyle(
                      color: isPublished ? Colors.green : Colors.orange,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  color: Colors.red,
                  onPressed: () => controller.confirmDeleteChapter(chapter),
                ),

                // Edit Button
                IconButton(
                  icon: Icon(Icons.edit, size: 20),
                  // onPressed: () {},
                  onPressed: () => controller.openEditChapter(chapter),
                  color: Get.theme.primaryColor,
                ),
              ],
            ),
            SizedBox(height: 8),

            // Word Count
            Text(
              '${chapter.content.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length} kata',
              style: Get.theme.textTheme.bodySmall?.copyWith(
                color: Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Obx(
          () => SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.isDirty.value && !controller.isLoading.value
                  ? controller.saveChanges
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Get.theme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: controller.isLoading.value
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Text('Simpan Perubahan'),
            ),
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => OutlinedButton(
                  onPressed: controller.isLoading.value ? null : () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Get.theme.textTheme.bodyLarge?.color,
                    side: BorderSide(color: Get.theme.dividerColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('Batal'),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.confirmDeleteNovel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Hapus Novel'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
