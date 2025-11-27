import 'package:get/get.dart';
import 'package:terra_brain/presentation/models/author_model.dart';

class AuthorsController extends GetxController {
  final RxList<Author> authors = <Author>[].obs;
  final RxString selectedCategory = 'Semua'.obs;
  final RxString searchQuery = ''.obs;

  // final RxList<String> categories = <String>[
  //   'Semua',
  //   'Romance',
  //   'Fantasy',
  //   'Mystery',
  //   'Sci-Fi',
  //   'Drama',
  //   'Action',
  //   'Horror',
  // ].obs;

  final List<String> categories = [
    'Semua',
    'Romance',
    'Fantasy',
    'Mystery',
    'Sci-Fi',
    'Drama',
    'Action',
    'Horror',
  ];

  @override
  void onInit() {
    super.onInit();
    _loadAuthors();
  }

  void _loadAuthors() {
    // Sample data dari design Anda
    authors.assignAll([
      Author(
        id: '1',
        name: 'Sarah Wijaya',
        description: 'Penulis cerita romance yang hangat dan penuh emosi',
        novelCount: 3,
        followerCount: 1200,
        category: 'Romance',
        isNew: true,
        isPopular: false,
      ),
      Author(
        id: '2',
        name: 'Andi Pratama',
        description: 'Menciptakan dunia fantasi yang penuh petualangan',
        novelCount: 2,
        followerCount: 856,
        category: 'Fantasy',
        isNew: true,
        isPopular: false,
      ),
      Author(
        id: '3',
        name: 'Maya Indah',
        description: 'Spesialis cerita misteri yang bikin penasaran',
        novelCount: 5,
        followerCount: 2400,
        category: 'Mystery',
        isNew: true,
        isPopular: false,
      ),
      Author(
        id: '4',
        name: 'Budi Setiawan',
        description: 'Mengeksplorasi masa depan melalui cerita sci-fi',
        novelCount: 4,
        followerCount: 3100,
        category: 'Sci-Fi',
        isNew: false,
        isPopular: true,
      ),
      Author(
        id: '5',
        name: 'Dina Kartika',
        description: 'Cerita drama kehidupan yang menyentuh hati',
        novelCount: 6,
        followerCount: 4500,
        category: 'Drama',
        isNew: false,
        isPopular: true,
      ),
    ]);
  }

  List<dynamic> get structuredList {
    List<dynamic> items = [];

    if (newAuthors.isNotEmpty) {
      items.add('_header_new');
      items.addAll(newAuthors);
      items.add('_divider_new');
    }

    if (popularAuthors.isNotEmpty) {
      items.add('_header_popular');
      items.addAll(popularAuthors);
    }

    items.addAll(otherAuthors);

    return items;
  }

  List<Author> get filteredAuthors {
    var filtered = authors.where((author) {
      final matchesCategory = selectedCategory.value == 'Semua' ||
          author.category == selectedCategory.value;
      final matchesSearch = searchQuery.value.isEmpty ||
          author.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          author.description
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    // Urutkan: new authors first, then popular, then others
    filtered.sort((a, b) {
      if (a.isNew && !b.isNew) return -1;
      if (!a.isNew && b.isNew) return 1;
      if (a.isPopular && !b.isPopular) return -1;
      if (!a.isPopular && b.isPopular) return 1;
      return b.followerCount.compareTo(a.followerCount);
    });

    return filtered;
  }

  List<Author> get newAuthors {
    return filteredAuthors.where((author) => author.isNew).toList();
  }

  List<Author> get popularAuthors {
    return filteredAuthors.where((author) => author.isPopular).toList();
  }

  List<Author> get otherAuthors {
    return filteredAuthors
        .where((author) => !author.isNew && !author.isPopular)
        .toList();
  }

  void setCategory(String category) {
    selectedCategory.value = category;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void followAuthor(String authorId) {
    final authorIndex = authors.indexWhere((author) => author.id == authorId);
    if (authorIndex != -1) {
      authors[authorIndex] = Author(
        id: authors[authorIndex].id,
        name: authors[authorIndex].name,
        description: authors[authorIndex].description,
        novelCount: authors[authorIndex].novelCount,
        followerCount: authors[authorIndex].followerCount + 1,
        category: authors[authorIndex].category,
        isNew: authors[authorIndex].isNew,
        isPopular: authors[authorIndex].isPopular,
        imageUrl: authors[authorIndex].imageUrl,
      );
    }
  }
}
