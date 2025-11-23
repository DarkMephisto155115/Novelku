class NovelItem {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final List<String> genre;
  final double rating;
  final int chapters;
  final int readers;
  final bool isNew;


  NovelItem({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.genre,
    required this.rating,
    required this.chapters,
    required this.readers,
    this.isNew = false,
  });
}