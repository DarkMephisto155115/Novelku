class Genre {
  final String id;
  final String name;
  final String emoji;
  final bool isSelected;

  Genre({
    required this.id,
    required this.name,
    required this.emoji,
    this.isSelected = false,
  });

  Genre copyWith({bool? isSelected}) {
    return Genre(
      id: id,
      name: name,
      emoji: emoji,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}