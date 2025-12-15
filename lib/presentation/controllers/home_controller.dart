import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:video_player/video_player.dart';
import '../models/novel_item.dart';

class HomeController extends GetxController {
  final box = GetStorage();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var selectedImagePath = ''.obs;
  var isImageLoading = false.obs;

  var selectedVideoPath = ''.obs;
  var isVideoPlaying = false.obs;
  VideoPlayerController? videoPlayerController;

  var allNovels = <NovelItem>[].obs;
  var recommendedNovels = <NovelItem>[].obs;
  var newNovels = <NovelItem>[].obs;
  var selectedCategory = ''.obs;
  var searchQuery = ''.obs;

  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    selectedCategory.value = 'All';
    _fetchNovelsFromFirestore();
  }

  @override
  void onClose() {
    videoPlayerController?.dispose();
    searchController.dispose();
    super.onClose();
  }

  void _fetchNovelsFromFirestore() {
    try {
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

        allNovels.assignAll(novels);
        
        // Recommended novels - top rated (first 3)
        final sorted = List<NovelItem>.from(novels);
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        recommendedNovels.assignAll(sorted.take(3).toList());

        // New novels - latest created
        final newest = List<NovelItem>.from(novels);
        newest.sort((a, b) {
          final dateA = _parseDate(a.id);
          final dateB = _parseDate(b.id);
          return dateB.compareTo(dateA);
        });
        newNovels.assignAll(newest.take(3).toList());

        if (kDebugMode) {
          print('✅ Loaded ${novels.length} novels from Firestore');
        }
      });
    } catch (e) {
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

  int _parseDate(String id) {
    // Use document ID as timestamp if available
    try {
      return int.parse(id.substring(0, 10));
    } catch (e) {
      return 0;
    }
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }
}
