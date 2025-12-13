class Author {
  final String id;
  final String name;
  final String biodata;
  final int novelCount;
  final int followerCount;
  final int? followingCount;
  final String category;
  final bool isNew;
  final bool isPopular;
  final String? imageUrl;

  Author({
    required this.id,
    required this.name,
    required this.biodata,
    required this.novelCount,
    required this.followerCount,
    this.followingCount,
    required this.category,
    required this.isNew,
    required this.isPopular,
    this.imageUrl,
  });

  Author copyWith({
    String? id,
    String? name,
    String? biodata,
    int? novelCount,
    int? followerCount,
    int? followingCount,
    String? category,
    bool? isNew,
    bool? isPopular,
    String? imageUrl,
  }) {
    return Author(
      id: id ?? this.id,
      name: name ?? this.name,
      biodata: biodata ?? this.biodata,
      novelCount: novelCount ?? this.novelCount,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      category: category ?? this.category,
      isNew: isNew ?? this.isNew,
      isPopular: isPopular ?? this.isPopular,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'biodata': biodata,
      'novelCount': novelCount,
      'followerCount': followerCount,
      'followingCount': followingCount,
      'category': category,
      'isNew': isNew,
      'isPopular': isPopular,
      'imageUrl': imageUrl,
    };
  }
}