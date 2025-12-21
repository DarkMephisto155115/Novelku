import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_brain/presentation/controllers/profile/profile_controller.dart';
import 'package:terra_brain/presentation/helpers/premium_popup_manager.dart';
import 'package:terra_brain/presentation/models/profile_model.dart';
import 'package:terra_brain/presentation/themes/theme_data.dart';
import 'package:terra_brain/presentation/widgets/profile_novel_card_widget.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return CustomScrollView(
          controller: controller.scrollController,
          slivers: [
            _buildAppBar(),
            _buildProfileHeader(controller.user.value),
            _buildTabSection(),
            Obx(() => controller.selectedTab.value == 0
                ? _buildMyNovelsSliver()
                : _buildFavoritesSliver()),
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
          ],
        );
      }),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 50,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppThemeData.primaryColor,
                AppThemeData.pinkColor,
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => Get.toNamed('/setting'),
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: controller.logout,
        ),
      ],
    );
  }

  SliverToBoxAdapter _buildProfileHeader(UserProfile user) {
    return SliverToBoxAdapter(
      child: Card(
        color: Get.theme.scaffoldBackgroundColor,
        elevation: 4,
        margin: const EdgeInsets.only(top: 30, left: 24, right: 24, bottom: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildAvatar(user),
              const SizedBox(height: 12),
              Text(
                user.name,
                style: Get.theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                user.username,
                style: Get.theme.textTheme.bodyMedium?.copyWith(
                  color:
                      Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                user.bio,
                textAlign: TextAlign.center,
                style: Get.theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              _buildEditProfileButton(),
              _buildPremiumSection(user),
              _buildStats(user),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(UserProfile user) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Get.theme.primaryColor, width: 2),
      ),
      child: ClipOval(
        child: user.profileImage != null && user.profileImage!.isNotEmpty
            ? Image.network(user.profileImage!, fit: BoxFit.cover)
            : Icon(Icons.person, size: 40, color: Get.theme.primaryColor),
      ),
    );
  }

  Widget _buildEditProfileButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => Get.toNamed('/edit_profile'),
        child: const Text('Edit Profil'),
      ),
    );
  }

  Widget _buildStats(UserProfile user) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat('Novel', user.novelCount.toString(), Icons.book),
          _stat('Dibaca', user.readCount.toString(), Icons.visibility),
          _stat('Followers', controller.formatNumber(user.followerCount),
              Icons.people),
          _stat('Following', user.followingCount.toString(), Icons.person_add),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 18),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  SliverToBoxAdapter _buildTabSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Get.theme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Obx(() => Row(
              children: [
                _tabButton('Novel Saya', 0),
                _tabButton('Favorit', 1),
              ],
            )),
      ),
    );
  }

  Widget _tabButton(String text, int index) {
    final selected = controller.selectedTab.value == index;
    return Expanded(
      child: ElevatedButton(
        onPressed: () => controller.switchTab(index),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              selected ? Get.theme.primaryColor : Get.theme.cardColor,
          foregroundColor:
              selected ? Colors.white : Get.theme.textTheme.bodyMedium?.color,
          elevation: 0,
        ),
        child: Text(text),
      ),
    );
  }

  Widget _buildMyNovelsSliver() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == controller.myNovels.length) {
              return controller.isLoadingMore.value
                  ? const Center(child: CircularProgressIndicator())
                  : const SizedBox.shrink();
            }

            final novel = controller.myNovels[index];
            return NovelCard(
              novel: novel,
              onEdit: () => controller.editNovel(novel.id),
            );
          },
          childCount: controller.myNovels.length + 1,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.56,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
      ),
    );
  }

  Widget _buildFavoritesSliver() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == controller.favoriteNovels.length) {
              return controller.isLoadingFavMore.value
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : const SizedBox.shrink();
            }

            final novel = controller.favoriteNovels[index];
            return FavoriteNovelTile(novel: novel);
          },
          childCount: controller.favoriteNovels.length + 1,
        ),
      ),
    );
  }

  Widget _buildPremiumSection(UserProfile user) {
    if (user.isPremium) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.amber.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.verified, color: Colors.orange),
            SizedBox(width: 12),
            Expanded(child: Text('Anda adalah pengguna Premium')),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Upgrade ke Premium',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Nikmati akses unlimited dan fitur eksklusif'),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                PremiumPopupManager.showPremiumPopup(
                  title: 'Upgrade ke Premium',
                  description: 'Nikmati membaca tanpa batas dengan premium!',
                  showCloseButton: true,
                );
              },
              child: const Text('Lihat Penawaran'),
            ),
          ),
        ],
      ),
    );
  }
}
