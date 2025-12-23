import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_brain/presentation/controllers/author/author_controller.dart';
import 'package:terra_brain/presentation/models/author_model.dart';
import 'package:terra_brain/presentation/themes/theme_data.dart';

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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.fetchAuthors();
            },
          ),
        ],
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        onChanged: controller.setSearchQuery,
        style: Get.theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Cari penulis...',
          hintStyle: Get.theme.textTheme.bodyMedium?.copyWith(
            color: Get.theme.hintColor.withOpacity(0.7),
          ),
          prefixIcon: Icon(Icons.search, color: Get.theme.primaryColor),
          suffixIcon: Icon(Icons.tune, color: Get.theme.hintColor),
          filled: true,
          fillColor: Get.theme.cardColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Get.theme.dividerColor,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Get.theme.dividerColor.withOpacity(0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Get.theme.primaryColor,
              width: 2,
            ),
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
          height: 56,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: categories.length,
            itemBuilder: (_, i) {
              final category = categories[i];
              final isSelected = selected == category;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: FilterChip(
                    key: ValueKey(category),
                    label: Text(
                      category,
                      style: Get.theme.textTheme.bodySmall?.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    backgroundColor: Get.theme.cardColor,
                    selectedColor: Get.theme.primaryColor.withOpacity(0.2),
                    side: BorderSide(
                      color: isSelected 
                        ? Get.theme.primaryColor 
                        : Get.theme.dividerColor.withOpacity(0.5),
                      width: isSelected ? 2 : 1,
                    ),
                    onSelected: (_) {
                      controller.setCategory(category);
                    },
                  ),
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
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Get.theme.primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Memuat data penulis...',
                  style: Get.theme.textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        final items = controller.structuredList;

        if (items.isEmpty) {
          return _emptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: items.length,
          itemBuilder: (_, index) {
            return _authorCard(items[index]);
          },
        );
      },
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Get.theme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_off,
                size: 80,
                color: Get.theme.primaryColor.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum ada penulis ditemukan',
              style: Get.theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Coba ubah filter atau cari dengan kata kunci lain',
              style: Get.theme.textTheme.bodySmall?.copyWith(
                color: Get.theme.hintColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                controller.setSearchQuery('');
                controller.setCategory('Semua');
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reset Filter'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _authorCard(Author author) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Get.toNamed('/author_profile/${author.id}'),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Get.theme.dividerColor.withOpacity(0.3),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: author.isPremium
                                ? AppThemeData.premiumColor
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: author.imageUrl != null &&
                                  author.imageUrl!.isNotEmpty
                              ? Image.network(
                                  author.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/default_profile.jpeg',
                                      fit: BoxFit.cover,
                                    );
                                  },
                                )
                              : Image.asset(
                                  'assets/images/default_profile.jpeg',
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      if (author.isPremium)
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppThemeData.premiumColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.workspace_premium,
                              size: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (author.isPremium)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
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
                            if (author.isNew)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                margin: author.isPremium
                                    ? const EdgeInsets.only(left: 4)
                                    : EdgeInsets.zero,
                                decoration: BoxDecoration(
                                  color: Get.theme.primaryColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Baru',
                                  style: TextStyle(
                                    fontSize: 9,
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
                          style: Get.theme.textTheme.bodySmall?.copyWith(
                            color: Get.theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _stat(Icons.menu_book, '${author.novelCount} novel'),
                            const SizedBox(width: 20),
                            _stat(Icons.people,
                                '${_formatFollowers(author.followerCount)} pengikut'),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Get.theme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                author.category,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Get.theme.primaryColor,
                                  fontWeight: FontWeight.w500,
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
        ),
      ),
    );
  }

  Widget _stat(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Get.theme.primaryColor,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: Get.theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
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
