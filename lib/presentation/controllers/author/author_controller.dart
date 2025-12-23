import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:terra_brain/presentation/models/author_model.dart';

class AuthorsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<Author> authors = <Author>[].obs;

  final RxString selectedCategory = 'Semua'.obs;
  final RxString searchQuery = ''.obs;

  final RxList<String> categories = <String>['Semua'].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchGenres();
    fetchAuthors();
  }

  Future<void> fetchAuthors() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      log('[AUTHOR] Fetch authors started');

      final currentUserId = _auth.currentUser?.uid;
      final novelSnap = await _firestore.collection('novels').get();

      if (novelSnap.docs.isEmpty) {
        authors.clear();
        log('[AUTHOR] No novels found');
        isLoading.value = false;
        return;
      }

      final Map<String, List<QueryDocumentSnapshot>> grouped = {};

      for (var doc in novelSnap.docs) {
        final authorId = doc['authorId'] ?? 'Unknown';
        grouped.putIfAbsent(authorId, () => []);
        grouped[authorId]!.add(doc);
      }

      List<Author> temp = [];

      for (var entry in grouped.entries) {
        final authorId = entry.key;
        final novels = entry.value;

        if (authorId == currentUserId) {
          log('[AUTHOR] Skipping current user: $authorId');
          continue;
        }

        final userDoc = await _firestore
            .collection('users')
            .doc(authorId)
            .get();

        if (!userDoc.exists) {
          log('[AUTHOR] User not found for author: $authorId');
          continue;
        }

        final user = userDoc.data() ?? {};
        final userId = userDoc.id;

        final novelCount = novels.length;

        final genreCount = <String, int>{};
        for (var n in novels) {
          final genre = n['genre'] ?? 'Unknown';
          if (genre is String) {
            genreCount[genre] = (genreCount[genre] ?? 0) + 1;
          } else if (genre is List) {
            for (var g in genre) {
              genreCount[g] = (genreCount[g] ?? 0) + 1;
            }
          }
        }

        final topGenre = genreCount.isNotEmpty
            ? genreCount.entries.reduce((a, b) => a.value > b.value ? a : b).key
            : 'Unknown';

        final createdAt =
            (((user['createdAt'] ?? user['created_at']) as Timestamp?)
                    ?.toDate()) ??
                DateTime.now();

        final isNew = DateTime.now().difference(createdAt).inDays <= 30;
        final followerCount = (user['followers'] ?? 0) as int;
        final isPopular = followerCount >= 100;

        temp.add(
          Author(
            id: userId,
            name: user['name'] ?? '-',
            username: user['username'] ?? user['name'] ?? '-',
            email: user['email'] ?? '',
            biodata: user['biodata'] ?? '',
            novelCount: novelCount,
            followerCount: followerCount,
            category: topGenre,
            isNew: isNew,
            isPopular: isPopular,
            isPremium: (user['is_premium'] ?? false) as bool,
            imageUrl: user['imageUrl'],
          ),
        );
      }

      authors.value = temp;
      log('[AUTHOR] Fetch authors success: ${authors.length}');
      isLoading.value = false;
    } catch (e) {
      log('[AUTHOR] ERROR fetchAuthors: $e');
      errorMessage.value = 'Gagal memuat data penulis';
      isLoading.value = false;
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

  List<Author> get structuredList {
    return filteredAuthors;
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
