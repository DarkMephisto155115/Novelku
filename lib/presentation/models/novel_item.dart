class NovelItem {
  final String id;
  final String title;
  final String author;
  final String? authorId;
  final String coverUrl;
  final List<String> genre;
  final int likeCount;
  final int chapters;
  final int readers;
  final bool isNew;
  final String? description;


  NovelItem({
    required this.id,
    required this.title,
    required this.author,
    this.authorId,
    required this.coverUrl,
    required this.genre,
    required this.likeCount,
    required this.chapters,
    required this.readers,
    this.isNew = false,
    this.description,
  });
}