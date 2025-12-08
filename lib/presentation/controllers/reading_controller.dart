import 'package:get/get.dart';
import 'package:terra_brain/presentation/models/reading_model.dart';

class ReadingController extends GetxController {
  final Rx<Chapter> currentChapter = Chapter(
    id: '1',
    title: 'Báb 1: Awal Perjalanan',
    content: '''Di sebuah desa kecil yang terletak di kaki gunung, hiduplah seorang pemuda bernama Arya. Sejak kecil, ia selalu bermimpi untuk menjelajahi dunia yang luas di luar desanya.

Suatu pagi, ketika matahari baru saja terbit, Arya memutuskan bahwa saatnya telah tiba untuk memulai petualangannya. Ia mengemas barang-barangnya yang sederhana ke dalam tas ransel tua milik ayahnya.

"Arya, apakah kamu yakin dengan keputusan ini?" tanya ibunya dengan wajah khawatir.

"Ibu, saya harus pergi. Ada sesuatu di luar sana yang menunggu saya." jawab Arya dengan tekad penuh keyakinan.

Dengan restu keluarganya, Arya memulai perjalanan yang akan mengubah hidupnya selamanya. Ia tidak tahu bahwa petualangan ini akan membawanya pada takdir yang jauh lebih besar dari yang pernah ia bayangkan.

Langkah pertamanya keluar dari desa adalah langkah menuju masa depan yang penuh misteri dan keajaiban. Di luar sana, petualangan menanti...''',
    author: 'Ahmad Rizki',
    chapterNumber: 1,
    likeCount: 342,
    commentCount: 2,
    publishedAt: DateTime.now().subtract(Duration(days: 1)),
  ).obs;

  final RxList<Comment> comments = <Comment>[
    Comment(
      id: '1',
      userName: 'Pembaca 123',
      userAvatar: '',
      content: 'Chapter ini sangat menarik! Tidak sabar untuk chapter selanjutnya!',
      timestamp: DateTime.now().subtract(Duration(hours: 2)),
      likeCount: 8,
    ),
    Comment(
      id: '2',
      userName: 'NovelLover',
      userAvatar: '',
      content: 'Karakternya berkembang dengan baik. Suka banget sama Arya!',
      timestamp: DateTime.now().subtract(Duration(hours: 6)),
      likeCount: 5,
    ),
  ].obs;

  final RxList<RecommendedNovel> recommendedNovels = <RecommendedNovel>[
    RecommendedNovel(
      id: '1',
      title: 'Petualangan ke Utara',
      author: 'Penulis E',
      category: 'Adventure',
      rating: 4.5,
    ),
    RecommendedNovel(
      id: '2',
      title: 'Legenda Naga',
      author: 'Penulis F',
      category: 'Fantasy',
      rating: 4.7,
    ),
  ].obs;

  final RxBool isLiked = false.obs;
  final RxString newComment = ''.obs;

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
      );
    }
    isLiked.value = !isLiked.value;
  }

  void addComment() {
    if (newComment.value.trim().isEmpty) return;

    final newCommentObj = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userName: 'Anda',
      userAvatar: '',
      content: newComment.value,
      timestamp: DateTime.now(),
      likeCount: 0,
    );

    comments.insert(0, newCommentObj);

    // Update comment count
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
    );

    newComment.value = '';
    Get.snackbar(
      'Berhasil',
      'Komentar berhasil ditambahkan',
      snackPosition: SnackPosition.BOTTOM,
    );
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
    Get.snackbar(
      'Bab Berikutnya',
      'Navigasi ke bab berikutnya',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void navigateToPreviousChapter() {
    Get.snackbar(
      'Bab Sebelumnya',
      'Navigasi ke bab sebelumnya',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'baru saja';
    if (difference.inHours < 1) return '${difference.inMinutes} menit lalu';
    if (difference.inDays < 1) return '${difference.inHours} jam lalu';
    if (difference.inDays < 7) return '${difference.inDays} hari lalu';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()} minggu lalu';
    return '${(difference.inDays / 30).floor()} bulan lalu';
  }

  String formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}