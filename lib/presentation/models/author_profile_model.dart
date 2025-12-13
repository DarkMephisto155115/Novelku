import 'package:cloud_firestore/cloud_firestore.dart';
import 'novel_model.dart';

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
  });

  AuthorProfile copyWith({
    String? id,
    String? name,
    String? username,
    String? bio,
    String? profileImage,
    int? novelCount,
    int? followerCount,
    int? followingCount,
    int? totalLikes,
    List<Novel>? novels,
  }) {
    return AuthorProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      profileImage: profileImage ?? this.profileImage,
      novelCount: novelCount ?? this.novelCount,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      totalLikes: totalLikes ?? this.totalLikes,
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
      username: data['username'] ?? '',
      bio: data['bio'] ?? '',
      profileImage: data['imagesURL'] ?? data['imageURL'],
      novelCount: (data['novelCount'] ?? novels.length) as int,
      followerCount: (data['followerCount'] ?? 0) as int,
      followingCount: (data['followingCount'] ?? 0) as int,
      totalLikes: (data['totalLikes'] ?? 0) as int,
      novels: novels,
    );
  }
}
