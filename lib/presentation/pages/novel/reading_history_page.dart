import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_brain/presentation/controllers/reading_controller.dart';
import 'package:terra_brain/presentation/widgets/reading_stats_widget.dart';

class ReadingHistoryPage extends GetView<ReadingController> {
  const ReadingHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Membaca'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => ReadingStatsWidget(
              stats: controller.readingStats.value,
            )),
            const SizedBox(height: 24),
            Obx(() {
              final history = controller.readingHistory;
              if (history.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada riwayat membaca',
                        style: Get.theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Riwayat Membaca (${history.length})',
                    style: Get.theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...history.map((item) {
                    return _buildHistoryCard(context, item);
                  }).toList(),
                ],
              );
            }),
            const SizedBox(height: 24),
            Obx(() {
              final bookmarks = controller.bookmarks;
              if (bookmarks.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bookmark (${bookmarks.length})',
                    style: Get.theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  BookmarkListWidget(
                    bookmarks: bookmarks,
                    onBookmarkDelete: (id) {
                      controller.removeBookmark(id);
                      Get.snackbar('Dihapus', 'Bookmark dihapus');
                    },
                  ),
                ],
              );
            }),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, dynamic item) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.chapterTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Get.theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bab ${item.chapterId}',
                        style: Get.theme.textTheme.bodySmall?.copyWith(
                          color: Get.theme.textTheme.bodyMedium?.color
                              ?.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    Get.back();
                  },
                ),
              ],
            ),
            const Divider(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 16,
                      color: Get.theme.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item.minutesRead} menit',
                      style: Get.theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Get.theme.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTimeAgo(item.lastReadAt),
                      style: Get.theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'baru saja';
    if (difference.inHours < 1) return '${difference.inMinutes} menit lalu';
    if (difference.inDays < 1) return '${difference.inHours} jam lalu';
    if (difference.inDays < 7) return '${difference.inDays} hari lalu';
    if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} minggu lalu';
    }
    return '${(difference.inDays / 30).floor()} bulan lalu';
  }
}
