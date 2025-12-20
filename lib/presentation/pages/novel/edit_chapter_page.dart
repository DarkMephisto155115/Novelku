import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_brain/presentation/controllers/novel/edit_chapter_controller.dart';

class EditChapterPage extends GetView<EditChapterController> {
  const EditChapterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.isPreviewMode.value ? 'Preview Chapter' : 'Edit Chapter',
          ),
        ),
        actions: [
          Obx(
            () => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(controller.statusText),
                selected: controller.isPublished.value,
                selectedColor:
                    controller.isPublished.value ? Colors.green : Colors.yellow,
                labelStyle: const TextStyle(color: Colors.black),
                onSelected: (_) => controller.togglePublished(),
              ),
            ),
          ),
          Obx(
            () => IconButton(
              icon: const Icon(Icons.save),
              onPressed: controller.isDirty.value && controller.isValid
                  ? controller.saveChapter
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

            // KONTEN YANG BERUBAH
            Expanded(
              child: Obx(() {
                return controller.isPreviewMode.value ? _preview() : _editor();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _editor() {
    return Column(
      children: [
        TextField(
          controller: controller.titleController,
          decoration: const InputDecoration(
            labelText: 'Judul Chapter',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TextField(
            controller: controller.contentController,
            maxLines: null,
            expands: true,
            decoration: const InputDecoration(
              hintText: 'Mulai menulis...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Text(
            '${controller.wordCount.value} kata • ${controller.characterCount.value} karakter',
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
