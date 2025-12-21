import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:terra_brain/presentation/models/novel_model.dart';

class NovelChaptersController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final String novelId;

  final novel = Rx<Novel?>(null);
  final chapters = <Chapter>[].obs;
  final filteredChapters = <Chapter>[].obs;

  final isLoading = true.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();

    novelId = Get.arguments?['novelId'] ?? '';

    if (novelId.isEmpty) {
      isLoading.value = false;
      return;
    }

    _fetchNovel();
    _fetchChapters();
    _incrementViewCount();
  }

  // =========================
  // FETCH NOVEL
  // =========================
  void _fetchNovel() {
    _firestore
        .collection('novels')
        .doc(novelId)
        .snapshots()
        .listen((doc) {
      if (!doc.exists) return;

      novel.value = Novel.fromJson(doc.data()!, doc.id);
    });
  }

  // =========================
  // FETCH CHAPTERS
  // =========================
  void _fetchChapters() {
    isLoading.value = true;

    _firestore
        .collection('novels')
        .doc(novelId)
        .collection('chapters')
        .where('isPublished', isEqualTo: 'published')
        .orderBy('chapter')
        .snapshots()
        .listen((snapshot) {
      final list = snapshot.docs
          .map((doc) => Chapter.fromJson(doc.id, doc.data()))
          .toList();

      chapters.assignAll(list);
      filteredChapters.assignAll(list);
      isLoading.value = false;
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
  // VIEW COUNT
  // =========================
  void _incrementViewCount() {
    _firestore.collection('novels').doc(novelId).update({
      'viewCount': FieldValue.increment(1),
    });
  }
}
