import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_brain/presentation/controllers/author_profile_controller.dart';
import 'package:terra_brain/presentation/models/author_profile_model.dart';
import 'package:terra_brain/presentation/themes/theme_data.dart';

class AuthorProfilePage extends GetView<AuthorProfileController> {
  const AuthorProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: Obx(() {
        final author = controller.author.value;

        return Stack(
          children: [
            // BAGIAN BAWAH: SliverScroll
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 50,
                  // pinned: true,
                  backgroundColor: Colors.transparent,
                  // elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppThemeData.primaryColor,
                            AppThemeData.pinkColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.share),
                      onPressed: () {
                        Get.snackbar(
                          'Berbagi',
                          'Bagikan profil ${author.name}',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                    ),
                  ],
                ),

                // Space kosong tempat profile card muncul

                // SliverToBoxAdapter(child: SizedBox(height: 120)),

                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: Offset(
                        0, 20), // ini yang bikin card naik ke atas AppBar
                    child: _buildMainProfile(author),
                  ),
                ),

                // // Konten Novel
                // SliverToBoxAdapter(
                //   child: _buildNovelsSection(author),
                // ),

                SliverToBoxAdapter(child: SizedBox(height: 36)),
                SliverToBoxAdapter(child: _buildNovelsSection(author)),
              ],
            ),

            // LAYER ATAS: Profile Card + Avatar (tidak tertutup AppBar)
            // Positioned(
            //   top: 80,
            //   left: 0,
            //   right: 0,
            //   child: _buildMainProfile(author),
            // ),
          ],
        );
      }),
    );
  }

  // =====================================
  // PROFILE CARD
  // =====================================
  Widget _buildMainProfile(AuthorProfile author) {
    return Container(
      margin: EdgeInsets.only(top: 10, left: 20, right: 20),
      padding: EdgeInsets.only(top: 0, bottom: 20, left: 16, right: 16),
      decoration: BoxDecoration(
        // color: Get.theme.cardColor,
        color: AppThemeData.lightCardBackground,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 9),
          )
        ],
      ),
      child: Column(
        children: [
          // Avatar floating above card
          Transform.translate(
            offset:
                Offset(0, -40), // sesuaikan tinggi supaya avatar naik sedikit
            child: CircleAvatar(
              radius: 55,
              backgroundColor: AppThemeData.darkHintText,
              child: CircleAvatar(
                radius: 52,
                backgroundImage:
                    AssetImage('assets/images/default_profile.jpeg'),
              ),
            ),
          ),

          SizedBox(height: 1),
          Text(
            author.name,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            author.username,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),

          SizedBox(height: 12),

          Text(
            author.bio,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),

          SizedBox(height: 16),

          // Follow Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.toggleFollow,
              icon: Icon(author.isFollowing ? Icons.check : Icons.person_add),
              label: Text(
                author.isFollowing ? "Mengikuti" : "Ikuti",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
                backgroundColor:
                    author.isFollowing ? Colors.white : Get.theme.primaryColor,
                foregroundColor:
                    author.isFollowing ? Get.theme.primaryColor : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: author.isFollowing
                      ? BorderSide(color: Get.theme.primaryColor, width: 1)
                      : BorderSide.none,
                ),
              ),
            ),
          ),

          SizedBox(height: 16),
          _buildStatsRedesign(author),
        ],
      ),
    );
  }

  // =====================================
  // STATS
  // =====================================
  Widget _buildStatsRedesign(AuthorProfile author) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _statItem("Novel", author.novelCount.toString()),
        _statItem("Followers", controller.formatNumber(author.followerCount)),
        _statItem("Following", author.followingCount.toString()),
        _statItem("Likes", controller.formatNumber(author.totalLikes)),
      ],
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  // =====================================
  // NOVEL LIST
  // =====================================
  Widget _buildNovelsSection(AuthorProfile author) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon(Icons.auto_stories, color: Get.theme.primaryColor, size: 20),
              // SizedBox(width: 8),
              Text(
                'Novel (${author.novels.length})',
                style: Get.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Column(
            children:
                author.novels.map((novel) => _buildNovelCard(novel)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNovelCard(Novel novel) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // COVER IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                // novel.coverUrl ?? 'assets/images/default_cover.jpeg',
                'assets/images/book.jpg',
                width: 60,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),

            SizedBox(width: 12),

            // TEXT SECTION
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Status Badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          novel.title,
                          style: Get.theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (novel.isOngoing)
                        _buildStatusBadge("Berlanjut", Colors.blue)
                      else
                        _buildStatusBadge("Selesai", Colors.green),
                    ],
                  ),

                  SizedBox(height: 4),
                  Text(
                    novel.category,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Get.theme.primaryColor,
                    ),
                  ),

                  SizedBox(height: 6),

                  Row(
                    children: [
                      _buildSmallStat(Icons.format_list_numbered,
                          "${novel.chapterCount} chapter"),
                      SizedBox(width: 10),
                      _buildSmallStat(Icons.favorite,
                          controller.formatNumber(novel.likeCount)),
                      SizedBox(width: 10),
                      _buildSmallStat(Icons.visibility,
                          controller.formatNumber(novel.viewCount) + " views"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSmallStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        )
      ],
    );
  }
}
