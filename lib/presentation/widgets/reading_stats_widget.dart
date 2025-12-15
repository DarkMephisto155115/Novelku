import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_brain/presentation/models/reading_model.dart';

class ReadingStatsWidget extends StatelessWidget {
  final ReadingStats stats;
  final VoidCallback? onTap;

  const ReadingStatsWidget({
    Key? key,
    required this.stats,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Get.theme.primaryColor.withOpacity(0.1),
                Get.theme.primaryColor.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statistik Membaca',
                style: Get.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              _buildStatRow(
                icon: Icons.book,
                label: 'Buku Dibaca',
                value: '${stats.totalBooksRead}',
              ),
              SizedBox(height: 12),
              _buildStatRow(
                icon: Icons.description,
                label: 'Bab Dibaca',
                value: '${stats.totalChaptersRead}',
              ),
              SizedBox(height: 12),
              _buildStatRow(
                icon: Icons.text_fields,
                label: 'Kata Dibaca',
                value: _formatNumber(stats.totalWordsRead),
              ),
              SizedBox(height: 12),
              _buildStatRow(
                icon: Icons.timer,
                label: 'Waktu Membaca',
                value: _formatDuration(stats.totalTimeSpent),
              ),
              SizedBox(height: 12),
              _buildStatRow(
                icon: Icons.local_fire_department,
                label: 'Streak Harian',
                value: '${stats.currentStreak} hari',
                valueColor: stats.currentStreak > 0 ? Colors.orange : Colors.grey,
              ),
              if (stats.lastReadAt != null) ...[
                SizedBox(height: 12),
                _buildStatRow(
                  icon: Icons.access_time,
                  label: 'Terakhir Dibaca',
                  value: _formatTimeAgo(stats.lastReadAt!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Get.theme.primaryColor,
            ),
            SizedBox(width: 12),
            Text(
              label,
              style: Get.theme.textTheme.bodyMedium,
            ),
          ],
        ),
        Text(
          value,
          style: Get.theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '$hours jam $minutes menit';
    }
    return '$minutes menit';
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

class BookmarkListWidget extends StatelessWidget {
  final List<Bookmark> bookmarks;
  final VoidCallback? onBookmarkTap;
  final Function(String)? onBookmarkDelete;

  const BookmarkListWidget({
    Key? key,
    required this.bookmarks,
    this.onBookmarkTap,
    this.onBookmarkDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (bookmarks.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bookmark_outline,
                  size: 48,
                  color: Colors.grey[300],
                ),
                SizedBox(height: 12),
                Text(
                  'Tidak ada bookmark',
                  style: Get.theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bookmark (${bookmarks.length})',
          style: Get.theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        ...bookmarks.map((bookmark) {
          return Card(
            elevation: 1,
            margin: EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: Icon(Icons.bookmark, color: Get.theme.primaryColor),
              title: Text(
                bookmark.note ?? 'Tanpa Catatan',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                'Bab ${bookmark.chapterId}',
                style: Get.theme.textTheme.bodySmall,
              ),
              trailing: IconButton(
                icon: Icon(Icons.close, size: 20),
                onPressed: () => onBookmarkDelete?.call(bookmark.id),
              ),
              onTap: onBookmarkTap,
            ),
          );
        }).toList(),
      ],
    );
  }
}
