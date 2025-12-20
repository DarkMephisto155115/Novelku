import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/novel_model.dart';
import '../models/novel_item.dart';

class NovelChaptersController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String novelId;
  
  var novel = Rx<NovelItem?>(null);
  var chapters = <Chapter>[].obs;
  var isLoading = true.obs;
  var searchQuery = ''.obs;

  var filteredChapters = <Chapter>[].obs;

  @override
  void onInit() {
    super.onInit();
    novelId = Get.arguments?['novelId'] ?? '';
    
    if (kDebugMode) {
      print('📚 NovelChaptersController onInit - novelId: $novelId');
    }

    if (novelId.isNotEmpty) {
      _fetchNovelAndChapters();
      _incrementViewCount();
    }
  }

  void _fetchNovelAndChapters() {
    try {
      isLoading.value = true;

      _firestore.collection('novels').doc(novelId).snapshots().listen((novelDoc) {
        if (novelDoc.exists) {
          final data = novelDoc.data()!;
          final novelData = Novel.fromJson(data, novelDoc.id);

          novel.value = NovelItem(
            id: novelDoc.id,
            title: novelData.title,
            author: novelData.authorName ?? 'Tidak diketahui',
            authorId: novelData.authorId,
            coverUrl: novelData.imageUrl ?? '',
            genre: _parseGenre(novelData.genre),
            likeCount: novelData.likeCount,
            chapters: novelData.chapters.length,
            readers: novelData.viewCount,
            description: novelData.description,
          );

          _processChapters(novelData.chapters);
        }
      });
    } catch (e) {
      isLoading.value = false;
      if (kDebugMode) {
        print('❌ Error fetching novel and chapters: $e');
      }
    }
  }

  void _processChapters(List<Chapter> novelChapters) {
    try {
      final fetchedChapters = <Chapter>[...novelChapters];
      
      chapters.assignAll(fetchedChapters);
      filteredChapters.assignAll(fetchedChapters);
      isLoading.value = false;

      if (kDebugMode) {
        print('✅ Loaded ${fetchedChapters.length} chapters');
      }
    } catch (e) {
      isLoading.value = false;
      if (kDebugMode) {
        print('❌ Error processing chapters: $e');
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

  void filterChapters(String keyword) {
    if (keyword.isEmpty) {
      filteredChapters.assignAll(chapters);
      searchQuery.value = '';
    } else {
      searchQuery.value = keyword;
      filteredChapters.assignAll(
        chapters.where(
          (chapter) => chapter.title.toLowerCase().contains(keyword.toLowerCase()) ||
              chapter.chapterNumber.toString().contains(keyword),
        ),
      );
    }
  }

  void _incrementViewCount() {
    try {
      _firestore.collection('novels').doc(novelId).update({
        'viewCount': FieldValue.increment(1),
      }).then((_) {
        if (kDebugMode) {
          print('✅ View count incremented for novel: $novelId');
        }
      }).catchError((e) {
        if (kDebugMode) {
          print('❌ Error incrementing view count: $e');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in _incrementViewCount: $e');
      }
    }
  }
}
