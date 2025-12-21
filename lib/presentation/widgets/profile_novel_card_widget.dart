import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_brain/presentation/models/profile_model.dart';

class NovelCard extends StatelessWidget {
  final UserNovel novel;
  final VoidCallback onEdit;

  const NovelCard({
    Key? key,
    required this.novel,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Get.bottomSheet(
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Get.theme.scaffoldBackgroundColor,
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  novel.title,
                  style: Get.theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.menu_book),
                    label: const Text('Baca Novel'),
                    onPressed: () {
                      Get.back();
                      Get.toNamed(
                        '/reading',
                        arguments: {'novelId': novel.id},
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Novel'),
                    onPressed: () {
                      Get.back();
                      onEdit();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  novel.coverUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Image.asset(
                      'assets/images/book.jpg',
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              const SizedBox(height: 6),
              Text(
                novel.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Get.theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                novel.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Get.theme.textTheme.bodySmall?.copyWith(
                  color: Get.theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class FavoriteNovelTile extends StatelessWidget {
  final FavoriteNovel novel;

  const FavoriteNovelTile({
    Key? key,
    required this.novel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Get.toNamed(
          '/reading',
          arguments: {'novelId': novel.id},
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Get.theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // COVER
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                novel.coverUrl,
                width: 75,
                height: 105,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Image.asset(
                    'assets/images/book.jpg',
                    width: 75,
                    height: 105,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),

            const SizedBox(width: 12),

            // INFO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    novel.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Get.theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // GENRE
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      novel.genre,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // CHAPTER + VIEWS
                  Row(
                    children: [
                      const Icon(Icons.menu_book,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${novel.chapterCount} chapter',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.favorite,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${novel.views} views',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // STATUS
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: novel.status == 'Selesai'
                    ? Colors.green.shade100
                    : Colors.blue.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                novel.status,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: novel.status == 'Selesai'
                      ? Colors.green.shade700
                      : Colors.blue.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
