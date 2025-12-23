import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_brain/presentation/controllers/novel/edit_chapter_controller.dart';

class EditChapterPage extends GetView<EditChapterController> {
  const EditChapterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Obx(
                () => Text(
              controller.isEditMode.value ? 'Edit Bab' : 'Tambah Bab',
            ),
          ),
          actions: [
            Obx(
                  () => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(controller.statusText),
                  selected: controller.isPublished.value,
                  selectedColor: controller.isPublished.value
                      ? Colors.green
                      : Colors.yellow,
                  labelStyle: const TextStyle(color: Colors.black),
                  onSelected: (_) => controller.togglePublished(),
                ),
              ),
            ),
            Obx(
                  () => IconButton(
                icon: const Icon(Icons.save),
                onPressed: controller.isDirty.value &&
                    controller.isValid.value
                    ? () => controller.saveChapter(context)
                    : null,
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Obx(
                    () => Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: controller.isPreviewMode.value
                            ? () => controller.setPreview(false)
                            : null,
                        child: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: !controller.isPreviewMode.value
                            ? () => controller.setPreview(true)
                            : null,
                        child: const Text('Preview'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(
                      () => controller.isPreviewMode.value
                      ? _preview()
                      : _editor(),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(
                  () => ElevatedButton(
                onPressed: controller.isDirty.value &&
                    controller.isValid.value
                    ? () => controller.saveChapter(context)
                    : null,
                child: Text(
                  controller.isEditMode.value
                      ? 'Simpan Perubahan'
                      : 'Tambah Bab',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _editor() {
    return Column(
      children: [
        TextField(
          controller: controller.titleController,
          decoration: InputDecoration(
            labelText: 'Judul Chapter',
            border: const OutlineInputBorder(),
            errorText: controller.isDirty.value &&
                controller.titleController.text.trim().isEmpty
                ? 'Judul wajib diisi'
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TextField(
            controller: controller.contentController,
            maxLines: null,
            expands: true,
            decoration: InputDecoration(
              hintText: 'Mulai menulis...',
              border: const OutlineInputBorder(),
              errorText: controller.isDirty.value &&
                  controller.characterCount.value <
                      EditChapterController.minCharacterCount
                  ? 'Minimal ${EditChapterController.minCharacterCount} karakter'
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Obx(
              () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${controller.wordCount.value} kata • '
                    '${controller.characterCount.value} karakter',
              ),
              if (controller.characterCount.value <
                  EditChapterController.minCharacterCount)
                Text(
                  'Kurang '
                      '${EditChapterController.minCharacterCount - controller.characterCount.value} karakter',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _preview() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              controller.titleController.text.isEmpty
                  ? 'Judul Chapter'
                  : controller.titleController.text,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            controller.contentController.text,
            textAlign: TextAlign.justify,
            style: const TextStyle(height: 1.7),
          ),
        ],
      ),
    );
  }
}
