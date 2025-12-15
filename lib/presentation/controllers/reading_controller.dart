import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:terra_brain/presentation/models/reading_model.dart';
import 'package:terra_brain/presentation/models/novel_item.dart';

class ReadingController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();

  late Rx<Chapter> currentChapter;

  late RxList<Chapter> chapterList = <Chapter>[].obs;
  late Rx<ReadingSettings> readingSettings = ReadingSettings().obs;
  late RxList<Bookmark> bookmarks = <Bookmark>[].obs;
  late Rx<ReadingStats> readingStats = ReadingStats().obs;
  late RxList<ReadingHistory> readingHistory = <ReadingHistory>[].obs;

  late String novelId;
  late String currentChapterId;

  final RxList<Comment> comments = <Comment>[].obs;

  final RxList<NovelItem> recommendedNovels = <NovelItem>[].obs;

  final RxBool isLiked = false.obs;
  final RxString newComment = ''.obs;
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
    loadReadingHistory();
    loadBookmarks();
    fetchRecommendedNovels();
    loadChapterComments();
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

  Future<void> fetchChaptersFromFirestore() async {
    try {
      isLoadingChapters.value = true;
      if (kDebugMode) {
        print('📡 Fetching chapters for novel: $novelId');
      }
      
      final doc = await _firestore
          .collection('novels')
          .doc(novelId)
          .get();

      if (!doc.exists) {
        if (kDebugMode) {
          print('❌ Novel document not found: $novelId');
        }
        isLoadingChapters.value = false;
        return;
      }

      final data = doc.data() ?? {};
      final chaptersData = data['chapters'] as List<dynamic>? ?? [];
      
      if (kDebugMode) {
        print('📡 Found ${chaptersData.length} chapters');
      }

      final chapters = List.generate(chaptersData.length, (index) {
        final chapterData = chaptersData[index] as Map<String, dynamic>;
        return Chapter(
          id: chapterData['id'] ?? '$index',
          title: chapterData['title'] ?? 'Untitled',
          content: chapterData['content'] ?? '',
          author: chapterData['author'] ?? data['authorName'] ?? 'Unknown',
          chapterNumber: chapterData['chapterNumber'] ?? index + 1,
          likeCount: chapterData['likeCount'] ?? 0,
          commentCount: chapterData['commentCount'] ?? 0,
          publishedAt: chapterData['publishedAt'] is Timestamp
              ? (chapterData['publishedAt'] as Timestamp).toDate()
              : DateTime.now(),
          novelId: novelId,
        );
      });

      chapterList.assignAll(chapters);
      
      if (chapters.isNotEmpty) {
        if (currentChapterId.isNotEmpty) {
          final foundChapter = chapters.firstWhereOrNull((ch) => ch.id == currentChapterId);
          if (foundChapter != null) {
            currentChapter.value = foundChapter;
          } else {
            currentChapter.value = chapters.first;
          }
        } else {
          currentChapter.value = chapters.first;
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
          rating: (data['likeCount'] ?? 0).toDouble(),
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

      final doc = await _firestore
          .collection('novels')
          .doc(novelId)
          .get();

      if (!doc.exists) {
        comments.clear();
        return;
      }

      final data = doc.data() ?? {};
      final chaptersData = data['chapters'] as List<dynamic>? ?? [];
      
      final currentChapterData = chaptersData.cast<Map<String, dynamic>>().firstWhereOrNull(
        (ch) => ch['id'] == currentChapter.value.id || ch['title'] == currentChapter.value.title,
      );

      if (currentChapterData == null) {
        comments.clear();
        return;
      }

      final commentsData = currentChapterData['comments'] as List<dynamic>? ?? [];

      final loadedComments = commentsData.map((commentData) {
        final cData = commentData as Map<String, dynamic>;
        return Comment(
          id: cData['id'] ?? '${DateTime.now().millisecondsSinceEpoch}',
          userName: cData['userName'] ?? 'Anonymous',
          userAvatar: cData['userAvatar'] ?? '',
          content: cData['content'] ?? '',
          timestamp: cData['timestamp'] is Timestamp
              ? (cData['timestamp'] as Timestamp).toDate()
              : DateTime.now(),
          likeCount: cData['likeCount'] ?? 0,
        );
      }).toList();

      comments.assignAll(loadedComments);

      if (kDebugMode) {
        print('✅ Loaded ${loadedComments.length} comments from Firestore');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error loading comments: $e');
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
    final chapter = currentChapter.value;
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
  }

  void addComment() {
    if (newComment.value.trim().isEmpty) return;

    try {
      final commentText = newComment.value;
      final timestamp = DateTime.now();

      final newCommentObj = Comment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: 'Anda',
        userAvatar: '',
        content: commentText,
        timestamp: timestamp,
        likeCount: 0,
      );

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

      newComment.value = '';
      Get.snackbar(
        'Berhasil',
        'Komentar berhasil ditambahkan',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      if (kDebugMode) print('❌ Error adding comment: $e');
      Get.snackbar(
        'Error',
        'Gagal menambahkan komentar',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void likeComment(String commentId) {
    final index = comments.indexWhere((comment) => comment.id == commentId);
    if (index != -1) {
      final comment = comments[index];
      comments[index] = Comment(
        id: comment.id,
        userName: comment.userName,
        userAvatar: comment.userAvatar,
        content: comment.content,
        timestamp: comment.timestamp,
        likeCount: comment.likeCount + 1,
      );
    }
  }

  void setNewComment(String value) {
    newComment.value = value;
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
      scrollPosition.value = 0;
      saveReadingProgress(0);
      loadChapterComments();
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
      scrollPosition.value = 0;
      saveReadingProgress(0);
      loadChapterComments();
    } else {
      Get.snackbar('Info', 'Anda sudah di bab pertama');
    }
  }

  void jumpToChapter(Chapter chapter) {
    currentChapter.value = chapter;
    scrollPosition.value = 0;
    saveReadingProgress(0);
    loadChapterComments();
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
}