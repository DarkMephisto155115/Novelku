class Chapter {
  final String id;
  final String title;
  final String content;
  final String author;
  final int chapterNumber;
  final int likeCount;
  final int commentCount;
  final DateTime publishedAt;

  Chapter({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.chapterNumber,
    required this.likeCount,
    required this.commentCount,
    required this.publishedAt,
  });
}

class Comment {
  final String id;
  final String userName;
  final String userAvatar;
  final String content;
  final DateTime timestamp;
  final int likeCount;

  Comment({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.content,
    required this.timestamp,
    required this.likeCount,
  });
}

class RecommendedNovel {
  final String id;
  final String title;
  final String author;
  final String category;
  final double rating;

  RecommendedNovel({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.rating,
  });
}