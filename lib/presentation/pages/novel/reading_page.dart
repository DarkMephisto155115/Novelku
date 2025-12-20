import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_brain/presentation/controllers/reading_controller.dart';
import 'package:terra_brain/presentation/helpers/premium_popup_manager.dart';
import 'package:terra_brain/presentation/models/novel_item.dart';
import 'package:terra_brain/presentation/models/reading_model.dart';
import 'package:terra_brain/presentation/widgets/novel_card.dart';

class ReadingPage extends GetView<ReadingController> {
  ReadingPage({Key? key}) : super(key: key);

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {

    WidgetsBinding.instance.addPostFrameCallback((_) {
      PremiumPopupManager.showPopupBeforeReading();
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
      }
    });

    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: _getThemeColor(),
            elevation: 0,
            title: Obx(() => Text(
              controller.currentChapter.value.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Get.theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            )),
            actions: [
              Obx(() => IconButton(
                icon: Icon(
                  controller.isChapterBookmarked(controller.currentChapter.value.id)
                      ? Icons.bookmark
                      : Icons.bookmark_outline,
                  color: controller.isChapterBookmarked(controller.currentChapter.value.id)
                      ? Get.theme.primaryColor
                      : null,
                ),
                onPressed: () => _showBookmarkDialog(context),
              )),
              IconButton(
                icon: const Icon(Icons.menu_book),
                onPressed: () => _showTableOfContents(context),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => _showReadingSettings(context),
              ),
            ],
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
      final settings = controller.readingSettings.value;

      TextAlign _getTextAlign(TextAlignment alignment) {
        switch (alignment) {
          case TextAlignment.left:
            return TextAlign.left;
          case TextAlignment.right:
            return TextAlign.right;
          case TextAlignment.justify:
            return TextAlign.justify;
        }
      }

