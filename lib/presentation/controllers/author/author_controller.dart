import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:terra_brain/presentation/models/author_model.dart';

class AuthorsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<Author> authors = <Author>[].obs;

  final RxString selectedCategory = 'Semua'.obs;
  final RxString searchQuery = ''.obs;

  final RxList<String> categories = <String>['Semua'].obs;

  @override
  void onInit() {
    super.onInit();
    fetchGenres();
    fetchAuthors();
  }

  Future<void> fetchAuthors() async {
    try {
      log('[AUTHOR] Fetch authors started');

      final storySnap = await _firestore
          .collection('stories')
          .where('isPublished', isEqualTo: true)
          .get();

      if (storySnap.docs.isEmpty) {
        authors.clear();
        log('[AUTHOR] No published stories found');
        return;
      }

      final Map<String, List<QueryDocumentSnapshot>> grouped = {};

      for (var doc in storySnap.docs) {
        final writerId = doc['writerId'];
        grouped.putIfAbsent(writerId, () => []);
        grouped[writerId]!.add(doc);
      }

      List<Author> temp = [];

      for (var entry in grouped.entries) {
        final writerId = entry.key;
        final stories = entry.value;

        final userSnap =
            await _firestore.collection('users').doc(writerId).get();

        if (!userSnap.exists) continue;

        final user = userSnap.data()!;

        final novelCount = stories.length;

        final genreCount = <String, int>{};
        for (var s in stories) {
          final genre = s['genre'] ?? 'Unknown';
          genreCount[genre] = (genreCount[genre] ?? 0) + 1;
        }

        final topGenre =
            genreCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;

        final createdAt =
            (user['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

        final isNew = DateTime.now().difference(createdAt).inDays <= 30;
        final followerCount = user['followers'] ?? 0;
        final isPopular = followerCount >= 1000;

        temp.add(
          Author(
            id: writerId,
            name: user['name'] ?? '-',
            biodata: user['biodata'] ?? '',
            novelCount: novelCount,
            followerCount: followerCount,
            category: topGenre,
            isNew: isNew,
            isPopular: isPopular,
            imageUrl: user['imagesURL'],
          ),
        );
      }

      authors.value = temp;
      log('[AUTHOR] Fetch authors success: ${authors.length}');
    } catch (e) {
      log('[AUTHOR] ERROR fetchAuthors: $e');
      rethrow;
    }
  }

  Future<void> fetchGenres() async {
    try {
      log('[GENRE] Fetch genres started');

      final snap = await _firestore.collection('genres').get();

      if (snap.docs.isEmpty) {
        log('[GENRE] No genres found');
        return;
      }

      final fetchedGenres =
          snap.docs.map((d) => d.data()['name']).whereType<String>().toList();

      categories
        ..clear()
        ..add('Semua')
        ..addAll(fetchedGenres);

      log('[GENRE] Genres loaded: $categories');
    } catch (e) {
      log('[GENRE] ERROR fetchGenres: $e');
    }
  }

  List<Author> get filteredAuthors {
    final q = searchQuery.value.toLowerCase();

    final list = authors.where((a) {
      final matchCategory = selectedCategory.value == 'Semua' ||
          a.category == selectedCategory.value;

      final matchSearch = q.isEmpty ||
          a.name.toLowerCase().contains(q) ||
          a.biodata.toLowerCase().contains(q);

      return matchCategory && matchSearch;
    }).toList();

    list.sort((a, b) {
      if (a.isNew && !b.isNew) return -1;
      if (!a.isNew && b.isNew) return 1;
      if (a.isPopular && !b.isPopular) return -1;
      if (!a.isPopular && b.isPopular) return 1;
      return b.followerCount.compareTo(a.followerCount);
    });

    return list;
  }

  List<Author> get newAuthors => filteredAuthors.where((a) => a.isNew).toList();

  List<Author> get popularAuthors =>
      filteredAuthors.where((a) => a.isPopular).toList();

  List<Author> get otherAuthors =>
      filteredAuthors.where((a) => !a.isNew && !a.isPopular).toList();

  List<dynamic> get structuredList {
    final List<dynamic> items = [];

    if (newAuthors.isNotEmpty) {
      items.add('_header_new');
      items.addAll(newAuthors);
      items.add('_divider_new');
    }

    if (popularAuthors.isNotEmpty) {
      items.add('_header_popular');
      items.addAll(popularAuthors);
    }

    if (otherAuthors.isNotEmpty) {
      items.add('_header_all');
      items.addAll(otherAuthors);
    }

    return items;
  }

  void setCategory(String category) {
    selectedCategory.value = category;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void followAuthor(String authorId) {
    final index = authors.indexWhere((a) => a.id == authorId);
    if (index == -1) return;

    final a = authors[index];
    authors[index] = a.copyWith(
      followerCount: a.followerCount + 1,
      isPopular: a.followerCount + 1 >= 1000,
    );
  }
}
