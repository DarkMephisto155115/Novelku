class Author {
  final String id;
  final String name;
  final String description;
  final int novelCount;
  final int followerCount;
  final String category;
  final bool isNew;
  final bool isPopular;
  final String? imageUrl;

  Author({
    required this.id,
    required this.name,
    required this.description,
    required this.novelCount,
    required this.followerCount,
    required this.category,
    required this.isNew,
    required this.isPopular,
    this.imageUrl,
  });
}