      return Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chapter.title,
              style: Get.theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: settings.fontSize + 8,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Bab ${chapter.chapterNumber}',
                  style: Get.theme.textTheme.bodySmall?.copyWith(
                    color: Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  '${chapter.wordCount} kata',
                  style: Get.theme.textTheme.bodySmall?.copyWith(
                    color: Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  '${chapter.estimatedReadTime} menit',
                  style: Get.theme.textTheme.bodySmall?.copyWith(
                    color: Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            SelectableText(
              chapter.content,
              style: TextStyle(
                fontSize: settings.fontSize,
                height: settings.lineHeight,
                color: _getTextColor(settings.theme),
              ),
              textAlign: _getTextAlign(settings.textAlignment),
              onSelectionChanged: (selection, _) {
                if (selection != null) {
                  controller.saveReadingProgress(_scrollController.offset.toInt());
                }
              },
            ),
          ],
        ),
      );
    });
  }

  Color _getTextColor(ReadingTheme theme) {
    switch (theme) {
      case ReadingTheme.dark:
        return Colors.grey[200] ?? Colors.white;
      case ReadingTheme.sepia:
        return const Color(0xFF3E2723);
      case ReadingTheme.light:
      default:
        return Get.theme.textTheme.bodyLarge?.color ?? Colors.black;
    }
  }

  Color _getBackgroundColor() {
    final settings = controller.readingSettings.value;
    switch (settings.theme) {
      case ReadingTheme.dark:
        return const Color(0xFF1A1A1A);
      case ReadingTheme.sepia:
        return const Color(0xFFF4EAD5);
      case ReadingTheme.light:
      default:
        return Colors.white;
    }
  }

  Color _getThemeColor() {
    final settings = controller.readingSettings.value;
    switch (settings.theme) {
      case ReadingTheme.dark:
        return const Color(0xFF2A2A2A);
      case ReadingTheme.sepia:
        return const Color(0xFFD7CCC8);
      case ReadingTheme.light:
      default:
        return Get.theme.appBarTheme.backgroundColor ?? Colors.white;
    }
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
                      Obx(() => Text(
                        controller.novelAuthor.value,
                        style: Get.theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      )),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 80,
                    maxWidth: 120,
                  ),
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isFollowingAuthor.value 
                        ? null 
                        : () => controller.followAuthor(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.isFollowingAuthor.value
                          ? Colors.grey
                          : Get.theme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(
                      controller.isFollowingAuthor.value ? 'Sudah Diikuti' : 'Ikuti',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )),
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
                      onPressed: controller.isLikeProcessing.value ? null : controller.toggleLike,
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
          Text(
            'Novel yang Mungkin Kamu Suka',
            style: Get.theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Obx(() {
            if (controller.recommendedNovels.isEmpty) {
              return SizedBox(
                height: 220,
                child: Center(
                  child: Text('Tidak ada rekomendasi'),
                ),
              );
            }
            return SizedBox(
              height: 220,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, idx) =>
                    NovelCardHorizontal(item: controller.recommendedNovels[idx]),
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: controller.recommendedNovels.length,
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showReadingSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _getBackgroundColor(),
      builder: (context) => Obx(() {
        final settings = controller.readingSettings.value;
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pengaturan Membaca',
                  style: Get.theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 24),
                _buildSettingSection(
                  'Ukuran Font',
                  Column(
                    children: [
                      Slider(
                        value: settings.fontSize,
                        min: 12,
                        max: 24,
                        onChanged: controller.updateFontSize,
                        divisions: 12,
                      ),
                      Center(
                        child: Text(
                          '${settings.fontSize.toStringAsFixed(0)}',
                          style: TextStyle(fontSize: settings.fontSize),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                _buildSettingSection(
                  'Tinggi Baris',
                  Column(
                    children: [
                      Slider(
                        value: settings.lineHeight,
                        min: 1.2,
                        max: 2.5,
                        onChanged: controller.updateLineHeight,
                        divisions: 13,
                      ),
                      Center(
                        child: Text(
                          settings.lineHeight.toStringAsFixed(1),
                          style: TextStyle(
                            height: settings.lineHeight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                _buildSettingSection(
                  'Tema',
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ReadingTheme.values.map((theme) {
                      final isSelected = settings.theme == theme;
                      final themeLabel = theme.name[0].toUpperCase() +
                          theme.name.substring(1);
                      return GestureDetector(
                        onTap: () => controller.updateTheme(theme),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Get.theme.primaryColor
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            themeLabel,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 24),
                _buildSettingSection(
                  'Perataan Teks',
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: TextAlignment.values.map((alignment) {
                      final isSelected = settings.textAlignment == alignment;
                      IconData icon;
                      switch (alignment) {
                        case TextAlignment.left:
                          icon = Icons.format_align_left;
                          break;
                        case TextAlignment.right:
                          icon = Icons.format_align_right;
                          break;
                        case TextAlignment.justify:
                          icon = Icons.format_align_justify;
                          break;
                      }
                      return GestureDetector(
                        onTap: () =>
                            controller.updateTextAlignment(alignment),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Get.theme.primaryColor
                                : Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Get.theme.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Tutup'),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSettingSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Get.theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12),
        content,
      ],
    );
  }

  void _showBookmarkDialog(BuildContext context) {
    final noteController = TextEditingController();
    final isBookmarked =
        controller.isChapterBookmarked(controller.currentChapter.value.id);

    Get.dialog(
      AlertDialog(
        title: Text(isBookmarked ? 'Hapus Bookmark' : 'Tambah Bookmark'),
        content: isBookmarked
            ? const Text('Hapus bookmark dari chapter ini?')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: noteController,
                    decoration: InputDecoration(
                      hintText: 'Tambah catatan (opsional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (isBookmarked) {
                final bookmark = controller.bookmarks
                    .firstWhere((b) =>
                        b.chapterId == controller.currentChapter.value.id);
                controller.removeBookmark(bookmark.id);
                Get.back();
              } else {
                controller.addBookmark(noteController.text);
                Get.back();
              }
            },
            child: Text(isBookmarked ? 'Hapus' : 'Simpan'),
          ),
        ],
      ),
    );
  }

  void _showTableOfContents(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _getBackgroundColor(),
      builder: (context) => Obx(() {
        final chapters = controller.chapterList;
        final currentChapterId = controller.currentChapter.value.id;

        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daftar Bab',
                style: Get.theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: chapters.isEmpty
                    ? Center(
                        child: Text('Tidak ada bab tersedia'),
                      )
                    : ListView.builder(
                        itemCount: chapters.length,
                        itemBuilder: (context, index) {
                          final chapter = chapters[index];
                          final isCurrentChapter =
                              chapter.id == currentChapterId;
                          final isBookmarked =
                              controller.isChapterBookmarked(chapter.id);

                          return GestureDetector(
                            onTap: () {
                              controller.jumpToChapter(chapter);
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.all(12),
                              margin: EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: isCurrentChapter
                                    ? Get.theme.primaryColor.withOpacity(0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isCurrentChapter
                                      ? Get.theme.primaryColor
                                      : Colors.transparent,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Bab ${chapter.chapterNumber}',
                                          style: Get.theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: Get.theme.textTheme
                                                .bodyMedium?.color
                                                ?.withOpacity(0.6),
                                          ),
                                        ),
                                        Text(
                                          chapter.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Get.theme.textTheme.bodyLarge
                                              ?.copyWith(
                                            fontWeight: isCurrentChapter
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isBookmarked)
                                    Icon(
                                      Icons.bookmark,
                                      color: Get.theme.primaryColor,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
