import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_brain/presentation/helpers/premium_popup_manager.dart';
import 'package:terra_brain/presentation/pages/novel/all_novel_page.dart';
import 'package:terra_brain/presentation/themes/theme_data.dart';
import '../../controllers/author/author_controller.dart' as home_ctrl_pkg;
import '../../controllers/home_controller.dart' as home_ctrl_pkg;
import '../../controllers/author/author_controller.dart';
import '../../controllers/setting_controller.dart';
import '../../controllers/write/writing_controller.dart';
import '../../models/novel_item.dart';
import '../../widgets/section_header.dart';
import '../../widgets/novel_card.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedFilter = 'Trending';

  @override
  Widget build(BuildContext context) {
    dynamic homeController;
    dynamic favoritesController;
    try {
      homeController = Get.find<home_ctrl_pkg.HomeController>();
    } catch (e) {
      homeController = Get.put(home_ctrl_pkg.HomeController());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      PremiumPopupManager.checkAndShowPopupOnLaunch();
    });

    return Obx(() {
      final writingController = Get.find<WritingController>();
      final isDarkMode = writingController.themeController.isDarkMode;
      final bgColor = isDarkMode ? Colors.grey.shade900 : Colors.white;

      return Scaffold(
        backgroundColor: bgColor,
      bottomNavigationBar: _buildBottomNav(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SectionHeader(title: '🔥 Rekomendasi Hari Ini'),
              ),
              Obx(() {
                final recommended = homeController.recommendedNovels;
                if (recommended.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'Tidak ada novel yang tersedia',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  );
                }
                return SizedBox(
                  height: 230,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, idx) => NovelCardHorizontal(
                      item: recommended[idx],
                      onTap: () {
                        Get.find<home_ctrl_pkg.HomeController>().clearSearch();
                        Get.toNamed('/novel_chapters',
                            arguments: {'novelId': recommended[idx].id});
                      },
                    ),
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemCount: recommended.length,
                  ),
                );
              }),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text('✨ Novel Baru Minggu Ini',
                          style: TextStyle(
                              fontSize: 16, 
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : Colors.black)),
                    ),
                    TextButton(
                        onPressed: () {
                          Get.find<home_ctrl_pkg.HomeController>().clearSearch();
                          Get.toNamed('/all_novel');
                        },
                        child: Text('Lihat Semua', style: TextStyle(color: isDarkMode ? Colors.blue[300] : Colors.blue)))
                  ],
                ),
              ),
              Obx(() {
                final newNovels = homeController.newNovels;
                if (newNovels.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'Belum ada novel baru',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  );
                }
                return SizedBox(
                  height: 200,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, idx) => GestureDetector(
                      onTap: () {
                        Get.find<home_ctrl_pkg.HomeController>().clearSearch();
                        Get.toNamed('/novel_chapters', arguments: {'novelId': newNovels[idx].id});
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(newNovels[idx].coverUrl,
                                    height: 140,
                                    width: 140,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                        height: 140,
                                        width: 140,
                                        color: isDarkMode ? Colors.grey[700] : Colors.grey[300])),
                              ),
                              if (newNovels[idx].isNew)
                                Positioned(
                                  left: 8,
                                  top: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: const Text('Baru',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12)),
                                  ),
                                )
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                              width: 140,
                              child: Text(newNovels[idx].title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: isDarkMode ? Colors.white : Colors.black))),
                          SizedBox(
                              width: 140,
                              child: Text(newNovels[idx].author,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 12, 
                                      color: isDarkMode ? Colors.grey[400] : Colors.grey))),
                        ],
                      ),
                    ),
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemCount: newNovels.length,
                  ),
                );
              }),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text('👥 Penulis Baru Minggu Ini',
                          style: TextStyle(
                              fontSize: 16, 
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : Colors.black)),
                    ),
                    TextButton(
                        onPressed: () {
                          Get.find<home_ctrl_pkg.HomeController>().clearSearch();
                          Get.toNamed('/list_author');
                        },
                        child: Text('Lihat Semua', style: TextStyle(color: isDarkMode ? Colors.blue[300] : Colors.blue)))
                  ],
                ),
              ),
              GetBuilder<AuthorsController>(
                init: AuthorsController(),
                builder: (authorsController) {
                  return Obx(() {
                    final newAuthors = authorsController.newAuthors;
                    if (newAuthors.isEmpty) {
                      return const SizedBox();
                    }

                    return SizedBox(
                      height: 120,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: newAuthors.take(10).length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, idx) {
                          final author = newAuthors[idx];
                          return GestureDetector(
                            onTap: () {
                              Get.find<home_ctrl_pkg.HomeController>().clearSearch();
                              Get.toNamed('/author_profile/${author.id}');
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: author.imageUrl != null &&
                                              author.imageUrl!.isNotEmpty
                                          ? Image.network(
                                              author.imageUrl!,
                                              width: 70,
                                              height: 70,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  width: 70,
                                                  height: 70,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.primaries[
                                                            idx %
                                                                Colors.primaries
                                                                    .length]
                                                        .withOpacity(0.2),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      author.name.isNotEmpty
                                                          ? author.name[0]
                                                              .toUpperCase()
                                                          : '?',
                                                      style: TextStyle(
                                                        fontSize: 28,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.primaries[
                                                            idx %
                                                                Colors.primaries
                                                                    .length],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            )
                                          : Container(
                                              width: 70,
                                              height: 70,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.primaries[idx %
                                                        Colors.primaries.length]
                                                    .withOpacity(0.2),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  author.name.isNotEmpty
                                                      ? author.name[0]
                                                          .toUpperCase()
                                                      : '?',
                                                  style: TextStyle(
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.primaries[
                                                        idx %
                                                            Colors.primaries
                                                                .length],
                                                  ),
                                                ),
                                              ),
                                            ),
                                    ),
                                    if (author.isPremium)
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFFFFD700),
                                                Color(0xFFFFA500)
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.star,
                                            size: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: 70,
                                  child: Text(
                                    author.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 70,
                                  child: Text(
                                    '${author.novelCount} novel',
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDarkMode ? Colors.grey[400] : Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  });
                },
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SectionHeader(title: '❤️ Favorit Saya'),
              ),
              if (favoritesController != null)
                Obx(() {
                  final favs = favoritesController.favorites ?? [];
                  if (favs.isEmpty) return const SizedBox();
                  return Column(
                    children: List.generate(
                        favs.length,
                        (i) => NovelCardVertical(
                            item: NovelItem(
                                id: favs[i].id,
                                title: favs[i].title ?? 'Unknown',
                                author: favs[i].author ?? '-',
                                coverUrl: favs[i].coverUrl ?? '',
                                genre: [favs[i].genre ?? 'Unknown'],
                                likeCount: 0,
                                chapters: favs[i].chapterCount ?? 0,
                                readers: favs[i].views ?? 0))),
                  );
                })
              else
                Obx(() {
                  final recommended = homeController.recommendedNovels;
                  if (recommended.isEmpty) return const SizedBox();
                  return Column(
                    children: [
                      for (var it in recommended.take(2))
                        NovelCardVertical(item: it)
                    ],
                  );
                }),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SectionHeader(title: '📚 Jelajahi Novel'),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: ['Trending', 'Terbaru', 'Terlaris']
                      .map((filter) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedFilter = filter;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: selectedFilter == filter
                                      ? (isDarkMode ? Colors.grey[700] : Colors.grey[300])
                                      : (isDarkMode ? Colors.grey[800] : Colors.white),
                                  border: Border.all(
                                    color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  filter,
                                  style: TextStyle(
                                    color: selectedFilter == filter
                                        ? (isDarkMode ? Colors.white : Colors.black)
                                        : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                                    fontWeight: selectedFilter == filter
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                final allNovels = homeController.allNovels;
                if (allNovels.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'Tidak ada novel yang tersedia',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  );
                }

                List<NovelItem> filteredNovels = [];

                if (selectedFilter == 'Trending') {
                  filteredNovels = homeController.filterByTrending(allNovels);
                } else if (selectedFilter == 'Terbaru') {
                  filteredNovels = homeController.filterByLatest(allNovels);
                } else if (selectedFilter == 'Terlaris') {
                  filteredNovels = homeController.filterByBestselling(allNovels);
                }

                return Column(
                  children: [
                    for (var e in filteredNovels.take(6))
                      NovelCardVertical(
                        item: e,
                        onTap: () {
                          Get.find<home_ctrl_pkg.HomeController>().clearSearch();
                          Get.toNamed('/novel_chapters',
                              arguments: {'novelId': e.id});
                        },
                      )
                  ],
                );
              }),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      );
    });
  }

  Widget _buildHeader(BuildContext context) {
    final homeController = Get.find<home_ctrl_pkg.HomeController>();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: [Color(0xFF8A2BE2), Color(0xFF6A00F4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                "assets/icons/novelku_logo.png",
                width: 50,
                height: 50,
              ),
              SizedBox(width: 12),
              Text('NovelKu',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: homeController.searchController,
              onChanged: homeController.updateSearchQuery,
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Cari novel atau penulis...',
                  prefixIcon: Icon(Icons.search)),
            ),
          ),
          Obx(() {
            if (homeController.searchQuery.value.isNotEmpty) {
              return _buildSearchResults(homeController);
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildSearchResults(home_ctrl_pkg.HomeController controller) {
    final writingController = Get.find<WritingController>();
    final isDarkMode = writingController.themeController.isDarkMode;
    final bgColor = isDarkMode ? Colors.grey.shade900 : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      constraints: const BoxConstraints(maxHeight: 400),
      child: Obx(() {
        if (controller.searchResults.isEmpty && controller.authorSearchResults.isEmpty) {
          return Center(
            child: Text('Tidak ada hasil ditemukan', style: TextStyle(color: textColor)),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.searchResults.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Novel',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey.shade400 : Colors.grey,
                    ),
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.searchResults.length,
                  separatorBuilder: (_, __) => Divider(color: isDarkMode ? Colors.grey.shade700 : null),
                  itemBuilder: (context, index) {
                    final novel = controller.searchResults[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          novel.coverUrl,
                          width: 40,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 40,
                            height: 60,
                            color: Colors.grey[300],
                          ),
                        ),
                      ),
                      title: Text(
                        novel.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
                      ),
                      subtitle: Text(
                        novel.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600]),
                      ),
                      onTap: () {
                        Get.toNamed('/novel_chapters', arguments: {'novelId': novel.id});
                      },
                    );
                  },
                ),
              ],
              
              if (controller.searchResults.isNotEmpty && controller.authorSearchResults.isNotEmpty)
                Divider(height: 24, color: isDarkMode ? Colors.grey.shade700 : null),

              if (controller.authorSearchResults.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Penulis',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey.shade400 : Colors.grey,
                    ),
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.authorSearchResults.length,
                  separatorBuilder: (_, __) => Divider(color: isDarkMode ? Colors.grey.shade700 : null),
                  itemBuilder: (context, index) {
                    final author = controller.authorSearchResults[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: author.imageUrl != null && author.imageUrl!.isNotEmpty
                            ? Image.network(
                                author.imageUrl!,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 40,
                                  height: 40,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.person, color: Colors.white),
                                ),
                              )
                            : Container(
                                width: 40,
                                height: 40,
                                color: Colors.grey[300],
                                child: const Icon(Icons.person, color: Colors.white),
                              ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            author.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
                          ),
                          if (author.isPremium) ...[
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
                      subtitle: Text(
                        '${author.followerCount} Pengikut',
                        style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600]),
                      ),
                      onTap: () {
                        Get.toNamed('/author_profile/${author.id}');
                      },
                    );
                  },
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBottomNav() {
    return Obx(() {
      final writingController = Get.find<WritingController>();
      final isDarkMode = writingController.themeController.isDarkMode;
      final navBgColor = isDarkMode ? Colors.grey.shade800 : Colors.white;

      return Container(
        decoration: BoxDecoration(
          color: navBgColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
            ),
          ],
        ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home,
            label: 'Beranda',
            selected: true,
            onTap: () {
              print("Beranda Clicked");
              // Get.to(HomePage());
            },
          ),
          _NavItem(
            icon: Icons.book,
            label: 'Novel',
            selected: false,
            onTap: () {
              print("Novel Clicked");
              Get.find<home_ctrl_pkg.HomeController>().clearSearch();
              Get.to(SemuaNovelPage());
            },
          ),
          _NavItem(
            icon: Icons.edit,
            label: 'Tulis',
            selected: false,
            onTap: () {
              print("Tulis Clicked");
              Get.find<home_ctrl_pkg.HomeController>().clearSearch();
              // Get.to(WritePage());
              Get.toNamed('/writing');
            },
          ),
          _NavItem(
            icon: Icons.person,
            label: 'Profil',
            selected: false,
            onTap: () {
              print("Profil Clicked");
              Get.find<home_ctrl_pkg.HomeController>().clearSearch();
              // Get.to(ProfilePage());
              Get.toNamed('/profile_page');
            },
          ),
        ],
      ),
      );
    });
  }
}

class _TabPill extends StatelessWidget {
  final String text;
  final bool selected;
  const _TabPill({required this.text, required this.selected});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
          color: selected ? Colors.grey[200] : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey.shade300)),
      child: Center(
          child: Text(text,
              style: TextStyle(
                  color: selected ? Colors.black : Colors.grey[600]))),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: selected ? Colors.blue : Colors.grey),
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.blue : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
