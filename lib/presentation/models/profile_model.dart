class UserNovel {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final String category;
  final int views;

  UserNovel({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.category,
    required this.views,
  });
}

class FavoriteNovel {
  final String id;
  final String title;
  final String coverUrl;
  final String genre;
  final int chapterCount;
  final int views;
  final String status; // Berlanjut / Selesai

  FavoriteNovel({
    required this.id,
    required this.title,
    required this.coverUrl,
    required this.genre,
    required this.chapterCount,
    required this.views,
    required this.status,
  });
}

class UserProfile {
  final String id;
  final String name;
  final String username;
  final String bio;
  final String? profileImage;
  final bool isPremium;

  final int novelCount;
  final int readCount;
  final int followerCount;
  final int followingCount;


  final List<UserNovel> myNovels;
  final List<FavoriteNovel> favoriteNovels;

  UserProfile({
    required this.id,
    required this.name,
    required this.username,
    required this.bio,
    this.profileImage,
    required this.isPremium,
    required this.novelCount,
    required this.readCount,
    required this.followerCount,
    required this.followingCount,
    required this.myNovels,
    required this.favoriteNovels,
  });

  UserProfile copyWith({
    String? name,
    String? username,
    String? bio,
    String? profileImage,
    bool? isPremium,
    int? novelCount,
    int? readCount,
    int? followerCount,
    int? followingCount,
    int? totalChaptersRead,
    int? totalWordsRead,
    int? readingStreak,
    List<UserNovel>? myNovels,
    List<FavoriteNovel>? favoriteNovels,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      profileImage: profileImage ?? this.profileImage,
      isPremium: isPremium ?? this.isPremium,
      novelCount: novelCount ?? this.novelCount,
      readCount: readCount ?? this.readCount,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      myNovels: myNovels ?? this.myNovels,
      favoriteNovels: favoriteNovels ?? this.favoriteNovels,
    );
  }
}