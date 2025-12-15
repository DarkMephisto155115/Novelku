import 'package:cloud_firestore/cloud_firestore.dart';

class Novel {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final int likeCount;
  final int viewCount;
  final bool isOngoing;
  final String? imageUrl;
  final String? genre;
  final List<Chapter> chapters;
  final String? authorId;
  final String? authorName;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Novel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.likeCount,
    required this.viewCount,
    required this.isOngoing,
    this.imageUrl,
    this.genre,
    required this.chapters,
    this.authorId,
    this.authorName,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  int get chapterCount => chapters.length;

  factory Novel.fromJson(Map<String, dynamic> json, String id) {
    final rawChapters = json['chapters'];

    final chapters = rawChapters is List
        ? rawChapters
        .map((e) => Chapter.fromJson(Map<String, dynamic>.from(e)))
        .toList()
        : <Chapter>[];

    return Novel(
      id: id,
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      category: json['category'] ?? '',
      likeCount: (json['likeCount'] ?? 0) as int,
      viewCount: (json['viewCount'] ?? 0) as int,
      isOngoing: json['isOngoing'] ?? false,
      imageUrl: json['imageUrl'],
      genre: json['genre'],
      chapters: chapters,
      authorId: json['authorId'],
      authorName: json['authorName'],
      description: json['description'],
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'category': category,
      'likeCount': likeCount,
      'viewCount': viewCount,
      'isOngoing': isOngoing,
      'imageUrl': imageUrl,
      'genre': genre,
      'authorId': authorId,
      'authorName': authorName,
      'description': description,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}


class Chapter {
  final int chapter;
  final String title;
  final String content;
  final DateTime createdAt;
  final String? imageUrl;

  Chapter({
    required this.chapter,
    required this.title,
    required this.content,
    required this.createdAt,
    this.imageUrl,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      chapter: (json['chapter'] ?? 0) as int,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chapter': chapter,
      'title': title,
      'content': content,
      'createdAt': createdAt,
      'imageUrl': imageUrl,
    };
  }
}