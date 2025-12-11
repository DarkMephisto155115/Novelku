import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_brain/presentation/controllers/reading_controller.dart';
import 'package:terra_brain/presentation/helpers/premium_popup_manager.dart';
import 'package:terra_brain/presentation/models/novel_item.dart';
import 'package:terra_brain/presentation/models/reading_model.dart';
import 'package:terra_brain/presentation/widgets/novel_card.dart';

class ReadingPage extends GetView<ReadingController> {
  ReadingPage({Key? key}) : super(key: key);

  final List<NovelItem> recommended = [
    NovelItem(
        id: '1',
        title: 'Dunia Fantasi',
        author: 'Penulis A',
        coverUrl: 'https://picsum.photos/200/300?random=1',
        genre: ['Fantasy'],
        rating: 4.8,
        chapters: 45,
        readers: 12500),
    NovelItem(
        id: '2',
        title: 'Cinta di Musim Semi',
        author: 'Penulis B',
        coverUrl: 'https://picsum.photos/200/300?random=2',
        genre: ['Romance'],
        rating: 4.6,
        chapters: 32,
        readers: 8300),
    NovelItem(
        id: '3',
        title: 'Misteri Malam',
        author: 'Penulis C',
        coverUrl: 'https://picsum.photos/200/300?random=3',
        genre: ['Mystery'],
        rating: 4.9,
        chapters: 28,
        readers: 15200),
  ];

  @override
  Widget build(BuildContext context) {

    WidgetsBinding.instance.addPostFrameCallback((_) {
      PremiumPopupManager.showPopupBeforeReading();
    });

    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar sederhana
          SliverAppBar(
            pinned: true,
            backgroundColor: Get.theme.appBarTheme.backgroundColor,
            elevation: 0,
            title: Text(
              'Membaca',
              style: Get.theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Content
          SliverList(
            delegate: SliverChildListDelegate([
              _buildChapterContent(),
              _buildAuthorSection(),
              _buildInteractionSection(),
              _buildCommentsSection(),
              _buildNavigationButtons(),
              _buildRecommendedSection(),
              SizedBox(height: 20),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterContent() {
    return Obx(() {
      final chapter = controller.currentChapter.value;

      return Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chapter Title
            Text(
              chapter.title,
              style: Get.theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            SizedBox(height: 24),

            // Chapter Content dengan font default
            Text(
              chapter.content,
              style: TextStyle(
                fontSize: 16, // Ukuran font default
                height: 1.8,
                color: Get.theme.textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAuthorSection() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Divider(
            //   color: Get.theme.dividerColor.withOpacity(0.3),
            //   height: 1,
            // ),
            // SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Penulis',
                        style: Get.theme.textTheme.bodySmall?.copyWith(
                          color: Get.theme.textTheme.bodyMedium?.color
                              ?.withOpacity(0.6),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        controller.currentChapter.value.author,
                        style: Get.theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 80,
                    maxWidth: 120,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Get.snackbar(
                        'Mengikuti',
                        'Anda sekarang mengikuti ${controller.currentChapter.value.author}',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Get.theme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(
                      'Ikuti',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionSection() {
    return Obx(() {
      final chapter = controller.currentChapter.value;

      return Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Divider(
              color: Get.theme.dividerColor.withOpacity(0.3),
              height: 1,
            ),
            SizedBox(height: 16),

            // Question
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Bagaimana chapter ini?',
                  style: Get.theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Like and Comment Count
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Like Count
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        controller.isLiked.value
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: controller.isLiked.value
                            ? Colors.red
                            : Get.theme.iconTheme.color,
                      ),
                      onPressed: controller.toggleLike,
                    ),
                    Text(
                      controller.formatNumber(chapter.likeCount),
                      style: Get.theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                SizedBox(width: 24),

                // Comment Count
                Row(
                  children: [
                    Icon(
                      Icons.comment,
                      color: Get.theme.iconTheme.color,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${chapter.commentCount} Komentar',
                      style: Get.theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCommentsSection() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            'Komentar',
            style: Get.theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),

          // Comment Input
          Container(
            decoration: BoxDecoration(
              color: Get.theme.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller:
                  TextEditingController(text: controller.newComment.value),
              onChanged: controller.setNewComment,
              decoration: InputDecoration(
                hintText: 'Tulis komentarmu...',
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: controller.addComment,
                  color: Get.theme.primaryColor,
                ),
              ),
              maxLines: 3,
            ),
          ),
          SizedBox(height: 16),

          // Comments List
          Obx(() => Column(
                children: controller.comments
                    .map((comment) => _buildCommentCard(comment))
                    .toList(),
              )),
        ],
      ),
    );
  }

  Widget _buildCommentCard(Comment comment) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      color: Get.theme.cardColor,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info and Time
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Get.theme.primaryColor.withOpacity(0.2),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 18,
                    color: Get.theme.primaryColor,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.userName,
                        style: Get.theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        controller.formatTimeAgo(comment.timestamp),
                        style: Get.theme.textTheme.bodySmall?.copyWith(
                          color: Get.theme.textTheme.bodyMedium?.color
                              ?.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                // Like Button for Comment
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.favorite_border,
                        size: 16,
                        color: Get.theme.textTheme.bodyMedium?.color
                            ?.withOpacity(0.5),
                      ),
                      onPressed: () => controller.likeComment(comment.id),
                    ),
                    Text(
                      comment.likeCount.toString(),
                      style: Get.theme.textTheme.bodySmall?.copyWith(
                        color: Get.theme.textTheme.bodyMedium?.color
                            ?.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),

            // Comment Content
            Text(
              comment.content,
              style: Get.theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Chapter
          Expanded(
            child: OutlinedButton(
              onPressed: controller.navigateToPreviousChapter,
              style: OutlinedButton.styleFrom(
                foregroundColor: Get.theme.primaryColor,
                side: BorderSide(color: Get.theme.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Bab Sebelumnya'),
            ),
          ),
          SizedBox(width: 12),

          // Next Chapter
          Expanded(
            child: ElevatedButton(
              onPressed: controller.navigateToNextChapter,
              style: ElevatedButton.styleFrom(
                backgroundColor: Get.theme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Bab Berikutnya'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedSection() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            'Novel yang Mungkin Kamu Suka',
            style: Get.theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, idx) =>
                  NovelCardHorizontal(item: recommended[idx]),
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: recommended.length,
            ),
          ),
        ],
      ),
    );
  }
}
