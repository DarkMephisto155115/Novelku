class Novel {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final int chapterCount;
  final int likeCount;
  final int viewCount;
  final bool isOngoing;

  Novel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.chapterCount,
    required this.likeCount,
    required this.viewCount,
    required this.isOngoing,
  });
}

class AuthorProfile {
  final String id;
  final String name;
  final String username;
  final String bio;
  final String? profileImage;
  final int novelCount;
  final int followerCount;
  final int followingCount;
  final int totalLikes;
  final List<Novel> novels;
  final bool isFollowing;

  AuthorProfile({
    required this.id,
    required this.name,
    required this.username,
    required this.bio,
    this.profileImage,
    required this.novelCount,
    required this.followerCount,
    required this.followingCount,
    required this.totalLikes,
    required this.novels,
    required this.isFollowing,
  });
}