import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_brain/presentation/controllers/author_controller.dart';
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
          // Search Bar
          _buildSearchBar(),

          // Category Filter
          _buildCategoryFilter(),

          // Authors List
          Expanded(
            child: _buildAuthorsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Get.theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          onChanged: controller.setSearchQuery,
          decoration: InputDecoration(
            hintText: 'Cari penulis...',
            prefixIcon: Icon(Icons.search, color: Get.theme.hintColor),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final category = controller.categories[index];

          return Obx(() {
            final isSelected = controller.selectedCategory.value == category;

            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (_) => controller.setCategory(category),
                backgroundColor: Get.theme.cardColor,
                selectedColor: Get.theme.primaryColor.withOpacity(0.2),
                checkmarkColor: Get.theme.primaryColor,
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildAuthorsList() {
    return Obx(() {
      final items = controller.structuredList;

      if (items.isEmpty) {
        return Center(
          child: Text(
            'Tidak ada penulis ditemukan',
            style: Get.theme.textTheme.bodyMedium,
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          if (item == '_header_new') {
            return _buildSectionHeader('Penulis Baru');
          }

          if (item == '_divider_new') {
            return _buildDivider();
          }

          if (item == '_header_popular') {
            return _buildSectionHeader('Penulis Populer');
          }

          // Otherwise it's an Author
          return _buildAuthorCard(item as Author);
        },
      );
    });
  }

  Widget _buildListItem(int index, List<Author> authors) {
    int currentIndex = 0;

    // Check for New Authors section
    final newAuthors = controller.newAuthors;
    if (newAuthors.isNotEmpty) {
      if (index == currentIndex) {
        return _buildSectionHeader('Penulis Baru');
      }
      currentIndex++;

      for (int i = 0; i < newAuthors.length; i++) {
        if (index == currentIndex) {
          return _buildAuthorCard(newAuthors[i]);
        }
        currentIndex++;
      }

      if (index == currentIndex) {
        return _buildDivider();
      }
      currentIndex++;
    }

    // Check for Popular Authors section
    final popularAuthors = controller.popularAuthors;
    if (popularAuthors.isNotEmpty) {
      if (index == currentIndex) {
        return _buildSectionHeader('Penulis Populer');
      }
      currentIndex++;

      for (int i = 0; i < popularAuthors.length; i++) {
        if (index == currentIndex) {
          return _buildAuthorCard(popularAuthors[i]);
        }
        currentIndex++;
      }
    }

    // Calculate actual author index for other authors
    final sectionHeadersCount = _getSectionCount(authors);
    final authorIndex = index - sectionHeadersCount;

    if (authorIndex >= 0 && authorIndex < authors.length) {
      return _buildAuthorCard(authors[authorIndex]);
    }

    return SizedBox.shrink();
  }

  int _getSectionCount(List<Author> authors) {
    int count = 0;
    if (controller.newAuthors.isNotEmpty) {
      count += 2; // Header + Divider
    }
    if (controller.popularAuthors.isNotEmpty) {
      count += 1; // Header
    }
    return count;
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: Get.theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Divider(
        color: Get.theme.dividerColor.withOpacity(0.3),
        height: 1,
      ),
    );
  }

  Widget _buildAuthorCard(Author author) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Get.toNamed('/author_profile');
      },
      // ),
      child: Card(
        margin: EdgeInsets.only(bottom: 12),
        color: Get.theme.cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FOTO DI KIRI
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.asset(
                  author.imageUrl ?? 'assets/images/default_profile.jpeg',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),

              SizedBox(width: 16),

              // INFO DI KANAN
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author.name,
                      style: Get.theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      author.description,
                      style: Get.theme.textTheme.bodyMedium?.copyWith(
                        color: Get.theme.textTheme.bodyMedium?.color
                            ?.withOpacity(0.8),
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        _buildStatItem(
                            '${author.novelCount} novel', Icons.book),
                        SizedBox(width: 16),
                        _buildStatItem(
                          '${_formatFollowerCount(author.followerCount)} pengikut',
                          Icons.people,
                        ),
                        SizedBox(width: 16),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Get.theme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            author.category,
                            style: TextStyle(
                              color: Get.theme.primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String text, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
        ),
        SizedBox(width: 4),
        Text(
          text,
          style: Get.theme.textTheme.bodySmall?.copyWith(
            color: Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  String _formatFollowerCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
