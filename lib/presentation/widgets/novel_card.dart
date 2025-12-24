import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/novel_item.dart';
import '../controllers/write/writing_controller.dart';

class NovelCardHorizontal extends StatelessWidget {
  final NovelItem item;
  final VoidCallback? onTap;

  const NovelCardHorizontal({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDarkMode = Get.find<WritingController>().themeController.isDarkMode;
      final textColor = isDarkMode ? Colors.white : Colors.black;
      final subtitleColor = isDarkMode ? Colors.grey.shade400 : Colors.grey;

      return GestureDetector(
        onTap: onTap ??
            () {
              Get.toNamed('/novel_chapters', arguments: {'novelId': item.id});
            },
        child: Card(
          // elevation: 9,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: Get.theme.cardColor,
          child: SizedBox(
            width: 120,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.coverUrl,
                      height: 160,
                      width: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                        height: 160,
                        width: 120,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class NovelCardVertical extends StatelessWidget {
  final NovelItem item;
  final VoidCallback? onTap;
  const NovelCardVertical({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDarkMode = Get.find<WritingController>().themeController.isDarkMode;
      final textColor = isDarkMode ? Colors.white : Colors.black;
      final subtitleColor = isDarkMode ? Colors.grey.shade400 : Colors.grey;
      final genreBgColor = isDarkMode ? Colors.grey.shade700 : Colors.grey[200];

      return GestureDetector(
        onTap: onTap ??
            () {
              Get.toNamed('/novel_chapters', arguments: {'novelId': item.id});
            },
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(item.coverUrl,
                      width: 72,
                      height: 96,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                          width: 72, height: 96, color: isDarkMode ? Colors.grey[700] : Colors.grey[300])),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title,
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15, color: textColor)),
                      const SizedBox(height: 4),
                      Text(item.author,
                          style:
                              TextStyle(color: subtitleColor, fontSize: 13)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: genreBgColor,
                                borderRadius: BorderRadius.circular(16)),
                            child: Text(item.genre.map((g) => '$g').join('\n'),
                                style: TextStyle(fontSize: 12, color: textColor)),
                          ),
                        Row(children: [
                          const Icon(Icons.favorite, size: 14, color: Colors.red),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text('${item.likeCount}',
                                style: TextStyle(fontSize: 13, color: textColor)),
                          ),
                        ]),
                        Row(
                          children: [
                            Icon(Icons.menu_book, size: 12, color: subtitleColor),
                            const SizedBox(width: 4),
                            Text('${item.chapters} Bab',
                                style: TextStyle(fontSize: 12, color: textColor)),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.visibility, size: 12, color: subtitleColor),
                            const SizedBox(width: 4),
                            Text(item.readers.toString(),
                                style: TextStyle(fontSize: 12, color: textColor)),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ));
    });
  }
}

class AllNovelGridItem extends StatelessWidget {
  final NovelItem novel;
  const AllNovelGridItem({super.key, required this.novel});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDarkMode = Get.find<WritingController>().themeController.isDarkMode;
      final textColor = isDarkMode ? Colors.white : Colors.black;
      final subtitleColor = isDarkMode ? Colors.grey.shade400 : Colors.grey;

      return InkWell(
        onTap: () {
          Get.toNamed('/novel_chapters', arguments: {'novelId': novel.id});
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  novel.coverUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    width: double.infinity,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(novel.title,
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
            Text('${novel.author}',
                style: TextStyle(fontSize: 12, color: subtitleColor)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children: novel.genre
                  .map((c) =>
                      Chip(label: Text(c, style: TextStyle(color: textColor)), visualDensity: VisualDensity.compact))
                  .toList(),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.favorite, size: 12, color: Colors.red),
                const SizedBox(width: 4),
                Expanded(
                  child: Text('${novel.likeCount}',
                      style: TextStyle(fontSize: 11, color: textColor)),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.menu_book, size: 12, color: subtitleColor),
                const SizedBox(width: 4),
                Text('${novel.chapters} Bab',
                    style: TextStyle(fontSize: 11, color: textColor)),
              ],
            ),
            Row(
              children: [
                Icon(Icons.visibility, size: 12, color: subtitleColor),
                const SizedBox(width: 4),
                Text(novel.readers.toString(),
                    style: TextStyle(fontSize: 11, color: textColor)),
              ],
            ),
          ],
        ),
      );
    });
  }
}
