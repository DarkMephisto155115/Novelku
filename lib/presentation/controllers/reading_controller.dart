import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:terra_brain/presentation/models/reading_model.dart';
import 'package:terra_brain/presentation/models/novel_item.dart';
import 'package:terra_brain/presentation/controllers/write/writing_controller.dart';

class ReadingController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GetStorage _storage = GetStorage();

  late Rx<Chapter> currentChapter;

  late RxList<Chapter> chapterList = <Chapter>[].obs;
  late Rx<ReadingSettings> readingSettings = ReadingSettings().obs;
  late RxList<Bookmark> bookmarks = <Bookmark>[].obs;
  late Rx<ReadingStats> readingStats = ReadingStats().obs;
  late RxList<ReadingHistory> readingHistory = <ReadingHistory>[].obs;

  late String novelId;
  late String currentChapterId;
  late String authorId;
  late RxString novelAuthor = ''.obs;
  late RxBool isFollowingAuthor = false.obs;

  final RxList<Comment> comments = <Comment>[].obs;
  final RxBool isCommentsExpanded = false.obs;
  final RxInt commentsDisplayCount = 3.obs;
  final RxList<String> likedCommentIds = <String>[].obs;

  final RxList<NovelItem> recommendedNovels = <NovelItem>[].obs;

  final RxBool isLiked = false.obs;
  final RxBool isLikeProcessing = false.obs;
  final RxBool isFavorite = false.obs;
  final RxBool isFavoriteProcessing = false.obs;
  final RxString newComment = ''.obs;
  final TextEditingController commentController = TextEditingController();
  final RxBool isLoadingChapters = false.obs;
  final RxInt scrollPosition = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadReadingSettings();
    _loadReadingStats();
    novelId = Get.arguments?['novelId'] ?? '';
    currentChapterId = Get.arguments?['chapterId'] ?? '';
    
    if (kDebugMode) {
      print('📖 ReadingController onInit - novelId: $novelId, chapterId: $currentChapterId');
    }
    
    currentChapter = Chapter(
      id: '',
      title: 'Loading...',
      content: '',
      author: '',
      chapterNumber: 0,
      likeCount: 0,
      commentCount: 0,
      publishedAt: DateTime.now(),
    ).obs;

    if (novelId.isNotEmpty) {
      _initializeReading();
    }
  }

  Future<void> _initializeReading() async {
    await fetchChaptersFromFirestore();
    // _loadChapterLikeState();
    loadReadingHistory();
    _incrementViewCount();
    loadBookmarks();
    fetchRecommendedNovels();
    _loadLikedComments();
    loadChapterComments();
    _loadFollowState();
    _loadFavoriteState();
  }

  void _loadReadingSettings() {
    try {
      final settingsMap = _storage.read('reading_settings');
      if (settingsMap != null) {
        readingSettings.value = ReadingSettings.fromMap(
            Map<String, dynamic>.from(settingsMap as Map));
      }
    } catch (e) {
      if (kDebugMode) print('Error loading reading settings: $e');
    }
    _syncWithGlobalTheme();
  }

  void _syncWithGlobalTheme() {
    try {
      final writingController = Get.find<WritingController>();
      final isDarkMode = writingController.themeController.isDarkMode;
      final currentTheme = readingSettings.value.theme;
      
      final newTheme = isDarkMode ? ReadingTheme.dark : ReadingTheme.light;
      if (currentTheme != newTheme) {
        readingSettings.value = readingSettings.value.copyWith(theme: newTheme);
        _saveReadingSettings();
      }
    } catch (e) {
      if (kDebugMode) print('Error syncing with global theme: $e');
    }
  }

  void _saveReadingSettings() {
    try {
      _storage.write('reading_settings', readingSettings.value.toMap());
    } catch (e) {
      if (kDebugMode) print('Error saving reading settings: $e');
    }
  }

  void _loadReadingStats() {
    try {
      final statsMap = _storage.read('reading_stats');
      if (statsMap != null) {
        readingStats.value = ReadingStats.fromMap(
            Map<String, dynamic>.from(statsMap as Map));
      }
    } catch (e) {
      if (kDebugMode) print('Error loading reading stats: $e');
    }
  }

  void _saveReadingStats() {
    try {
      _storage.write('reading_stats', readingStats.value.toMap());
    } catch (e) {
      if (kDebugMode) print('Error saving reading stats: $e');
    }
  }

  void _loadLikedComments() {
    try {
      final List<dynamic>? storedLikes = _storage.read('liked_comments');
      if (storedLikes != null) {
        likedCommentIds.assignAll(storedLikes.cast<String>());
      }
    } catch (e) {
      if (kDebugMode) print('Error loading liked comments: $e');
    }
  }

  void _saveLikedComments() {
    try {
      _storage.write('liked_comments', likedCommentIds.toList());
    } catch (e) {
      if (kDebugMode) print('Error saving liked comments: $e');
    }
  }

  Future<void> fetchChaptersFromFirestore() async {
    try {
      isLoadingChapters.value = true;
      if (kDebugMode) {
        print('📡 Fetching chapters for novel: $novelId');
      }
      
      final novelDoc = await _firestore
          .collection('novels')
          .doc(novelId)
          .get();

      if (!novelDoc.exists) {
        if (kDebugMode) {
          print('❌ Novel document not found: $novelId');
        }
        isLoadingChapters.value = false;
        return;
      }

      final novelData = novelDoc.data() ?? {};
      novelAuthor.value = novelData['authorName'] ?? 'Unknown';
      authorId = novelData['authorId'] ?? '';

      final chaptersSnapshot = await _firestore
          .collection('novels')
          .doc(novelId)
          .collection('chapters')
          .orderBy('chapter')
          .get();

      if (kDebugMode) {
        print('📡 Found ${chaptersSnapshot.docs.length} chapters');
      }

      final chapters = chaptersSnapshot.docs.map((doc) {
        final chapterData = doc.data();
        return Chapter(
          id: doc.id,
          title: chapterData['title'] ?? 'Untitled',
          content: chapterData['content'] ?? '',
          author: chapterData['author'] ?? novelData['authorName'] ?? 'Unknown',
          chapterNumber: chapterData['chapter'] ?? 0,
          likeCount: chapterData['likeCount'] ?? 0,
          commentCount: chapterData['commentCount'] ?? 0,
          publishedAt: chapterData['createdAt'] is Timestamp
              ? (chapterData['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
          novelId: novelId,
        );
      }).toList();

      chapterList.assignAll(chapters);
      
      if (chapters.isNotEmpty) {
        if (currentChapterId.isNotEmpty) {
          final foundChapter = chapters.firstWhereOrNull((ch) => ch.id == currentChapterId);
          if (foundChapter != null) {
            currentChapter.value = foundChapter;
            _loadChapterLikeState();
          } else {
            currentChapter.value = chapters.first;
            _loadChapterLikeState();
          }
        } else {
          currentChapter.value = chapters.first;
          _loadChapterLikeState();
        }
      }
      
      isLoadingChapters.value = false;

      if (kDebugMode) {
        print('✅ Loaded ${chapters.length} chapters from Firestore');
      }
    } catch (e) {
      isLoadingChapters.value = false;
      if (kDebugMode) print('❌ Error fetching chapters: $e');
    }
  }

  Future<void> fetchRecommendedNovels() async {
    try {
      final snapshot = await _firestore
          .collection('novels')
          .limit(3)
          .get();

      final novels = snapshot.docs.map((doc) {
        final data = doc.data();
        final chapters = data['chapters'] as List<dynamic>? ?? [];
        
        return NovelItem(
          id: doc.id,
          title: data['title'] ?? 'Untitled',
          author: data['authorName'] ?? 'Unknown',
          coverUrl: data['imageUrl'] ?? '',
          genre: _parseGenre(data['genre']),
          likeCount: (data['likeCount'] ?? 0) as int,
          chapters: chapters.length,
          readers: data['viewCount'] ?? 0,
          isNew: false,
        );
      }).toList();

      recommendedNovels.assignAll(novels);

      if (kDebugMode) {
        print('✅ Loaded ${novels.length} recommended novels from Firestore');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error fetching recommended novels: $e');
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

  Future<void> loadChapterComments() async {
    try {
      if (novelId.isEmpty || currentChapter.value.id.isEmpty) {
        comments.clear();
        return;
      }

      final commentsSnapshot = await _firestore
          .collection('novels')
          .doc(novelId)
          .collection('chapters')
          .doc(currentChapter.value.id)
          .collection('komentar')
          .orderBy('timestamp', descending: true)
          .get();

      final loadedComments = commentsSnapshot.docs.map((doc) {
        final cData = doc.data();
        return Comment(
          id: doc.id,
          userId: cData['userId'] ?? '',
          userName: cData['userName'] ?? 'Anonymous',
          userAvatar: cData['userAvatar'] ?? '',
          content: cData['content'] ?? '',
          timestamp: cData['timestamp'] is Timestamp
              ? (cData['timestamp'] as Timestamp).toDate()
              : DateTime.now(),
          likeCount: cData['likeCount'] ?? 0,
          isPremium: cData['isPremium'] ?? false,
          isLiked: likedCommentIds.contains(doc.id),
        );
      }).toList();

      loadedComments.sort((a, b) => b.likeCount.compareTo(a.likeCount));
      comments.assignAll(loadedComments);

      if (kDebugMode) {
        print('✅ Loaded ${loadedComments.length} komentar from Firestore');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error loading komentar: $e');
    }
  }

  Future<void> loadReadingHistory() async {
    try {
      final historyList = _storage.read('reading_history_$novelId') as List? ?? [];
      final history = historyList
          .map((item) => ReadingHistory.fromMap(Map<String, dynamic>.from(item)))
          .toList();
      readingHistory.assignAll(history);
    } catch (e) {
      if (kDebugMode) print('Error loading reading history: $e');
    }
  }

  Future<void> saveReadingProgress(int position) async {
    try {
      scrollPosition.value = position;
      final history = ReadingHistory(
        id: '${novelId}_${currentChapter.value.id}',
        novelId: novelId,
        chapterId: currentChapter.value.id,
        chapterTitle: currentChapter.value.title,
        scrollPosition: position,
        lastReadAt: DateTime.now(),
      );

      final historyList =
          readingHistory.where((h) => h.chapterId != history.chapterId).toList();
      historyList.add(history);
      readingHistory.assignAll(historyList);

      await _storage.write(
        'reading_history_$novelId',
        historyList.map((h) => h.toMap()).toList(),
      );

      _updateReadingStats();
    } catch (e) {
      if (kDebugMode) print('Error saving reading progress: $e');
    }
  }

  void _updateReadingStats() {
    final stats = readingStats.value;
    readingStats.value = ReadingStats(
      totalBooksRead: stats.totalBooksRead,
      totalChaptersRead: readingHistory.length,
      totalWordsRead: stats.totalWordsRead + currentChapter.value.wordCount,
      totalTimeSpent: stats.totalTimeSpent + Duration(minutes: 5),
      lastReadAt: DateTime.now(),
      currentStreak: _calculateStreak(),
    );
    _saveReadingStats();
  }

  int _calculateStreak() {
    if (readingStats.value.lastReadAt == null) return 1;
    final lastRead = readingStats.value.lastReadAt!;
    final now = DateTime.now();
    final difference = now.difference(lastRead).inDays;

    if (difference == 0) return readingStats.value.currentStreak;
    if (difference == 1) return readingStats.value.currentStreak + 1;
    return 1;
  }

  Future<void> loadBookmarks() async {
    try {
      final bookmarkList = _storage.read('bookmarks_$novelId') as List? ?? [];
      final bms = bookmarkList
          .map((item) => Bookmark.fromMap(Map<String, dynamic>.from(item)))
          .toList();
      bookmarks.assignAll(bms);
    } catch (e) {
      if (kDebugMode) print('Error loading bookmarks: $e');
    }
  }

  Future<void> addBookmark(String note) async {
    try {
      final bookmark = Bookmark(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chapterId: currentChapter.value.id,
        novelId: novelId,
        position: scrollPosition.value,
        note: note,
      );

      bookmarks.add(bookmark);
      await _storage.write(
        'bookmarks_$novelId',
        bookmarks.map((b) => b.toMap()).toList(),
      );

      Get.snackbar('Bookmark Ditambahkan', note.isEmpty ? 'Chapter ditandai' : note);
    } catch (e) {
      if (kDebugMode) print('Error adding bookmark: $e');
    }
  }

  Future<void> removeBookmark(String bookmarkId) async {
    try {
      bookmarks.removeWhere((b) => b.id == bookmarkId);
      await _storage.write(
        'bookmarks_$novelId',
        bookmarks.map((b) => b.toMap()).toList(),
      );
    } catch (e) {
      if (kDebugMode) print('Error removing bookmark: $e');
    }
  }

  bool isChapterBookmarked(String chapterId) {
    return bookmarks.any((b) => b.chapterId == chapterId);
  }

  void updateFontSize(double size) {
    readingSettings.value = readingSettings.value.copyWith(fontSize: size);
    _saveReadingSettings();
  }

  void updateLineHeight(double height) {
    readingSettings.value = readingSettings.value.copyWith(lineHeight: height);
    _saveReadingSettings();
  }

  void updateTheme(ReadingTheme theme) {
    readingSettings.value = readingSettings.value.copyWith(theme: theme);
    _saveReadingSettings();
  }

  void updateTextAlignment(TextAlignment alignment) {
    readingSettings.value = readingSettings.value.copyWith(textAlignment: alignment);
    _saveReadingSettings();
  }

  void toggleLike() {
    if (isLikeProcessing.value) return;
    
    isLikeProcessing.value = true;
    final chapter = currentChapter.value;
    final increment = isLiked.value ? -1 : 1;
    
    if (isLiked.value) {
      currentChapter.value = Chapter(
        id: chapter.id,
        title: chapter.title,
        content: chapter.content,
        author: chapter.author,
        chapterNumber: chapter.chapterNumber,
        likeCount: chapter.likeCount - 1,
        commentCount: chapter.commentCount,
        publishedAt: chapter.publishedAt,
        novelId: chapter.novelId,
        imageUrl: chapter.imageUrl,
      );
    } else {
      currentChapter.value = Chapter(
        id: chapter.id,
        title: chapter.title,
        content: chapter.content,
        author: chapter.author,
        chapterNumber: chapter.chapterNumber,
        likeCount: chapter.likeCount + 1,
        commentCount: chapter.commentCount,
        publishedAt: chapter.publishedAt,
        novelId: chapter.novelId,
        imageUrl: chapter.imageUrl,
      );
    }
    isLiked.value = !isLiked.value;
    _saveChapterLikeState();
    _updateChapterLikeCount(increment);
    isLikeProcessing.value = false;
  }
  
  void _loadChapterLikeState() {
    try {
      final liked = _storage.read('chapter_liked_${currentChapter.value.id}') ?? false;
      isLiked.value = liked as bool;
    } catch (e) {
      if (kDebugMode) print('Error loading chapter like state: $e');
      isLiked.value = false;
    }
  }

  void _saveChapterLikeState() {
    try {
      _storage.write('chapter_liked_${currentChapter.value.id}', isLiked.value);
    } catch (e) {
      if (kDebugMode) print('Error saving chapter like state: $e');
    }
  }

  Future<void> _refreshCurrentChapterData() async {
    try {
      if (novelId.isEmpty || currentChapter.value.id.isEmpty) return;
      
      final chapterDoc = await _firestore
          .collection('novels')
          .doc(novelId)
          .collection('chapters')
          .doc(currentChapter.value.id)
          .get();

      if (!chapterDoc.exists) return;

      final chapterData = chapterDoc.data() ?? {};
      final novelDoc = await _firestore.collection('novels').doc(novelId).get();
      final novelData = novelDoc.data() ?? {};

      currentChapter.value = Chapter(
        id: chapterDoc.id,
        title: chapterData['title'] ?? currentChapter.value.title,
        content: currentChapter.value.content,
        author: chapterData['author'] ?? currentChapter.value.author,
        chapterNumber: chapterData['chapter'] ?? currentChapter.value.chapterNumber,
        likeCount: chapterData['likeCount'] ?? currentChapter.value.likeCount,
        commentCount: chapterData['commentCount'] ?? currentChapter.value.commentCount,
        publishedAt: chapterData['createdAt'] is Timestamp
            ? (chapterData['createdAt'] as Timestamp).toDate()
            : currentChapter.value.publishedAt,
        novelId: novelId,
      );
    } catch (e) {
      if (kDebugMode) print('❌ Error refreshing chapter data: $e');
    }
  }

  void _updateChapterLikeCount(int increment) {
    try {
      if (novelId.isEmpty || currentChapter.value.id.isEmpty) return;
      
      _firestore
          .collection('novels')
          .doc(novelId)
          .collection('chapters')
          .doc(currentChapter.value.id)
          .update({
            'likeCount': FieldValue.increment(increment),
          }).then((_) {
            _firestore.collection('novels').doc(novelId).update({
              'likeCount': FieldValue.increment(increment),
            }).then((_) {
              if (kDebugMode) {
                print('✅ Chapter like count updated and novel likeCount incremented');
              }
            }).catchError((e) {
              if (kDebugMode) {
                print('❌ Error updating novel like count: $e');
              }
            });
          }).catchError((e) {
            if (kDebugMode) {
              print('❌ Error updating chapter like count: $e');
            }
          });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in _updateChapterLikeCount: $e');
      }
    }
  }

  void addComment() async {
    if (newComment.value.trim().isEmpty) return;

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        Get.snackbar(
          'Error',
          'Anda harus login terlebih dahulu',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
      
      final userData = userDoc.data() ?? {};
      final userName = userData['name'] ?? userData['username'] ?? 'Anonymous';
      final userAvatar = userData['imageUrl'] ?? '';
      final isPremium = userData['is_premium'] ?? false;

      final commentText = newComment.value;
      final timestamp = DateTime.now();
      final commentId = DateTime.now().millisecondsSinceEpoch.toString();

      final newCommentObj = Comment(
        id: commentId,
        userId: currentUser.uid,
        userName: userName,
        userAvatar: userAvatar,
        content: commentText,
        timestamp: timestamp,
        likeCount: 0,
        isPremium: isPremium,
      );

      _firestore
          .collection('novels')
          .doc(novelId)
          .collection('chapters')
          .doc(currentChapter.value.id)
          .collection('komentar')
          .doc(commentId)
          .set({
            'userId': currentUser.uid,
            'userName': userName,
            'userAvatar': userAvatar,
            'content': commentText,
            'timestamp': FieldValue.serverTimestamp(),
            'likeCount': 0,
            'isPremium': isPremium,
          }).then((_) {
            comments.insert(0, newCommentObj);

            final chapter = currentChapter.value;
            currentChapter.value = Chapter(
              id: chapter.id,
              title: chapter.title,
              content: chapter.content,
              author: chapter.author,
              chapterNumber: chapter.chapterNumber,
              likeCount: chapter.likeCount,
              commentCount: chapter.commentCount + 1,
              publishedAt: chapter.publishedAt,
              novelId: chapter.novelId,
              imageUrl: chapter.imageUrl,
            );

            _firestore
                .collection('novels')
                .doc(novelId)
                .collection('chapters')
                .doc(currentChapter.value.id)
                .update({
                  'commentCount': FieldValue.increment(1),
                });

            newComment.value = '';
            commentController.clear();
            // Get.snackbar(
            //   'Berhasil',
            //   'Komentar berhasil ditambahkan',
            //   snackPosition: SnackPosition.BOTTOM,
            // );
          }).catchError((e) {
            if (kDebugMode) print('❌ Error saving komentar: $e');
            Get.snackbar(
              'Error',
              'Gagal menambahkan komentar',
              snackPosition: SnackPosition.BOTTOM,
            );
          });
    } catch (e) {
      if (kDebugMode) print('❌ Error adding komentar: $e');
      Get.snackbar(
        'Error',
        'Gagal menambahkan komentar',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> likeComment(String commentId) async {
    final index = comments.indexWhere((comment) => comment.id == commentId);
    if (index != -1) {
      final comment = comments[index];
      final isLiked = likedCommentIds.contains(commentId);
      
      if (isLiked) {
        // Unlike
        likedCommentIds.remove(commentId);
        final updatedComment = comment.copyWith(
          likeCount: comment.likeCount > 0 ? comment.likeCount - 1 : 0,
          isLiked: false,
        );
        comments[index] = updatedComment;
        _saveLikedComments();

        try {
          await _firestore
              .collection('novels')
              .doc(novelId)
              .collection('chapters')
              .doc(currentChapter.value.id)
              .collection('komentar')
              .doc(commentId)
              .update({
                'likeCount': FieldValue.increment(-1),
              });
        } catch (e) {
          if (kDebugMode) print('❌ Error unliking komentar: $e');
          // Revert if error
          comments[index] = comment;
          likedCommentIds.add(commentId);
          _saveLikedComments();
        }
      } else {
        // Like
        likedCommentIds.add(commentId);
        final updatedComment = comment.copyWith(
          likeCount: comment.likeCount + 1,
          isLiked: true,
        );
        comments[index] = updatedComment;
        _saveLikedComments();

        try {
          await _firestore
              .collection('novels')
              .doc(novelId)
              .collection('chapters')
              .doc(currentChapter.value.id)
              .collection('komentar')
              .doc(commentId)
              .update({
                'likeCount': FieldValue.increment(1),
              });

          if (kDebugMode) {
            print('✅ Komentar like count updated');
          }
        } catch (e) {
          if (kDebugMode) print('❌ Error liking komentar: $e');
          // Revert if error
          comments[index] = comment;
          likedCommentIds.remove(commentId);
          _saveLikedComments();
        }
      }
    }
  }

  void setNewComment(String value) {
    newComment.value = value;
  }

  void toggleCommentsExpanded() {
    isCommentsExpanded.value = !isCommentsExpanded.value;
  }

  List<Comment> getDisplayedComments() {
    if (isCommentsExpanded.value) {
      return comments;
    }
    return comments.take(commentsDisplayCount.value).toList();
  }

  int getRemainingCommentsCount() {
    if (comments.length <= commentsDisplayCount.value) {
      return 0;
    }
    return comments.length - commentsDisplayCount.value;
  }

  void navigateToNextChapter() {
    if (chapterList.isEmpty) {
      Get.snackbar('Info', 'Tidak ada bab berikutnya');
      return;
    }

    final currentIndex =
        chapterList.indexWhere((ch) => ch.id == currentChapter.value.id);
    if (currentIndex < chapterList.length - 1) {
      currentChapter.value = chapterList[currentIndex + 1];
      _loadChapterLikeState();
      scrollPosition.value = 0;
      saveReadingProgress(0);
      loadChapterComments();
      isCommentsExpanded.value = false;
    } else {
      Get.snackbar('Info', 'Anda sudah di bab terakhir');
    }
  }

  void navigateToPreviousChapter() {
    if (chapterList.isEmpty) {
      Get.snackbar('Info', 'Tidak ada bab sebelumnya');
      return;
    }

    final currentIndex =
        chapterList.indexWhere((ch) => ch.id == currentChapter.value.id);
    if (currentIndex > 0) {
      currentChapter.value = chapterList[currentIndex - 1];
      _loadChapterLikeState();
      scrollPosition.value = 0;
      saveReadingProgress(0);
      loadChapterComments();
      isCommentsExpanded.value = false;
    } else {
      Get.snackbar('Info', 'Anda sudah di bab pertama');
    }
  }

  void jumpToChapter(Chapter chapter) {
    currentChapter.value = chapter;
    _loadChapterLikeState();
    scrollPosition.value = 0;
    saveReadingProgress(0);
    loadChapterComments();
    isCommentsExpanded.value = false;
  }

  String formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'baru saja';
    if (difference.inHours < 1) return '${difference.inMinutes} menit lalu';
    if (difference.inDays < 1) return '${difference.inHours} jam lalu';
    if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    }
    if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} minggu lalu';
    }
    return '${(difference.inDays / 30).floor()} bulan lalu';
  }

  String formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '$hours jam $minutes menit';
    }
    return '$minutes menit';
  }

  void _incrementViewCount() {
    try {
      if (novelId.isEmpty) return;
      
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

  Future<void> _loadFollowState() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null || authorId.isEmpty) {
        isFollowingAuthor.value = false;
        return;
      }

      final doc = await _firestore
          .collection('users')
          .doc(authorId)
          .collection('followers')
          .doc(currentUser.uid)
          .get();

      isFollowingAuthor.value = doc.exists;
    } catch (e) {
      if (kDebugMode) print('Error loading follow state: $e');
      isFollowingAuthor.value = false;
    }
  }

  Future<void> followAuthor() async {
    if (isFollowingAuthor.value) return;

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      Get.snackbar(
        'Error',
        'Anda harus login terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (authorId.isEmpty) {
      Get.snackbar(
        'Error',
        'Author ID tidak ditemukan',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final batch = _firestore.batch();

      final authorRef = _firestore.collection('users').doc(authorId);
      final followerRef =
          authorRef.collection('followers').doc(currentUser.uid);

      final followingRef = _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('following')
          .doc(authorId);

      batch.set(followerRef, {
        'createdAt': FieldValue.serverTimestamp(),
      });
      batch.set(followingRef, {
        'createdAt': FieldValue.serverTimestamp(),
      });
      batch.update(authorRef, {
        'followers': FieldValue.increment(1),
      });
      batch.update(_firestore.collection('users').doc(currentUser.uid), {
        'following': FieldValue.increment(1),
      });

      await batch.commit();

      isFollowingAuthor.value = true;
      // Get.snackbar(
      //   'Mengikuti',
      //   'Anda sekarang mengikuti ${novelAuthor.value}',
      //   snackPosition: SnackPosition.BOTTOM,
      // );

      if (kDebugMode) {
        print('✅ Successfully followed author: $authorId');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error following author: $e');
      Get.snackbar(
        'Error',
        'Gagal mengikuti penulis',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

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
      final novelDoc = await _firestore.collection('novels').doc(novelId).get();
      if (!novelDoc.exists) return;

      final novelData = novelDoc.data() ?? {};

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
      Get.snackbar(
        'Berhasil',
        '${novelData['title'] ?? 'Novel'} ditambahkan ke favorit',
        snackPosition: SnackPosition.BOTTOM,
      );

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
      final novelDoc = await _firestore.collection('novels').doc(novelId).get();
      if (!novelDoc.exists) return;

      final novelData = novelDoc.data() ?? {};

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(novelId)
          .delete();

      isFavorite.value = false;
      Get.snackbar(
        'Berhasil',
        '${novelData['title'] ?? 'Novel'} dihapus dari favorit',
        snackPosition: SnackPosition.BOTTOM,
      );

      if (kDebugMode) {
        print('✅ Novel removed from favorites: $novelId');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error removing from favorites: $e');
      rethrow;
    }
  }
}