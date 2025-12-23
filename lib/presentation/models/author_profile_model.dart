import 'package:cloud_firestore/cloud_firestore.dart';
import 'novel_model.dart';

class AuthorProfile {
  final String id;
  final String name;
  final String username;
  final String email;
  final String bio;
  final String? profileImage;
  final bool isPremium;
  final int novelCount;
  final int followerCount;
  final int followingCount;
  final int readCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;
  final DateTime? lastLogoutAt;
  final List<Novel> novels;

  AuthorProfile({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.bio,
    this.profileImage,
    required this.isPremium,
    required this.novelCount,
    required this.followerCount,
    required this.followingCount,
    required this.readCount,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
    this.lastLogoutAt,
    required this.novels,
  });

  int get totalLikes {
    return novels.fold(0, (sum, novel) => sum + novel.likeCount);
  }

  AuthorProfile copyWith({
    String? id,
    String? name,
    String? username,
    String? email,
    String? bio,
    String? profileImage,
    bool? isPremium,
    int? novelCount,
    int? followerCount,
    int? followingCount,
    int? readCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    DateTime? lastLogoutAt,
    List<Novel>? novels,
  }) {
    return AuthorProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      profileImage: profileImage ?? this.profileImage,
      isPremium: isPremium ?? this.isPremium,
      novelCount: novelCount ?? this.novelCount,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      readCount: readCount ?? this.readCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      lastLogoutAt: lastLogoutAt ?? this.lastLogoutAt,
      novels: novels ?? this.novels,
    );
  }

  factory AuthorProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    List<Novel> novels,
  ) {
    final data = doc.data()!;

    return AuthorProfile(
      id: doc.id,
      name: data['name'] ?? '',
      username: data['username'] ?? data['name'] ?? '',
      email: data['email'] ?? '',
      bio: data['biodata'] ?? data['bio'] ?? '',
      profileImage: data['imageUrl'],
      isPremium: (data['is_premium'] ?? false) as bool,
      novelCount: novels.length,
      followerCount: (data['followers'] ?? 0) as int,
      followingCount: (data['following'] ?? 0) as int,
      readCount: novels.fold(0, (sum, novel) => sum + novel.viewCount),
      createdAt:
          ((data['createdAt'] ?? data['created_at']) as Timestamp?)?.toDate(),
      updatedAt: ((data['updated_at']) as Timestamp?)?.toDate(),
      lastLoginAt: ((data['last_login_at']) as Timestamp?)?.toDate(),
      lastLogoutAt: ((data['last_logout_at']) as Timestamp?)?.toDate(),
      novels: novels,
    );
  }
}
