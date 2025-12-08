import 'package:get/get.dart';
import 'package:terra_brain/presentation/models/author_profile_model.dart';

class AuthorProfileController extends GetxController {
  final Rx<AuthorProfile> author = AuthorProfile(
    id: '1',
    name: 'Sarah Martinez',
    username: '@sarahwrites',
    bio: 'Penulis romance dan drama. Mencintai cerita yang menyentuh hati',
    novelCount: 2,
    followerCount: 1234,
    followingCount: 45,
    totalLikes: 5420,
    novels: [
      Novel(
        id: '1',
        title: 'MARI',
        subtitle: 'Cinta di Musim Hujan',
        category: 'Romance',
        chapterCount: 15,
        likeCount: 3200,
        viewCount: 45600,
        isOngoing: false,
      ),
      Novel(
        id: '2',
        title: 'Berlanjut',
        subtitle: 'Melody of the Heart',
        category: 'Drama',
        chapterCount: 22,
        likeCount: 2220,
        viewCount: 2220,
        isOngoing: true,
      ),
    ],
    isFollowing: false,
  ).obs;

  void toggleFollow() {
    final currentAuthor = author.value;
    author.value = AuthorProfile(
      id: currentAuthor.id,
      name: currentAuthor.name,
      username: currentAuthor.username,
      bio: currentAuthor.bio,
      profileImage: currentAuthor.profileImage,
      novelCount: currentAuthor.novelCount,
      followerCount: currentAuthor.isFollowing 
          ? currentAuthor.followerCount - 1 
          : currentAuthor.followerCount + 1,
      followingCount: currentAuthor.followingCount,
      totalLikes: currentAuthor.totalLikes,
      novels: currentAuthor.novels,
      isFollowing: !currentAuthor.isFollowing,
    );
  }

  String formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}