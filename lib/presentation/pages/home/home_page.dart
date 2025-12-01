import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_brain/presentation/pages/novel/all_novel_page.dart';
import '../../controllers/home_controller.dart' as home_ctrl_pkg;
import '../../models/novel_item.dart';
import '../../widgets/section_header.dart';
import '../../models/novel_item.dart';
import '../../widgets/novel_card.dart';
import '../../widgets/section_header.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  // dummy data
  final List<NovelItem> recommended = [
    NovelItem(
        id: '1',
        title: 'Dunia Fantasi',
        author: 'Penulis A',
        coverUrl: 'https://picsum.photos/200/300?random=1',
        genre: ['Fantasy'],
        rating: 4.8,
        chapters: 45,
        readers: 12500),
    NovelItem(
        id: '2',
        title: 'Cinta di Musim Semi',
        author: 'Penulis B',
        coverUrl: 'https://picsum.photos/200/300?random=2',
        genre: ['Romance'],
        rating: 4.6,
        chapters: 32,
        readers: 8300),
    NovelItem(
        id: '3',
        title: 'Misteri Malam',
        author: 'Penulis C',
        coverUrl: 'https://picsum.photos/200/300?random=3',
        genre: ['Mystery'],
        rating: 4.9,
        chapters: 28,
        readers: 15200),
  ];

  final List<NovelItem> newThisWeek = [
    NovelItem(
        id: '4',
        title: 'Kisah Pertama',
        author: 'Sarah Wijaya',
        coverUrl: 'https://picsum.photos/200/300?random=4',
        genre: ['Slice of Life'],
        rating: 4.5,
        chapters: 12,
        readers: 4200,
        isNew: true),
    NovelItem(
        id: '5',
        title: 'Awal Petualangan',
        author: 'Andi Pratama',
        coverUrl: 'https://picsum.photos/200/300?random=5',
        genre: ['Adventure'],
        rating: 4.3,
        chapters: 20,
        readers: 6800,
        isNew: true),
    NovelItem(
        id: '6',
        title: 'Rahasia Tersembunyi',
        author: 'Maya Indah',
        coverUrl: 'https://picsum.photos/200/300?random=6',
        genre: ['Fantasy'],
        rating: 4.6,
        chapters: 16,
        readers: 5400,
        isNew: true),
  ];

  final List<NovelItem> explore = [
    NovelItem(
        id: '1',
        title: 'Dunia Fantasi',
        author: 'Penulis A',
        coverUrl: 'https://picsum.photos/200/300?random=1',
        genre: ['Fantasy'],
        rating: 4.8,
        chapters: 45,
        readers: 12500),
    NovelItem(
        id: '2',
        title: 'Cinta di Musim Semi',
        author: 'Penulis B',
        coverUrl: 'https://picsum.photos/200/300?random=2',
        genre: ['Romance'],
        rating: 4.6,
        chapters: 32,
        readers: 8300),
    NovelItem(
        id: '3',
        title: 'Misteri Malam',
        author: 'Penulis C',
        coverUrl: 'https://picsum.photos/200/300?random=3',
        genre: ['Mystery'],
        rating: 4.9,
        chapters: 28,
        readers: 15200),
    NovelItem(
        id: '7',
        title: 'Petualangan Hebat',
        author: 'Penulis D',
        coverUrl: 'https://picsum.photos/200/300?random=7',
        genre: ['Adventure'],
        rating: 4.7,
        chapters: 50,
        readers: 20100),
  ];

  final List<Map<String, dynamic>> newAuthors = [
    {
      'name': 'Sarah Wijaya',
      'profileUrl': 'https://picsum.photos/100/100?random=10',
      'novels': 5,
    },
    {
      'name': 'Andi Pratama',
      'profileUrl': 'https://picsum.photos/100/100?random=11',
      'novels': 3,
    },
    {
      'name': 'Maya Indah',
      'profileUrl': 'https://picsum.photos/100/100?random=12',
      'novels': 4,
    },
    {
      'name': 'Maya Indah',
      'profileUrl': 'https://picsum.photos/100/100?random=12',
      'novels': 4,
    },
    {
      'name': 'Andi Pratama',
      'profileUrl': 'https://picsum.photos/100/100?random=11',
      'novels': 3,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // attempt to find existing controllers, fallback to local dummy controllers
    dynamic homeController;
    dynamic favoritesController;
    try {
      homeController = Get.find<home_ctrl_pkg.HomeController>();
    } catch (e) {
      homeController = null;
    }

    return Scaffold(
      backgroundColor: Colors.white,
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
              SizedBox(
                
                height: 220,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, idx) =>
                      NovelCardHorizontal(item: recommended[idx]),
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemCount: recommended.length,
                ),
              ),

              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text('✨ Novel Baru Minggu Ini',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                    TextButton(
                        onPressed: () {Get.toNamed('/all_novel');}, child: const Text('Lihat Semua'))
                  ],
                ),
              ),
              SizedBox(
                height: 200,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, idx) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(newThisWeek[idx].coverUrl,
                                height: 140,
                                width: 140,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                    height: 140,
                                    width: 140,
                                    color: Colors.grey[300])),
                          ),
                          if (newThisWeek[idx].isNew)
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
                          child: Text(newThisWeek[idx].title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600))),
                      SizedBox(
                          width: 140,
                          child: Text(newThisWeek[idx].author,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey))),
                    ],
                  ),
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemCount: newThisWeek.length,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text('✍️ Penulis Baru',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                    TextButton(
                        onPressed: () {Get.toNamed('/all_author');}, child: const Text('Lihat Semua'))
                  ],
                ),
              ),
              SizedBox(
                height: 140,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: newAuthors.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, idx) {
                    final author = newAuthors[idx];
                    return Column(
                      children: [
                        ClipOval(
                          child: Image.network(
                            author['profileUrl'],
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 80,
                              width: 80,
                              color: Colors.grey[300],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 80,
                          child: Text(
                            author['name'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: Text(
                            '${author['novels']} Novel',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SectionHeader(title: '❤️ Favorit Saya'),
              ),
              // Use favoritesController if available
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
                                genre: favs[i].genre ?? 'Unknown',
                                rating: favs[i].rating ?? 0.0,
                                chapters: favs[i].chapters ?? 0,
                                readers: favs[i].readers ?? 0))),
                  );
                })
              else
                // fallback dummy
                Column(children: [
                  for (var it in recommended) NovelCardVertical(item: it)
                ]),

              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SectionHeader(title: '📚 Jelajahi Novel'),
              ),

              // Tab selector (simplified)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(child: _TabPill(text: 'Trending', selected: true)),
                    const SizedBox(width: 8),
                    Expanded(child: _TabPill(text: 'Terbaru', selected: false)),
                    const SizedBox(width: 8),
                    Expanded(child: _TabPill(text: 'Selesai', selected: false)),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              Column(children: [
                for (var e in explore) NovelCardVertical(item: e)
              ]),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            child: const TextField(
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Cari novel atau penulis...',
                  prefixIcon: Icon(Icons.search)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
              Get.to(SemuaNovelPage());
            },
          ),
          _NavItem(
            icon: Icons.edit,
            label: 'Tulis',
            selected: false,
            onTap: () {
              print("Tulis Clicked");
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
              // Get.to(ProfilePage());
              Get.toNamed('/profile_page');
            },
          ),
        ],
      ),
    );
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
