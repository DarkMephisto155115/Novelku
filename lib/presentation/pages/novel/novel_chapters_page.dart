import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_brain/presentation/controllers/novel_chapters_controller.dart';
import 'package:terra_brain/presentation/models/novel_model.dart';

class NovelChaptersPage extends StatelessWidget {
  const NovelChaptersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NovelChaptersController());

    return Scaffold(
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
          return const Center(child: Text('Novel tidak ditemukan'));
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
  }

  Widget _buildNovelHeader(NovelChaptersController controller) {
    return Obx(() {
      final novel = controller.novel.value;
      if (novel == null) return const SizedBox.shrink();

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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Penulis: ${novel.authorName ?? 'Tidak diketahui'}',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  if (novel.genre != null && novel.genre!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        novel.genre!,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.favorite,
                          size: 14, color: Colors.red),
                      const SizedBox(width: 4),
                      Text('${novel.likeCount}',
                          style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 16),
                      const Icon(Icons.menu_book,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${novel.chapterCount}',
                          style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 16),
                      const Icon(Icons.visibility,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${novel.viewCount}',
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
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

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Deskripsi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
            const Divider(height: 24),
          ],
        ),
      );
    });
  }

  Widget _buildSearchBar(NovelChaptersController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari bab...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: controller.filterChapters,
      ),
    );
  }

  Widget _buildChaptersList(NovelChaptersController controller) {
    return Obx(() {
      if (controller.filteredChapters.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              controller.searchQuery.value.isEmpty
                  ? 'Belum ada bab yang dipublikasikan'
                  : 'Tidak ada bab yang cocok dengan pencarian',
            ),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.filteredChapters.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final chapter = controller.filteredChapters[index];
          return _buildChapterItem(chapter, controller);
        },
      );
    });
  }

  Widget _buildChapterItem(
      Chapter chapter,
      NovelChaptersController controller,
      ) {
    final wordCount =
        chapter.content.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final estimatedReadTime = (wordCount / 200).ceil();

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        'Bab ${chapter.chapter}: ${chapter.title}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            'Tanggal: ${_formatDate(chapter.createdAt)}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 2),
          Text(
            '$estimatedReadTime min • $wordCount kata',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Get.toNamed(
          '/reading',
          arguments: {
            'novelId': controller.novelId,
            'chapter': chapter.chapter,
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
