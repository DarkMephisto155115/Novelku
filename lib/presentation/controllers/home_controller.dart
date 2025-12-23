import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:video_player/video_player.dart';
import '../models/novel_item.dart';

import 'package:terra_brain/presentation/models/author_model.dart';

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

  var searchResults = <NovelItem>[].obs;
  var authorSearchResults = <Author>[].obs;

  @override
  void onInit() {
    super.onInit();
    selectedCategory.value = 'All';
    _fetchNovelsFromFirestore();
    
    // Listen to search query changes
    debounce(searchQuery, (query) {
      _performSearch(query);
    }, time: const Duration(milliseconds: 500));
  }

  void _performSearch(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      authorSearchResults.clear();
      return;
    }

    final lowerQuery = query.toLowerCase();
    
    // Search Novels
    final novelResults = allNovels.where((novel) {
      final titleMatch = novel.title.toLowerCase().contains(lowerQuery);
      final authorMatch = novel.author.toLowerCase().contains(lowerQuery);
      return titleMatch || authorMatch;
    }).toList();

    searchResults.assignAll(novelResults);

    // Search Authors
    try {
      final userSnap = await _firestore.collection('users').get();
      final authors = userSnap.docs.map((doc) {
        final data = doc.data();
        return Author(
          id: doc.id,
          name: data['name'] ?? '-',
          username: data['username'] ?? data['name'] ?? '-',
          email: data['email'] ?? '',
          biodata: data['biodata'] ?? '',
          novelCount: data['novelCount'] ?? 0,
          followerCount: data['followers'] ?? 0,
          category: '',
          isNew: false,
          isPopular: false,
          isPremium: data['is_premium'] ?? false,
          imageUrl: data['imageUrl'],
        );
      }).where((author) {
        return author.name.toLowerCase().contains(lowerQuery) ||
               author.username.toLowerCase().contains(lowerQuery);
      }).toList();

      authorSearchResults.assignAll(authors);
    } catch (e) {
      if (kDebugMode) {
        print('Error searching authors: $e');
      }
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    searchResults.clear();
    authorSearchResults.clear();
  }

  @override
  void onClose() {
    videoPlayerController?.dispose();
    searchController.dispose();
    super.onClose();
  }

  void _fetchNovelsFromFirestore() {
    try {
      _firestore.collection('novels').snapshots().listen((snapshot) async {
        final List<NovelItem> novels = [];
        
        for (var doc in snapshot.docs) {
          final data = doc.data();
          
          // Filter out drafts
          if (data['status'] == 'Draft') continue;

          final authorName = data['authorName'] ?? 'Tidak diketahui';

          String? authorId;
          try {
            final userQuery = await _firestore
                .collection('users')
                .where('name', isEqualTo: authorName)
                .limit(1)
                .get();
            
            if (userQuery.docs.isNotEmpty) {
              authorId = userQuery.docs.first.id;
            }
          } catch (e) {
            if (kDebugMode) {
              print('⚠️ Error fetching author ID for $authorName: $e');
            }
          }

          int publishedChapterCount = 0;
          try {
            final chaptersSnap = await doc.reference
                .collection('chapters')
                .get();
            
            publishedChapterCount = chaptersSnap.docs
                .where((ch) {
                  final isPublished = ch['isPublished'];
                  return isPublished != null && 
                      (isPublished.toString().toLowerCase() == 'published' || 
                       isPublished.toString() == 'true');
                })
                .length;
          } catch (e) {
            if (kDebugMode) {
              print('⚠️ Error fetching chapters for ${data['title']}: $e');
            }
          }

          DateTime? createdAtDate;
          if (data['createdAt'] is Timestamp) {
            createdAtDate = (data['createdAt'] as Timestamp).toDate();
          } else if (data['createdAt'] is DateTime) {
            createdAtDate = data['createdAt'] as DateTime;
          }

          novels.add(NovelItem(
            id: doc.id,
            title: data['title'] ?? 'Tanpa Judul',
            author: authorName,
            authorId: authorId,
            coverUrl: data['imageUrl'] ?? '',
            genre: _parseGenre(data['genre']),
            likeCount: (data['likeCount'] ?? 0) as int,
            chapters: publishedChapterCount,
            readers: data['viewCount'] ?? 0,
            isNew: _isNewNovel(data['createdAt']),
            createdAt: createdAtDate ?? DateTime.now(),
          ));
        }

        allNovels.assignAll(novels);
        
        // Recommended novels - top liked (first 3)
        final sorted = List<NovelItem>.from(novels);
        sorted.sort((a, b) => b.likeCount.compareTo(a.likeCount));
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

  List<NovelItem> filterByTrending(List<NovelItem> novels) {
    final sorted = List<NovelItem>.from(novels);
    sorted.sort((a, b) {
      final scoreA = (a.likeCount * 0.6) + (a.readers * 0.4);
      final scoreB = (b.likeCount * 0.6) + (b.readers * 0.4);
      return scoreB.compareTo(scoreA);
    });
    return sorted;
  }

  List<NovelItem> filterByLatest(List<NovelItem> novels) {
    final sorted = List<NovelItem>.from(novels);
    sorted.sort((a, b) {
      final dateA = a.createdAt ?? DateTime.now();
      final dateB = b.createdAt ?? DateTime.now();
      return dateB.compareTo(dateA);
    });
    return sorted;
  }

  List<NovelItem> filterByBestselling(List<NovelItem> novels) {
    final sorted = List<NovelItem>.from(novels);
    sorted.sort((a, b) => b.readers.compareTo(a.readers));
    return sorted;
  }
}
