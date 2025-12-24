import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_brain/presentation/controllers/novel_chapters_controller.dart';
import 'package:terra_brain/presentation/models/novel_model.dart';
import 'package:terra_brain/presentation/themes/theme_data.dart';
import '../../controllers/write/writing_controller.dart';

class NovelChaptersPage extends StatelessWidget {
  const NovelChaptersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NovelChaptersController());

    return Obx(() {
      final writingController = Get.find<WritingController>();
      final isDarkMode = writingController.themeController.isDarkMode;
      final bgColor = isDarkMode ? Colors.grey.shade900 : Colors.white;

      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Obx(
                () => Text(controller.novel.value?.title ?? 'Loading...'),
          ),
          centerTitle: true,
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.novel.value == null) {
            return Center(child: Text('Novel tidak ditemukan', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildNovelHeader(controller),
                _buildNovelDescription(controller),
                _buildSearchBar(controller),
                _buildChaptersList(controller),
              ],
            ),
          );
        }),
      );
    });
  }

  Widget _buildNovelHeader(NovelChaptersController controller) {
    return Obx(() {
      final novel = controller.novel.value;
      if (novel == null) return const SizedBox.shrink();

      final writingController = Get.find<WritingController>();
      final isDarkMode = writingController.themeController.isDarkMode;
      final textColor = isDarkMode ? Colors.white : Colors.black;
      final subtitleColor = isDarkMode ? Colors.grey.shade400 : Colors.grey;
      final genreBgColor = isDarkMode ? Colors.grey.shade700 : Colors.grey[200];

      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                novel.imageUrl ?? '',
                width: 100,
                height: 140,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 100,
                  height: 140,
                  color: Colors.grey[300],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    novel.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Penulis: ${novel.authorName ?? 'Tidak diketahui'}',
                        style:
                            TextStyle(fontSize: 13, color: subtitleColor),
                      ),
                      if (controller.isAuthorPremium.value) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color.fromARGB(255, 251, 255, 34),
                                AppThemeData.premiumColor,
                                const Color.fromARGB(255, 203, 108, 0)
                                    .withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Premium',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (novel.genre != null && novel.genre!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: genreBgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            novel.genre!,
                            style: TextStyle(fontSize: 11, color: textColor),
                          ),
                        ),
                      const SizedBox(width: 8),
                      _buildNovelStatusBadge(novel, isDarkMode),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.favorite,
                          size: 14, color: Colors.red),
                      const SizedBox(width: 4),
                      Text('${novel.likeCount}',
                          style: TextStyle(fontSize: 12, color: textColor)),
                      const SizedBox(width: 16),
                      Icon(Icons.menu_book,
                          size: 14, color: subtitleColor),
                      const SizedBox(width: 4),
                      Text('${controller.chapters.length}',
                          style: TextStyle(fontSize: 12, color: textColor)),
                      const SizedBox(width: 16),
                      Icon(Icons.visibility,
                          size: 14, color: subtitleColor),
                      const SizedBox(width: 4),
                      Text('${novel.viewCount}',
                          style: TextStyle(fontSize: 12, color: textColor)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    final isFav = controller.isFavorite.value;
                    final isProcessing = controller.isFavoriteProcessing.value;
                    return ElevatedButton.icon(
                      onPressed: isProcessing
                          ? null
                          : () => controller.toggleFavorite(),
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                      ),
                      label: Text(
                        isFav ? 'Favorit' : 'Tambah Favorit',
                        style: const TextStyle(fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isFav ? Colors.red : Colors.grey[300],
                        foregroundColor:
                            isFav ? Colors.white : Colors.black,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildNovelDescription(NovelChaptersController controller) {
    return Obx(() {
      final description = controller.novel.value?.description;
      if (description == null || description.isEmpty) {
        return const SizedBox.shrink();
      }

      final writingController = Get.find<WritingController>();
      final isDarkMode = writingController.themeController.isDarkMode;
      final textColor = isDarkMode ? Colors.white : Colors.black;
      final subtitleColor = isDarkMode ? Colors.grey.shade400 : Colors.grey;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deskripsi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: subtitleColor,
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
            Divider(height: 24, color: isDarkMode ? Colors.grey.shade700 : null),
          ],
        ),
      );
    });
  }

  Widget _buildSearchBar(NovelChaptersController controller) {
    final writingController = Get.find<WritingController>();
    final isDarkMode = writingController.themeController.isDarkMode;
    final inputBgColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        decoration: InputDecoration(
          hintText: 'Cari bab...',
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.grey.shade400 : Colors.black),
          filled: true,
          fillColor: inputBgColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: controller.filterChapters,
      ),
    );
  }

  Widget _buildNovelStatusBadge(Novel novel, bool isDarkMode) {
    String status = 'Draft';
    Color statusColor = Colors.grey;
    Color statusBgColor = Colors.grey[100]!;

    if (novel.status != null) {
      switch (novel.status!.toLowerCase()) {
        case 'ongoing':
        case 'berlangsung':
          status = 'Berlangsung';
          statusColor = Colors.blue;
          statusBgColor = isDarkMode ? Colors.blue.shade900 : Colors.blue[50]!;
          break;
        case 'completed':
        case 'selesai':
          status = 'Selesai';
          statusColor = Colors.green;
          statusBgColor = isDarkMode ? Colors.green.shade900 : Colors.green[50]!;
          break;
        case 'hiatus':
          status = 'Hiatus';
          statusColor = Colors.orange;
          statusBgColor = isDarkMode ? Colors.orange.shade900 : Colors.orange[50]!;
          break;
        case 'dropped':
        case 'ditutup':
          status = 'Ditutup';
          statusColor = Colors.red;
          statusBgColor = isDarkMode ? Colors.red.shade900 : Colors.red[50]!;
          break;
        case 'draft':
          status = 'Draft';
          statusColor = Colors.grey;
          statusBgColor = isDarkMode ? Colors.grey[700]! : Colors.grey[200]!;
          break;
        default:
          status = novel.status!;
          statusColor = Colors.grey;
          statusBgColor = isDarkMode ? Colors.grey[700]! : Colors.grey[100]!;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusBgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: statusColor,
        ),
      ),
    );
  }

  Widget _buildChaptersList(NovelChaptersController controller) {
    return Obx(() {
      if (controller.filteredChapters.isEmpty) {
        final writingController = Get.find<WritingController>();
        final isDarkMode = writingController.themeController.isDarkMode;
        final textColor = isDarkMode ? Colors.white : Colors.black;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              controller.searchQuery.value.isEmpty
                  ? 'Belum ada bab yang dipublikasikan'
                  : 'Tidak ada bab yang cocok dengan pencarian',
              style: TextStyle(color: textColor),
            ),
          ),
        );
      }

      final writingController = Get.find<WritingController>();
      final isDarkMode = writingController.themeController.isDarkMode;

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.filteredChapters.length,
        separatorBuilder: (_, __) => Divider(color: isDarkMode ? Colors.grey.shade700 : null),
        itemBuilder: (context, index) {
          final chapter = controller.filteredChapters[index];
          return _buildChapterItem(chapter, controller, isDarkMode);
        },
      );
    });
  }

  Widget _buildChapterItem(
      Chapter chapter,
      NovelChaptersController controller,
      bool isDarkMode,
      ) {
    final wordCount =
        chapter.content.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final estimatedReadTime = (wordCount / 200).ceil();
    final chapterIndex = controller.chapters.indexWhere((c) => c.id == chapter.id) + 1;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = isDarkMode ? Colors.grey.shade400 : Colors.grey;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        'Bab $chapterIndex: ${chapter.title}',
        style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            'Tanggal: ${_formatDate(chapter.createdAt)}',
            style: TextStyle(fontSize: 12, color: subtitleColor),
          ),
          const SizedBox(height: 2),
          Text(
            '$estimatedReadTime min • $wordCount kata',
            style: TextStyle(fontSize: 11, color: subtitleColor),
          ),
        ],
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: subtitleColor),
      onTap: () {
        Get.toNamed(
          '/reading',
          arguments: {
            'novelId': controller.novelId,
            'chapterId': chapter.id,
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
