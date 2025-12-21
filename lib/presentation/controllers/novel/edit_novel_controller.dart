import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:terra_brain/presentation/models/genre_model.dart';
import 'package:terra_brain/presentation/models/novel_model.dart';

class EditNovelController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  late final TextEditingController titleController = TextEditingController();
  late final TextEditingController descriptionController =
      TextEditingController();
  late final String novelId;
  String coverUrl = '';
  final Rx<File?> newCoverImage = Rx<File?>(null);
  final RxList<Chapter> chapters = <Chapter>[].obs;

  final Rxn<Novel> novel = Rxn<Novel>();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isDirty = false.obs;

  Rx<Genre?> selectedGenre = Rx<Genre?>(null);
  final RxString selectedStatus = 'Berlanjut'.obs;
  final RxList<Genre> genres = <Genre>[].obs;

  final List<String> status = ['Berlanjut', 'Selesai', 'Hiatus'];

  @override
  void onInit() {
    super.onInit();
    novelId = Get.parameters['id'] ?? '';

    if (novelId.isNotEmpty) {
      fetchGenres().then((_) async {
        await fetchNovel();
        await fetchChapters();
      });
    } else {
      errorMessage.value = 'ID novel tidak valid';
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  Future<void> fetchGenres() async {
    try {
      isLoading.value = true;

      final snapshot = await _firestore.collection('genres').get();

      if (snapshot.docs.isEmpty) {
        log('Tidak ada genre yang tersedia');
        errorMessage.value = 'Tidak ada genre yang tersedia';
        genres.clear();
        return;
      }

      genres.value = snapshot.docs
          .map((doc) => Genre.fromMap(doc.data(), doc.id))
          .toList();

      errorMessage.value = '';
    } catch (e, stack) {
      log('Error fetchGenres: $e', stackTrace: stack);
      errorMessage.value = 'Gagal mengambil data genre';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchNovel() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      log('idNovel: $novelId');

      final doc = await _firestore.collection('novels').doc(novelId).get();

      if (!doc.exists) {
        log("novel tidak ditemukan");
        errorMessage.value = 'Novel tidak ditemukan';
        return;
      }

      final data = doc.data()!;
      final parsed = Novel.fromJson(data, doc.id);

      novel.value = parsed;
      coverUrl = parsed.imageUrl ?? '';
      titleController.text = parsed.title;
      descriptionController.text = parsed.description ?? '';
      selectedGenre.value = genres.firstWhereOrNull(
        (g) => g.name == parsed.genre,
      );
      selectedStatus.value = parsed.status ?? 'Berlanjut';
    } catch (e, s) {
      log('[EDIT_NOVEL] $e', stackTrace: s);
      errorMessage.value = 'Gagal memuat novel';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchChapters() async {
    try {
      log('start fetching chapter');
      final snapshot = await _firestore
          .collection('novels')
          .doc(novelId)
          .collection('chapters')
          .orderBy('chapter')
          .get();

      chapters.value = snapshot.docs
          .map((doc) => Chapter.fromJson(doc.id, doc.data()))
          .toList();

      // Log data yang di-fetch
      log('[FETCH_CHAPTERS] Berhasil mengambil ${chapters.length} chapter');

      for (var i = 0; i < chapters.length; i++) {
        final chapter = chapters[i];
        log('Chapter ${i+1}: No.${chapter.chapter} - ${chapter.title} (ID: ${chapter.id})');
      }

    } catch (e, s) {
      log('[FETCH_CHAPTERS] $e', stackTrace: s);
      Get.snackbar('Error', 'Gagal memuat chapter');
    }
  }

  Future<void> pickNewCoverImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked != null) {
      newCoverImage.value = File(picked.path);
      _markDirty();
      log('Cover baru dipilih: ${picked.path}');
    }
  }

  Future<String> _uploadCoverAndReplace() async {
    // path baru
    final ref = _storage.ref(
      'novels/$novelId/cover/${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    await ref.putFile(newCoverImage.value!);
    final newUrl = await ref.getDownloadURL();

    // hapus gambar lama kalau ada
    if (coverUrl.isNotEmpty) {
      try {
        await _storage.refFromURL(coverUrl).delete();
      } catch (e) {
        log('Gagal hapus cover lama (aman diabaikan): $e');
      }
    }

    return newUrl;
  }

  void _updateNovel(Novel updated) {
    novel.value = updated.copyWith(updatedAt: DateTime.now());
  }

  void updateTitle(String title) {
    _updateNovel(novel.value!.copyWith(title: title));
    _markDirty();
  }

  void updateDescription(String description) {
    _updateNovel(novel.value!.copyWith(description: description));
    _markDirty();
  }

  void updateGenre(Genre genre) {
    selectedGenre.value = genre;
    _updateNovel(novel.value!.copyWith(genre: genre.name));
    _markDirty();
  }

  void updateOngoingStatus(String value) {
    if (!statusOngoingMap.containsKey(value)) return;

    selectedStatus.value = value;

    _updateNovel(
      novel.value!.copyWith(
        status: value,
        isOngoing: statusOngoingMap[value]!,
      ),
    );

    _markDirty();
  }

  static const Map<String, bool> statusOngoingMap = {
    'Berlanjut': true,
    'Hiatus': false,
    'Selesai': false,
  };

  Future<void> openAddChapter() async {
    final result = await Get.toNamed(
      '/edit_chapter',
      arguments: {
        'chapter': chapters.length + 1,
      },
    );

    if (result == null) return;

    if (result['action'] != 'create') return;

    final Chapter chapter = result['chapter'];

    final docRef = _firestore
        .collection('novels')
        .doc(novelId)
        .collection('chapters')
        .doc();

    final chapterWithId = chapter.copyWith(id: docRef.id);

    await docRef.set(chapterWithId.toJson());
    chapters.add(chapterWithId);
  }

  Future<void> openEditChapter(Chapter chapter) async {
    final index = chapters.indexWhere((c) => c.id == chapter.id);

    final result = await Get.toNamed(
      '/edit_chapter',
      arguments: {
        'chapter': chapter,
      },
    );

    if (result == null) return;

    if (result['action'] != 'update') return;

    final Chapter updated = result['chapter'];

    await _firestore
        .collection('novels')
        .doc(novelId)
        .collection('chapters')
        .doc(updated.id)
        .update(updated.toJson());

    chapters[index] = updated;
  }

  Future<void> deleteChapter(Chapter chapter) async {
    try {
      final batch = _firestore.batch();

      for (int i = 0; i < chapters.length; i++) {
        final updated = chapters[i].copyWith(chapter: i + 1);
        chapters[i] = updated;

        final ref = _firestore
            .collection('novels')
            .doc(novelId)
            .collection('chapters')
            .doc(updated.id);

        batch.update(ref, {'chapterNumber': i + 1});
      }

      await batch.commit();

      Get.snackbar('Dihapus', 'Chapter berhasil dihapus');
    } catch (e, s) {
      log('[DELETE_CHAPTER] $e', stackTrace: s);
      Get.snackbar('Error', 'Gagal menghapus chapter');
    }
  }

  Future<void> saveChanges() async {
    try {
      isLoading.value = true;

      String? finalCoverUrl = coverUrl;

      if (newCoverImage.value != null) {
        finalCoverUrl = await _uploadCoverAndReplace();
      }

      final updatedNovel = novel.value!.copyWith(
        imageUrl: finalCoverUrl,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('novels')
          .doc(updatedNovel.id)
          .update(updatedNovel.toJson());

      novel.value = updatedNovel;
      coverUrl = finalCoverUrl;
      newCoverImage.value = null;
      isDirty.value = false;

      Get.back();
    } catch (e, s) {
      log('SAVE ERROR: $e', stackTrace: s);
      Get.snackbar(
        'Gagal',
        'Tidak bisa menyimpan perubahan',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  int get totalWordCount {
    return chapters.fold(0, (total, c) {
      return total +
          c.content.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    });
  }

  void _markDirty() {
    if (!isDirty.value) {
      isDirty.value = true;
    }
  }
}
