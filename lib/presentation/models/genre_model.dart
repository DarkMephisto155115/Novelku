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

  Genre copyWith({String? id, String? name, String? emoji, bool? isSelected}) {
    return Genre(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  factory Genre.fromMap(Map<String, dynamic> map, String docId) {
    return Genre(
      id: docId,
      name: map['name'] ?? '',
      emoji: map['emoji'] ?? '',
    );
  }
}
