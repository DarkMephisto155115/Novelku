import 'package:cloud_firestore/cloud_firestore.dart';

class Novel {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final int likeCount;
  final int viewCount;
  final bool isOngoing;
  final String? status;
  final String? imageUrl;
  final String? genre;
  final int chapterCount;
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
    this.status,
    this.imageUrl,
    this.genre,
    this.chapterCount = 1,
    this.chapters = const [],
    this.authorId,
    this.authorName,
    this.description,
    this.createdAt,
    this.updatedAt,
  });
  Novel copyWith({
    String? title,
    String? subtitle,
    String? category,
    int? likeCount,
    int? viewCount,
    bool? isOngoing,
    String? status,
    String? imageUrl,
    String? genre,
    int? chapterCount,
    List<Chapter>? chapters,
    String? authorId,
    String? authorName,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Novel(
      id: id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      category: category ?? this.category,
      likeCount: likeCount ?? this.likeCount,
      viewCount: viewCount ?? this.viewCount,
      isOngoing: isOngoing ?? this.isOngoing,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      genre: genre ?? this.genre,
      chapterCount: chapterCount ?? this.chapterCount,
      chapters: chapters ?? this.chapters,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Novel.fromJson(Map<String, dynamic> json, String id) {
    return Novel(
      id: id,
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      category: json['category'] ?? '',
      likeCount: json['likeCount'] ?? 0,
      viewCount: json['viewCount'] ?? 0,
      isOngoing: json['isOngoing'] ?? false,
      status: json['status'],
      imageUrl: json['imageUrl'],
      genre: json['genre'],
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
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'category': category,
      'likeCount': likeCount,
      'viewCount': viewCount,
      'isOngoing': isOngoing,
      'status': status,
      'imageUrl': imageUrl,
      'genre': genre,
      'authorId': authorId,
      'authorName': authorName,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class Chapter {
  final String id;
  final int chapter;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? imageUrl;
  final String? isPublished;

  Chapter({
    required this.id,
    required this.chapter,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.imageUrl,
    this.isPublished,
  });

  Chapter copyWith({
    String? id,
    int? chapter,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imageUrl,
    String? isPublished,
  }) {
    return Chapter(
      id: id ?? this.id,
      chapter: chapter ?? this.chapter,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      isPublished: isPublished ?? this.isPublished,
    );
  }

  factory Chapter.fromJson(String id, Map<String, dynamic> json) {
    return Chapter(
      id: id,
      chapter: json['chapter'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
      imageUrl: json['imageUrl'],
      isPublished: json['isPublished'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapter': chapter,
      'title': title,
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'imageUrl': imageUrl,
      'isPublished': isPublished,
    };
  }
}