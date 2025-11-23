import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:terra_brain/presentation/controllers/home_controller.dart';
import 'package:terra_brain/presentation/controllers/favorites_controller.dart';
import 'package:terra_brain/presentation/themes/theme_data.dart';
import '../../routes/app_pages.dart';
import '../favorite_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final FavoritesController favoritesController =
        Get.put(FavoritesController());
    final HomeController homeController = Get.put(HomeController());

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple.shade900, Colors.black],
          ),
        ),
        child: SafeArea(
          child: Obx(() => CustomScrollView(
                slivers: [
                  // 🔹 AppBar + Search
                  SliverAppBar(
                    expandedHeight: 150.0,
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.deepPurple.shade900,
                    flexibleSpace: FlexibleSpaceBar(
                      title: const Text('Novelku',
                          style: TextStyle(color: Colors.white)),
                      background: Image.asset(
                        'assets/images/book.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(50),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: TextField(
                          controller: homeController.searchController,
                          onChanged: (value) =>
                              homeController.searchQuery.value = value,
                          decoration: InputDecoration(
                            hintText: 'Cari rekomendasi cerita...',
                            hintStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.deepPurple.shade800,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon:
                                const Icon(Icons.search, color: Colors.white),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),

                  // 🔹 Konten utama
                  SliverToBoxAdapter(
                    child: AnimationLimiter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: AnimationConfiguration.toStaggeredList(
                          duration: const Duration(milliseconds: 375),
                          childAnimationBuilder: (widget) => SlideAnimation(
                            horizontalOffset: 50.0,
                            child: FadeInAnimation(child: widget),
                          ),
                          children: [
                            _buildSectionTitle('Cerita Populer'),
                            _buildStoryCarousel(homeController),
                            _buildSectionTitle('Kategori'),
                            CategoryList(onCategoryTap: (String category) {}),
                            _buildAuthorCard(),
                            _buildSectionTitle('Rekomendasi untuk Anda'),
                            _buildRecommendedStories(
                                homeController, favoritesController),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // 🔹 Judul section
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  // 🔹 Carousel dari stories terbaru
  Widget _buildStoryCarousel(HomeController controller) {
    final stories = controller.filteredStories;

    if (stories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('Belum ada cerita.',
              style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];
          final imageUrl = story['image'] ?? 'assets/images/book.jpg';
          final title = story['title'] ?? 'Tanpa Judul';
          final author = story['author'] ?? 'Anonim';

          return Padding(
            padding: const EdgeInsets.only(left: 16),
            child: GestureDetector(
              onTap: () {
                // Buka halaman detail (bisa dikembangkan nanti)
                Get.snackbar("Buka Cerita", "Judul: $title");
              },
              child: Container(
                width: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.deepPurpleAccent.withOpacity(0.3),
                  image: imageUrl.toString().startsWith('http')
                      ? DecorationImage(
                          image: NetworkImage(imageUrl), fit: BoxFit.cover)
                      : DecorationImage(
                          image: AssetImage(imageUrl), fit: BoxFit.cover),
                ),
                child: Container(
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent
                      ],
                    ),
                  ),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAuthorCard() {
    return Center(
      child: GestureDetector(
        onTap: () => (
          Get.snackbar("hello", "masuk ke halaman author"),
          Get.toNamed('list_author'),
        ),
        child: const Text(
          'Author Card',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // 🔹 Daftar rekomendasi cerita
  Widget _buildRecommendedStories(
      HomeController controller, FavoritesController favoritesController) {
    final stories = controller.filteredStories;

    if (stories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'Tidak ada rekomendasi.',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stories.length,
      itemBuilder: (context, index) {
        final story = stories[index];
        final title = story['title'];
        final author = story['author'];
        final category = story['category'];
        final imageUrl = story['image'] ?? 'assets/images/book.jpg';
        final chapterCount = story['chapters']?.length ?? 0;

        return Card(
          color: Colors.deepPurple.shade800.withOpacity(0.6),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl.toString().startsWith('http')
                  ? Image.network(imageUrl,
                      width: 60, height: 60, fit: BoxFit.cover)
                  : Image.asset(imageUrl,
                      width: 60, height: 60, fit: BoxFit.cover),
            ),
            title: Text(title,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text(
              "$author • $category • $chapterCount chapter",
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.favorite_border, color: Colors.pinkAccent),
              onPressed: () {
                // favoritesController.toggleFavorite(story);
              },
            ),
            onTap: () {
              // TODO: arahkan ke detail story
              Get.snackbar("Detail Cerita", "Kamu memilih '$title'");
            },
          ),
        );
      },
    );
  }

  // 🔹 Bottom Navigation
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4A148C), // Deep Purple 900
            Color(0xFF1A1A2E), // Hitam kebiruan gelap
          ],
        ),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          topLeft: Radius.circular(30),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent, // penting agar gradient terlihat
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          selectedIconTheme: const IconThemeData(size: 28),
          unselectedIconTheme: const IconThemeData(size: 24),
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
            BottomNavigationBarItem(
                icon: Icon(Icons.book), label: 'Perpustakaan'),
            BottomNavigationBarItem(icon: Icon(Icons.post_add), label: 'Tulis'),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite), label: 'Favorit'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          ],
          onTap: (index) {
            switch (index) {
              case 1:
                Get.toNamed(Routes.API);
                break;
              case 2:
                Get.toNamed('/write');
                break;
              case 3:
                Get.to(() => const FavoritesPage());
                break;
              case 4:
                Get.toNamed(Routes.PROFILE);
                break;
            }
          },
        ),
      ),
    );
  }
}

// 🔹 Widget kategori tetap sama
class CategoryList extends StatelessWidget {
  CategoryList({super.key, required this.onCategoryTap});

  final void Function(String category) onCategoryTap;
  final List<String> categories = [
    'All',
    'Komedi',
    'Horor',
    'Romansa',
    'Thriller',
    'Fantasi',
    'Fiksi Ilmiah',
    'Misteri',
    'Aksi',
  ];

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () {
              homeController.selectCategory(category);
              onCategoryTap(category);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Obx(() {
                final isSelected =
                    homeController.selectedCategory.value == category;
                return Chip(
                  label: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  backgroundColor:
                      isSelected ? Colors.deepPurpleAccent : Colors.deepPurple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}
