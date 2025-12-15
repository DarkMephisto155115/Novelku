import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/novel_item.dart';

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
    return GestureDetector(
      onTap: onTap ??
          () {
            Get.toNamed('/reading', arguments: {'novelId': item.id});
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
                      color: Colors.grey[300],
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
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  item.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NovelCardVertical extends StatelessWidget {
  final NovelItem item;
  final VoidCallback? onTap;
  const NovelCardVertical({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ??
          () {
            Get.toNamed('/reading', arguments: {'novelId': item.id});
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
                        width: 72, height: 96, color: Colors.grey[300])),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(item.author,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(16)),
                          child: Text(item.genre.map((g) => '$g').join('\n'),
                              style: const TextStyle(fontSize: 12)),
                        ),
                        Row(children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(item.rating.toString(),
                              style: const TextStyle(fontSize: 13)),
                        ]),
                        Text('${item.chapters} Bab',
                            style: const TextStyle(fontSize: 12)),
                        Text('${(item.readers / 1000).toStringAsFixed(1)}K',
                            style: const TextStyle(fontSize: 12)),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AllNovelGridItem extends StatelessWidget {
  final NovelItem novel;
  const AllNovelGridItem({super.key, required this.novel});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.toNamed('/reading', arguments: {'novelId': novel.id});
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
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(novel.title,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('Penulis: ${novel.author}',
              style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            children: novel.genre
                .map((c) =>
                    Chip(label: Text(c), visualDensity: VisualDensity.compact))
                .toList(),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.star, size: 16, color: Colors.amber),
              Text(novel.rating.toString()),
            ],
          ),
        ],
      ),
    );
  }
}
