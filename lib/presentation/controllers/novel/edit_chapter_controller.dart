import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_brain/presentation/models/novel_model.dart';

class EditChapterController extends GetxController {
  late Chapter chapter;

  final isEditMode = false.obs;
  final isPreviewMode = false.obs;
  final isPublished = false.obs;
  final isDirty = false.obs;
  final isValid = false.obs;

  final wordCount = 0.obs;
  final characterCount = 0.obs;

  static const int minCharacterCount = 200;

  final titleController = TextEditingController();
  final contentController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    if (args != null && args['chapter'] is Chapter) {
      chapter = args['chapter'] as Chapter;
      isEditMode.value = true;

      titleController.text = chapter.title;
      contentController.text = chapter.content;
      isPublished.value = chapter.isPublished == 'published';
    } else {
      final chapterNumber = (args?['chapter'] as int?) ?? 1;

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

    _onChanged();
  }

  void _onChanged() {
    final title = titleController.text.trim();
    final content = contentController.text;

    characterCount.value = content.length;
    wordCount.value =
        content.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).length;

    isValid.value =
        title.isNotEmpty && content.length >= minCharacterCount;

    isDirty.value = true;
  }

  void setPreview(bool value) {
    isPreviewMode.value = value;
  }

  void togglePublished() {
    isPublished.toggle();
    isDirty.value = true;
  }

  /// 🔥 FINAL FIX — NO Get.back(), NO Snackbar
  void saveChapter(BuildContext context) {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isEmpty) {
      _popError(context, 'Judul chapter wajib diisi');
      return;
    }

    if (content.isEmpty) {
      _popError(context, 'Konten chapter wajib diisi');
      return;
    }

    if (content.length < minCharacterCount) {
      _popError(
        context,
        'Minimal $minCharacterCount karakter '
            '(sekarang ${content.length})',
      );
      return;
    }

    final updatedChapter = chapter.copyWith(
      title: title,
      content: content,
      isPublished: isPublished.value ? 'published' : 'draft',
      updatedAt: DateTime.now(),
    );

    Navigator.of(context).pop({
      'success': true,
      'action': isEditMode.value ? 'update' : 'create',
      'chapter': updatedChapter,
    });
  }

  void _popError(BuildContext context, String message) {
    Navigator.of(context).pop({
      'success': false,
      'message': message,
    });
  }

  String get statusText => isPublished.value ? 'Published' : 'Draft';

  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    super.onClose();
  }
}
