class Chapter {
  final String id;
  final String title;
  final String content;
  final String author;
  final int chapterNumber;
  final int likeCount;
  final int commentCount;
  final DateTime publishedAt;
  final String? novelId;
  final String? imageUrl;

  Chapter({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.chapterNumber,
    required this.likeCount,
    required this.commentCount,
    required this.publishedAt,
    this.novelId,
    this.imageUrl,
  });

  int get wordCount {
    return content.split(RegExp(r'\s+')).length;
  }

  int get characterCount {
    return content.length;
  }

  int get estimatedReadTime {
    const avgWordsPerMinute = 200;
    return (wordCount / avgWordsPerMinute).ceil();
  }
}

class Comment {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final DateTime timestamp;
  final int likeCount;
  final bool isPremium;
  final bool isLiked;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.content,
    required this.timestamp,
    required this.likeCount,
    this.isPremium = false,
    this.isLiked = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'content': content,
      'timestamp': timestamp,
      'likeCount': likeCount,
      'isPremium': isPremium,
      'isLiked': isLiked,
    };
  }

  Comment copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? content,
    DateTime? timestamp,
    int? likeCount,
    bool? isPremium,
    bool? isLiked,
  }) {
    return Comment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      likeCount: likeCount ?? this.likeCount,
      isPremium: isPremium ?? this.isPremium,
      isLiked: isLiked ?? this.isLiked,
    );
  }
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

enum ReadingTheme { light, sepia, dark }

enum TextAlignment { left, justify, right }

class ReadingSettings {
  final double fontSize;
  final double lineHeight;
  final ReadingTheme theme;
  final TextAlignment textAlignment;
  final bool showBookmarks;
  final bool enableTextSelection;

  ReadingSettings({
    this.fontSize = 16.0,
    this.lineHeight = 1.8,
    this.theme = ReadingTheme.light,
    this.textAlignment = TextAlignment.justify,
    this.showBookmarks = true,
    this.enableTextSelection = true,
  });

  ReadingSettings copyWith({
    double? fontSize,
    double? lineHeight,
    ReadingTheme? theme,
    TextAlignment? textAlignment,
    bool? showBookmarks,
    bool? enableTextSelection,
  }) {
    return ReadingSettings(
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      theme: theme ?? this.theme,
      textAlignment: textAlignment ?? this.textAlignment,
      showBookmarks: showBookmarks ?? this.showBookmarks,
      enableTextSelection: enableTextSelection ?? this.enableTextSelection,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fontSize': fontSize,
      'lineHeight': lineHeight,
      'theme': theme.index,
      'textAlignment': textAlignment.index,
      'showBookmarks': showBookmarks,
      'enableTextSelection': enableTextSelection,
    };
  }

  factory ReadingSettings.fromMap(Map<String, dynamic> map) {
    return ReadingSettings(
      fontSize: (map['fontSize'] as num?)?.toDouble() ?? 16.0,
      lineHeight: (map['lineHeight'] as num?)?.toDouble() ?? 1.8,
      theme: ReadingTheme.values[(map['theme'] as int?) ?? 0],
      textAlignment: TextAlignment.values[(map['textAlignment'] as int?) ?? 1],
      showBookmarks: map['showBookmarks'] as bool? ?? true,
      enableTextSelection: map['enableTextSelection'] as bool? ?? true,
    );
  }
}

class Bookmark {
  final String id;
  final String chapterId;
  final String novelId;
  final int position;
  final String? note;
  final DateTime createdAt;

  Bookmark({
    required this.id,
    required this.chapterId,
    required this.novelId,
    required this.position,
    this.note,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chapterId': chapterId,
      'novelId': novelId,
      'position': position,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Bookmark.fromMap(Map<String, dynamic> map) {
    return Bookmark(
      id: map['id'] as String,
      chapterId: map['chapterId'] as String,
      novelId: map['novelId'] as String,
      position: map['position'] as int,
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

class ReadingHistory {
  final String id;
  final String novelId;
  final String chapterId;
  final String chapterTitle;
  final int scrollPosition;
  final DateTime lastReadAt;
  final int minutesRead;

  ReadingHistory({
    required this.id,
    required this.novelId,
    required this.chapterId,
    required this.chapterTitle,
    required this.scrollPosition,
    required this.lastReadAt,
    this.minutesRead = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'novelId': novelId,
      'chapterId': chapterId,
      'chapterTitle': chapterTitle,
      'scrollPosition': scrollPosition,
      'lastReadAt': lastReadAt.toIso8601String(),
      'minutesRead': minutesRead,
    };
  }

  factory ReadingHistory.fromMap(Map<String, dynamic> map) {
    return ReadingHistory(
      id: map['id'] as String,
      novelId: map['novelId'] as String,
      chapterId: map['chapterId'] as String,
      chapterTitle: map['chapterTitle'] as String,
      scrollPosition: map['scrollPosition'] as int,
      lastReadAt: DateTime.parse(map['lastReadAt'] as String),
      minutesRead: map['minutesRead'] as int? ?? 0,
    );
  }
}

class ReadingStats {
  final int totalBooksRead;
  final int totalChaptersRead;
  final int totalWordsRead;
  final Duration totalTimeSpent;
  final DateTime? lastReadAt;
  final int currentStreak;

  ReadingStats({
    this.totalBooksRead = 0,
    this.totalChaptersRead = 0,
    this.totalWordsRead = 0,
    Duration? totalTimeSpent,
    this.lastReadAt,
    this.currentStreak = 0,
  }) : totalTimeSpent = totalTimeSpent ?? Duration.zero;

  Map<String, dynamic> toMap() {
    return {
      'totalBooksRead': totalBooksRead,
      'totalChaptersRead': totalChaptersRead,
      'totalWordsRead': totalWordsRead,
      'totalTimeSpent': totalTimeSpent.inMinutes,
      'lastReadAt': lastReadAt?.toIso8601String(),
      'currentStreak': currentStreak,
    };
  }

  factory ReadingStats.fromMap(Map<String, dynamic> map) {
    return ReadingStats(
      totalBooksRead: map['totalBooksRead'] as int? ?? 0,
      totalChaptersRead: map['totalChaptersRead'] as int? ?? 0,
      totalWordsRead: map['totalWordsRead'] as int? ?? 0,
      totalTimeSpent:
          Duration(minutes: map['totalTimeSpent'] as int? ?? 0),
      lastReadAt: map['lastReadAt'] != null
          ? DateTime.parse(map['lastReadAt'] as String)
          : null,
      currentStreak: map['currentStreak'] as int? ?? 0,
    );
  }
}