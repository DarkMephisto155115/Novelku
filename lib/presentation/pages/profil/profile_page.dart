import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_brain/presentation/controllers/profile/profile_controller.dart';
import 'package:terra_brain/presentation/helpers/premium_popup_manager.dart';
import 'package:terra_brain/presentation/models/profile_model.dart';
import 'package:terra_brain/presentation/themes/theme_data.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: Obx(() {

        final user = controller.user.value;
        final isLoading = controller.isLoading.value;

        if (isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        return CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 50,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppThemeData.primaryColor,
                        // Get.theme.colorScheme.secondary.withOpacity(0.2),
                        AppThemeData.pinkColor,
                      ],
                    ),
                  ),
                ),
              ),
              pinned: true,
              actions: [
                IconButton(
                  icon: Icon(Icons.settings_outlined),
                  onPressed: () {
                    Get.toNamed('/setting');
                  },
                ),
                IconButton(
                    onPressed: controller.logout, icon: Icon(Icons.logout)),
              ],
            ),

            // Profile Content
            SliverList(
              delegate: SliverChildListDelegate([
                _buildProfileHeader(user),
                // _buildPremiumSection(user),
                // _buildStatsSection(user),
                _buildTabSection(),
                _buildContentSection(user),
                SizedBox(height: 20),
              ]),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildProfileHeader(UserProfile user) {
    return Card(
      // padding: EdgeInsets.all(24),
      color: Get.theme.scaffoldBackgroundColor,
      elevation: 4,
      margin: EdgeInsets.only(top: 30, left: 24, right: 24, bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Get.theme.primaryColor.withOpacity(0.2),
                border: Border.all(
                  color: Get.theme.primaryColor,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child:
                    user.profileImage != null && user.profileImage!.isNotEmpty
                        ? Image.network(
                            user.profileImage!,
                            fit: BoxFit.cover,
                          )
                        : Icon(
                            Icons.person,
                            size: 40,
                            color: Get.theme.primaryColor,
                          ),
              ),
            ),

            SizedBox(height: 12),

            // NAMA
            Text(
              user.name,
              style: Get.theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 4),

            // USERNAME
            Text(
              user.username,
              style: Get.theme.textTheme.bodyMedium?.copyWith(
                color: Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 12),

            // BIO
            Text(
              user.bio,
              style: Get.theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 16),

            // TOMBOL EDIT PROFIL
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.toNamed('/edit_profile'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Get.theme.primaryColor,
                  side: BorderSide(color: Get.theme.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 8),
                ),
                child: Text(
                  'Edit Profil',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            _buildPremiumSection(user),
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Get.theme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistik',
                    style: Get.theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                          'Novel', user.novelCount.toString(), Icons.book),
                      _buildStatItem('Dibaca', user.readCount.toString(),
                          Icons.visibility),
                      _buildStatItem(
                          'Followers',
                          controller.formatNumber(user.followerCount),
                          Icons.people),
                      _buildStatItem('Following',
                          user.followingCount.toString(), Icons.person_add),
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

  Widget _buildPremiumSection(UserProfile user) {
    if (user.isPremium) {
      return Container(
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.amber.shade100,
              Colors.orange.shade100,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              Icons.verified,
              color: Colors.orange,
              size: 24,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Anda adalah pengguna Premium',
                style: TextStyle(
                  color: Colors.orange.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Get.theme.primaryColor.withOpacity(0.1),
            Get.theme.colorScheme.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Get.theme.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: Colors.amber,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Upgrade ke Premium',
                style: Get.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Nikmati akses unlimited dan fitur eksklusif lainnya',
            style: Get.theme.textTheme.bodyMedium?.copyWith(
              color: Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              // onPressed: controller.upgradeToPremium,
              onPressed: () {
                PremiumPopupManager.showPremiumPopup(
                  title: "Upgrade ke Premium",
                  description: "Nikmati membaca tanpa batas dengan premium!!",
                  showCloseButton: true,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Lihat Penawaran',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        SizedBox(height: 20),
        Text(
          value,
          style: Get.theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: Get.theme.textTheme.bodySmall?.copyWith(
            color: Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTabSection() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() => Row(
            children: [
              Expanded(
                child: _buildTabButton('Novel Saya', 0),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildTabButton('Favorit', 1),
              ),
            ],
          )),
    );
  }

  Widget _buildTabButton(String text, int index) {
    return ElevatedButton(
      onPressed: () => controller.switchTab(index),
      style: ElevatedButton.styleFrom(
        backgroundColor: controller.selectedTab.value == index
            ? Get.theme.primaryColor
            : Get.theme.cardColor,
        foregroundColor: controller.selectedTab.value == index
            ? Colors.white
            : Get.theme.textTheme.bodyMedium?.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildContentSection(UserProfile user) {
    return Obx(() {
      if (controller.selectedTab.value == 0) {
        return _buildMyNovelsSection(user); // desain baru
      } else {
        return _buildFavoritesSection(user); // desain baru
      }
    });
  }

  Widget _buildMyNovelsSection(UserProfile user) {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.56,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: user.myNovels.length,
        itemBuilder: (context, index) {
          final novel = user.myNovels[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // COVER
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

                  SizedBox(height: 6),

                  // JUDUL
                  Text(
                    novel.title,
                    style: Get.theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // PENULIS
                  Text(
                    novel.author,
                    style: Get.theme.textTheme.bodySmall?.copyWith(
                      color: Get.theme.textTheme.bodySmall?.color
                          ?.withOpacity(0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoritesSection(UserProfile user) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: user.favoriteNovels.map((novel) {
          return Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                )
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
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/book.jpg',
                        width: 75,
                        height: 105,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),

                SizedBox(width: 12),

                // INFORMATION
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TITLE + EDIT ICON
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              novel.title,
                              style: Get.theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Icon(Icons.edit,
                              size: 18,
                              color: Get.theme.primaryColor.withOpacity(0.8)),
                        ],
                      ),

                      SizedBox(height: 4),

                      // GENRE TAG
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          novel.genre,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      SizedBox(height: 6),

                      // CHAPTER + VIEWS
                      Row(
                        children: [
                          Icon(Icons.menu_book, size: 14, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            '${novel.chapterCount} chapter',
                            style: TextStyle(fontSize: 12),
                          ),
                          SizedBox(width: 12),
                          Icon(Icons.favorite, size: 14, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            controller.formatNumber(novel.views) + ' views',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 8),

                // STATUS BADGE
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      color: novel.status == 'Selesai'
                          ? Colors.green.shade700
                          : Colors.blue.shade700,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}