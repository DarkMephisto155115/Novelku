import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_brain/presentation/controllers/author/author_profile_controller.dart';
import 'package:terra_brain/presentation/models/author_profile_model.dart';
import 'package:terra_brain/presentation/models/novel_model.dart';
import 'package:terra_brain/presentation/themes/theme_data.dart';

class AuthorProfilePage extends GetView<AuthorProfileController> {
  const AuthorProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.errorMessage.isNotEmpty) {
            return Center(
              child: Text(
                controller.errorMessage.value,
                style: TextStyle(
                  color: Get.theme.textTheme.bodyMedium?.color,
                ),
              ),
            );
          }
          final author = controller.author.value;
          if (author == null) {
            return Center(
              child: Text(
                'Data penulis tidak tersedia',
                style: TextStyle(
                  color: Get.theme.textTheme.bodyMedium?.color,
                ),
              ),
            );
          }
          return _buildContent(author);
        },
      ),
    );
  }

  Widget _buildContent(AuthorProfile author) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 60,
          backgroundColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
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
              icon: const Icon(Icons.share),
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
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: const Offset(0, 15),
            child: _buildMainProfile(author),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 36),
        ),
        SliverToBoxAdapter(
          child: _buildNovelsSection(author),
        ),
      ],
    );
  }

  Widget _buildMainProfile(AuthorProfile author) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.only(
        top: 20,
        bottom: 20,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: AppThemeData.lightCardBackground,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 9),
          )
        ],
      ),
      child: Column(
        children: [
          Transform.translate(
            offset: const Offset(0, 0),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: author.isPremium
                          ? AppThemeData.premiumColor
                          : AppThemeData.darkHintText,
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: author.profileImage != null &&
                            author.profileImage!.isNotEmpty
                        ? Image.network(
                            author.profileImage!,
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
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppThemeData.premiumColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.workspace_premium,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  (author.name.isNotEmpty ? author.name : author.username),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (author.isPremium) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color.fromARGB(255, 251, 255, 34),
                        AppThemeData.premiumColor,
                        const Color.fromARGB(255, 203, 108, 0).withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Premium',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '@${author.username}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            author.bio,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Obx(
              () {
                final isFollowing = controller.isFollowing.value;
                return ElevatedButton.icon(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.toggleFollow,
                  icon: Icon(
                    isFollowing ? Icons.check : Icons.person_add,
                  ),
                  label: Text(
                    isFollowing ? 'Mengikuti' : 'Ikuti',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor:
                        isFollowing ? Colors.white : Get.theme.primaryColor,
                    foregroundColor:
                        isFollowing ? Get.theme.primaryColor : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isFollowing
                          ? BorderSide(
                              color: Get.theme.primaryColor,
                            )
                          : BorderSide.none,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildStats(author),
        ],
      ),
    );
  }

  Widget _buildStats(AuthorProfile author) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _statItem('Novel', author.novelCount.toString()),
        _statItem(
          'Dibaca',
          controller.formatNumber(author.readCount),
        ),
        _statItem(
          'Followers',
          controller.formatNumber(author.followerCount),
        ),
        _statItem(
          'Following',
          author.followingCount.toString(),
        ),
        _statItem(
          'Likes',
          controller.formatNumber(author.totalLikes),
        ),
      ],
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildNovelsSection(AuthorProfile author) {
    if (author.novels.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text('Belum ada novel'),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Novel (${author.novels.length})',
            style: Get.theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children:
                author.novels.map((novel) => _buildNovelCard(novel)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNovelCard(Novel novel) {
    return GestureDetector(
      onTap: () {
        Get.toNamed('/novel_chapters', arguments: {'novelId': novel.id});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Get.theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: novel.imageUrl != null && novel.imageUrl!.isNotEmpty
                    ? Image.network(
                        novel.imageUrl!,
                        width: 60,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Image.asset(
                            'assets/images/book.jpg',
                            width: 60,
                            height: 80,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset(
                        'assets/images/book.jpg',
                        width: 60,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      _buildStatusBadge(
                        novel.isOngoing ? 'Berlanjut' : 'Selesai',
                        novel.isOngoing ? Colors.blue : Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    novel.category,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Get.theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildSmallStat(
                        Icons.format_list_numbered,
                        '${novel.chapterCount} bab',
                      ),
                      const SizedBox(width: 10),
                      _buildSmallStat(
                        Icons.thumb_up,
                        controller.formatNumber(novel.likeCount),
                      ),
                      const SizedBox(width: 10),
                      _buildSmallStat(
                        Icons.visibility,
                        '${controller.formatNumber(novel.viewCount)} views',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
