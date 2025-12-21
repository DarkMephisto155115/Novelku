import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_brain/presentation/models/novel_model.dart';

class EditChapterController extends GetxController {
  late Chapter chapter;
  late bool isEditMode;

  final titleController = TextEditingController();
  final contentController = TextEditingController();

  final RxBool isPreviewMode = false.obs;
  final RxBool isPublished = false.obs;

  final RxInt wordCount = 0.obs;
  final RxInt characterCount = 0.obs;
  final RxBool isDirty = false.obs;
  static const int minCharacterCount = 200;


  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    if (args != null && args['chapter'] != null) {
      chapter = args['chapter'] as Chapter;
      isEditMode = true;

      titleController.text = chapter.title;
      contentController.text = chapter.content;
      isPublished.value = chapter.isPublished == 'published';
    } else {
      isEditMode = false;

      final chapterNumber = args?['chapterNumber'] ?? 1;

      chapter = Chapter(
        id: '',
        chapter: chapterNumber,
        title: '',
        content: '',
        isPublished: 'draft',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    titleController.addListener(_onChanged);
    contentController.addListener(_onChanged);
  }

  void _onChanged() {
    final text = contentController.text;

    characterCount.value = text.length;
    wordCount.value =
        text.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).length;

    if (!isDirty.value) isDirty.value = true;
  }

  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    super.onClose();
  }

  void setPreview(bool value) {
    isPreviewMode.value = value;
  }

  void togglePublished() {
    isPublished.value = !isPublished.value;
    _markDirty();
  }

  void _markDirty() {
    if (!isDirty.value) isDirty.value = true;
  }

  bool get isValid =>
      titleController.text.trim().isNotEmpty &&
          contentController.text.trim().isNotEmpty;


  void saveChapter() {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isEmpty) {
      Get.snackbar('Gagal', 'Judul chapter wajib diisi');
      return;
    }

    if (content.isEmpty) {
      Get.snackbar('Gagal', 'Konten chapter wajib diisi');
      return;
    }

    if (content.length < minCharacterCount) {
      Get.snackbar(
        'Cerita terlalu pendek',
        'Minimal $minCharacterCount karakter (sekarang ${content.length})',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final updatedChapter = chapter.copyWith(
      title: title,
      content: content,
      isPublished: isPublished.value ? 'published' : 'draft',
      updatedAt: DateTime.now(),
    );

    Get.back(result: {
      'action': isEditMode ? 'update' : 'create',
      'chapter': updatedChapter,
    });

    Get.snackbar(
      'Berhasil',
      isEditMode ? 'Chapter diperbarui' : 'Chapter ditambahkan',
      snackPosition: SnackPosition.BOTTOM,
    );
  }


  String get statusText => isPublished.value ? 'Published' : 'Draft';
}
