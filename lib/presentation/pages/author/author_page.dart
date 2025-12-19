import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_brain/presentation/controllers/author/author_controller.dart';
import 'package:terra_brain/presentation/models/author_model.dart';

class AuthorsPage extends GetView<AuthorsController> {
  const AuthorsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Semua Penulis',
          style: Get.theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Get.theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(child: _buildAuthorsList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: controller.setSearchQuery,
        decoration: InputDecoration(
          hintText: 'Cari penulis...',
          prefixIcon: Icon(Icons.search, color: Get.theme.hintColor),
          filled: true,
          fillColor: Get.theme.cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Obx(
      () {
        final categories = controller.categories;
        final selected = controller.selectedCategory.value;

        return SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (_, i) {
              final category = categories[i];
              final isSelected = selected == category;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  key: ValueKey(category), // 🔥 WAJIB
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (_) {
                    controller.setCategory(category);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAuthorsList() {
    return Obx(
      () {
        final items = controller.structuredList;

        if (items.isEmpty) {
          return _emptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (_, index) {
            final item = items[index];

            if (item == '_header_new') {
              return _sectionHeader('✨ Penulis Baru');
            }
            if (item == '_divider_new') {
              return _divider();
            }
            if (item == '_header_popular') {
              return _sectionHeader('🔥 Penulis Populer');
            }
            if (item == '_header_all') {
              return _sectionHeader('📚 Semua Penulis');
            }

            return _authorCard(item as Author);
          },
        );
      },
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_off,
                size: 80, color: Get.theme.hintColor.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text(
              'Belum ada penulis ditemukan',
              style: Get.theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Nungguin mereka nulis dulu ya...',
              style: Get.theme.textTheme.bodySmall
                  ?.copyWith(color: Get.theme.hintColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: Get.theme.textTheme.headlineSmall
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Divider(),
    );
  }

  Widget _authorCard(Author author) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Get.toNamed('/author_profile/${author.id}'),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: author.imageUrl != null && author.imageUrl!.isNotEmpty
                      ? Image.network(
                          author.imageUrl!,
                          width: 55,
                          height: 55,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/default_profile.jpeg',
                              width: 55,
                              height: 55,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          'assets/images/default_profile.jpeg',
                          width: 55,
                          height: 55,
                          fit: BoxFit.cover,
                        )),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            author.name,
                            style: Get.theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (author.isPremium)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, size: 10, color: Colors.white),
                                SizedBox(width: 2),
                                Text(
                                  'Premium',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (author.isNew)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Get.theme.primaryColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Baru',
                              style: TextStyle(
                                fontSize: 11,
                                color: Get.theme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      author.biodata,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Get.theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _stat(Icons.menu_book, '${author.novelCount} novel'),
                        const SizedBox(width: 16),
                        _stat(Icons.people,
                            '${_formatFollowers(author.followerCount)} pengikut'),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Get.theme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            author.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: Get.theme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 4),
        Text(text, style: Get.theme.textTheme.bodySmall),
      ],
    );
  }

  String _formatFollowers(int value) {
    if (value < 1000) return value.toString();

    if (value < 1000000) {
      final r = value / 1000;
      return '${r.toStringAsFixed(r.truncateToDouble() == r ? 0 : 1)}K';
    }

    final r = value / 1000000;
    return '${r.toStringAsFixed(r.truncateToDouble() == r ? 0 : 1)}M';
  }
}
