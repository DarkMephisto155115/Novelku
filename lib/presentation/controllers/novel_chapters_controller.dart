import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:terra_brain/presentation/models/novel_model.dart';
import 'package:terra_brain/presentation/service/firestore_cache_service.dart';

class NovelChaptersController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreCacheService _cacheService =
      Get.find<FirestoreCacheService>();

  late final String novelId;

  final novel = Rx<Novel?>(null);
  final chapters = <Chapter>[].obs;
  final filteredChapters = <Chapter>[].obs;

  final isLoading = true.obs;
  final searchQuery = ''.obs;
  final isFavorite = false.obs;
  final isFavoriteProcessing = false.obs;
  final isAuthorPremium = false.obs;

  @override
  void onInit() {
    super.onInit();

    novelId = Get.arguments?['novelId'] ?? '';

    if (novelId.isEmpty) {
      isLoading.value = false;
      return;
    }

    _fetchNovelWithChapters();
    _loadFavoriteState();
  }

  // =========================
  // FETCH NOVEL WITH CHAPTERS FROM SUBCOLLECTION
  // =========================
  void _fetchNovelWithChapters() {
    isLoading.value = true;

    _firestore
        .collection('novels')
        .doc(novelId)
        .snapshots()
        .listen((novelDoc) async {
      if (!novelDoc.exists) {
        isLoading.value = false;
        return;
      }

      Novel novelData = Novel.fromJson(novelDoc.data()!, novelDoc.id);

      if (novelData.authorId != null) {
        _firestore
            .collection('users')
            .doc(novelData.authorId)
            .get()
            .then((userDoc) {
          if (userDoc.exists) {
            isAuthorPremium.value = userDoc.data()?['is_premium'] ?? false;
          }
        });
      }

      _firestore
          .collection('novels')
          .doc(novelId)
          .collection('chapters')
          .orderBy('chapter')
          .snapshots()
          .listen((chaptersSnapshot) {
        final chapterList = chaptersSnapshot.docs
            .map((doc) => Chapter.fromJson(doc.id, doc.data()))
            .where((c) => c.isPublished != null && (c.isPublished!.toLowerCase() == 'published' || c.isPublished == 'true'))
            .toList();

        chapters.assignAll(chapterList);
        filteredChapters.assignAll(chapterList);

        novel.value = novelData.copyWith(chapters: chapterList);
        isLoading.value = false;
      }, onError: (e) {
        novel.value = novelData;
        isLoading.value = false;
      });
    }, onError: (_) {
      isLoading.value = false;
    });
  }

  // =========================
  // SEARCH
  // =========================
  void filterChapters(String keyword) {
    searchQuery.value = keyword;

    if (keyword.isEmpty) {
      filteredChapters.assignAll(chapters);
      return;
    }

    final lower = keyword.toLowerCase();

    filteredChapters.assignAll(
      chapters.where(
            (c) =>
        c.title.toLowerCase().contains(lower) ||
            c.chapter.toString().contains(lower),
      ),
    );
  }

  // =========================
  // FAVORITE
  // =========================
  Future<void> _loadFavoriteState() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null || novelId.isEmpty) {
        isFavorite.value = false;
        return;
      }

      final doc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('favorites')
          .doc(novelId)
          .get();

      isFavorite.value = doc.exists;
    } catch (e) {
      if (kDebugMode) print('Error loading favorite state: $e');
      isFavorite.value = false;
    }
  }

  Future<void> toggleFavorite() async {
    if (isFavoriteProcessing.value) return;

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      Get.snackbar(
        'Error',
        'Anda harus login terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isFavoriteProcessing.value = true;

      if (isFavorite.value) {
        await _removeFromFavorites(currentUser.uid);
      } else {
        await _addToFavorites(currentUser.uid);
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error toggling favorite: $e');
      Get.snackbar(
        'Error',
        'Gagal mengubah favorit',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isFavoriteProcessing.value = false;
    }
  }

  Future<void> _addToFavorites(String userId) async {
    try {
      final novelDoc = await _cacheService.docGet(
        _firestore.collection('novels').doc(novelId),
      );
      if (!novelDoc.exists) return;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(novelId)
          .set({
            'novelRef': _firestore.collection('novels').doc(novelId),
            'createdAt': FieldValue.serverTimestamp(),
          });

      isFavorite.value = true;

      if (kDebugMode) {
        print('✅ Novel added to favorites: $novelId');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error adding to favorites: $e');
      rethrow;
    }
  }

  Future<void> _removeFromFavorites(String userId) async {
    try {
      final novelDoc = await _cacheService.docGet(
        _firestore.collection('novels').doc(novelId),
      );
      if (!novelDoc.exists) return;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(novelId)
          .delete();

      isFavorite.value = false;

      if (kDebugMode) {
        print('✅ Novel removed from favorites: $novelId');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error removing from favorites: $e');
      rethrow;
    }
  }
}
