import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/novel_item.dart';

class AllNovelController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var novels = <NovelItem>[].obs;
  var filteredNovels = <NovelItem>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchNovelsFromFirestore();
  }

  void _fetchNovelsFromFirestore() {
    try {
      isLoading.value = true;
      _firestore.collection('novels').snapshots().listen((snapshot) {
        final List<NovelItem> novels = snapshot.docs.map((doc) {
          final data = doc.data();
          final chapters = data['chapters'] as List<dynamic>? ?? [];

          return NovelItem(
            id: doc.id,
            title: data['title'] ?? 'Tanpa Judul',
            author: data['authorName'] ?? 'Tidak diketahui',
            coverUrl: data['imageUrl'] ?? '',
            genre: _parseGenre(data['genre']),
            rating: (data['likeCount'] ?? 0).toDouble(),
            chapters: chapters.length,
            readers: data['viewCount'] ?? 0,
            isNew: _isNewNovel(data['createdAt']),
          );
        }).toList();

        this.novels.assignAll(novels);
        filteredNovels.assignAll(novels);
        isLoading.value = false;

        if (kDebugMode) {
          print('✅ Loaded ${novels.length} novels from Firestore');
        }
      });
    } catch (e) {
      isLoading.value = false;
      if (kDebugMode) {
        print('❌ Error fetching novels: $e');
      }
    }
  }

  List<String> _parseGenre(dynamic genre) {
    if (genre == null) return ['Unknown'];
    if (genre is String) return [genre];
    if (genre is List) {
      return List<String>.from(genre).where((g) => g.isNotEmpty).toList();
    }
    return ['Unknown'];
  }

  bool _isNewNovel(dynamic createdAt) {
    if (createdAt == null) return false;
    try {
      DateTime created;
      if (createdAt is Timestamp) {
        created = createdAt.toDate();
      } else if (createdAt is DateTime) {
        created = createdAt;
      } else {
        return false;
      }
      final difference = DateTime.now().difference(created).inDays;
      return difference <= 7;
    } catch (e) {
      return false;
    }
  }

  void filterNovel(String keyword) {
    if (keyword.isEmpty) {
      filteredNovels.assignAll(novels);
    } else {
      filteredNovels.assignAll(
        novels.where(
          (e) => e.title.toLowerCase().contains(keyword.toLowerCase()) ||
              e.author.toLowerCase().contains(keyword.toLowerCase()),
        ),
      );
    }
  }
}
