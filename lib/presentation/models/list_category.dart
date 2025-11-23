class ListCategory {
  final String listName;
  final String displayName;
  final String oldestPublishedDate;
  final String newestPublishedDate;
  final String updated;

  ListCategory({
    required this.listName,
    required this.displayName,
    required this.oldestPublishedDate,
    required this.newestPublishedDate,
    required this.updated,
  });

  factory ListCategory.fromJson(Map<String, dynamic> json) {
    return ListCategory(
      listName: json['list_name'],
      displayName: json['display_name'],
      oldestPublishedDate: json['oldest_published_date'],
      newestPublishedDate: json['newest_published_date'],
      updated: json['updated'],
    );
  }
}
