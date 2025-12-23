import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terra_brain/presentation/models/profile_model.dart';
import 'package:terra_brain/presentation/routes/app_pages.dart';

class ProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rx<UserProfile> user = UserProfile(
    id: '',
    name: '',
    username: '',
    bio: '',
    profileImage: null,
    isPremium: false,
    novelCount: 0,
    readCount: 0,
    followerCount: 0,
    followingCount: 0,
    totalLikes: 0,
    myNovels: const [],
    favoriteNovels: const [],
  ).obs;

  late final String userId;

  final RxBool isLoading = false.obs;
  final RxInt selectedTab = 0.obs;

  static const int _pageSize = 6;

  final RxList<UserNovel> myNovels = <UserNovel>[].obs;
  final RxBool isLoadingMore = false.obs;

  DocumentSnapshot? _lastNovelDoc;
  bool _hasMoreMyNovels = true;

  static const int _favPageSize = 6;

  final RxList<FavoriteNovel> favoriteNovels = <FavoriteNovel>[].obs;
  final RxBool isLoadingFavMore = false.obs;

  DocumentSnapshot? _lastFavDoc;
  bool _hasMoreFavorites = true;


  final ScrollController scrollController = ScrollController();

  @override
  void onInit() async {
    super.onInit();

    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId') ?? '';

    scrollController.addListener(_onScroll);

    isLoading.value = true;
    await _fetchUserProfile();
    await fetchMyNovels(refresh: true);
    await fetchFavoriteNovels(refresh: true);
    isLoading.value = false;
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels <
        scrollController.position.maxScrollExtent - 300) {
      return;
    }

    if (selectedTab.value == 0) {
      fetchMyNovels();
    } else {
      fetchFavoriteNovels();
    }
  }

  Future<void> _fetchUserProfile() async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return;

      final data = doc.data()!;

      // Fetch all novels to calculate stats
      final novelSnap = await _firestore
          .collection('novels')
          .where('authorId', isEqualTo: userId)
          .get();

      final novels =
          novelSnap.docs.where((d) => d['status'] != 'Draft').toList();

      final int calculatedNovelCount = novels.length;
      final int calculatedReadCount =
          novels.fold(0, (sum, doc) => sum + (doc['viewCount'] as int? ?? 0));
      final int calculatedTotalLikes =
          novels.fold(0, (sum, doc) => sum + (doc['likeCount'] as int? ?? 0));

      user.value = user.value.copyWith(
        name: data['name'] ?? '',
        username: data['username'] ?? '',
        bio: data['bio'] ?? data['biodata'] ?? '',
        profileImage:
            (data['imageUrl'] is String && data['imageUrl'].isNotEmpty)
                ? data['imageUrl']
                : null,
        isPremium: data['is_premium'] ?? false,
        novelCount: calculatedNovelCount,
        readCount: calculatedReadCount,
        followerCount: data['followers'] ?? 0,
        followingCount: data['following'] ?? 0,
        totalLikes: calculatedTotalLikes,
      );
    } catch (e, s) {
      log('[PROFILE] fetchUserProfile error', error: e, stackTrace: s);
    }
  }

  Future<void> fetchMyNovels({bool refresh = false}) async {
    if (isLoadingMore.value) return;
    if (!_hasMoreMyNovels && !refresh) return;

    try {
      isLoadingMore.value = true;

      if (refresh) {
        myNovels.clear();
        _lastNovelDoc = null;
        _hasMoreMyNovels = true;
      }

      Query query = _firestore
          .collection('novels')
          .where('authorId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(_pageSize);

      if (_lastNovelDoc != null) {
        query = query.startAfterDocument(_lastNovelDoc!);
      }

      final snap = await query.get();

      if (snap.docs.isNotEmpty) {
        _lastNovelDoc = snap.docs.last;

        myNovels.addAll(
          snap.docs.map((doc) {
            final d = doc.data() as Map<String, dynamic>;
            return UserNovel(
              id: doc.id,
              title: d['title'] ?? '',
              author: d['authorName'] ?? '',
              coverUrl: d['imageUrl'] ?? '',
              category: d['genre'] ?? 'General',
              views: d['viewCount'] ?? 0,
            );
          }).toList(),
        );
      }

      if (snap.docs.length < _pageSize) {
        _hasMoreMyNovels = false;
      }
    } catch (e, s) {
      log('[PROFILE] fetchMyNovels error', error: e, stackTrace: s);
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> fetchFavoriteNovels({bool refresh = false}) async {
    if (isLoadingFavMore.value) return;
    if (!_hasMoreFavorites && !refresh) return;

    try {
      isLoadingFavMore.value = true;

      if (refresh) {
        favoriteNovels.clear();
        _lastFavDoc = null;
        _hasMoreFavorites = true;
      }

      Query query = _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .orderBy('createdAt', descending: true)
          .limit(_favPageSize);

      if (_lastFavDoc != null) {
        query = query.startAfterDocument(_lastFavDoc!);
      }

      final snap = await query.get();

      if (snap.docs.isNotEmpty) {
        _lastFavDoc = snap.docs.last;

        for (final doc in snap.docs) {
          final ref = doc['novelRef'];
          if (ref is! DocumentReference) continue;

          try {
            final novelDoc = await ref.get();
            if (!novelDoc.exists) {
              // optional cleanup
              await doc.reference.delete();
              continue;
            }

            final d = novelDoc.data() as Map<String, dynamic>;
            
            // Filter out drafts from favorites
            if (d['status'] == 'Draft') continue;
            
            final chaptersSnap = await ref
                .collection('chapters')
                .get();
            
            final publishedChapters = chaptersSnap.docs
                .where((ch) {
                  final isPublished = ch['isPublished'];
                  return isPublished != null && 
                      (isPublished.toString().toLowerCase() == 'published' || 
                       isPublished.toString() == 'true');
                })
                .length;
            
            favoriteNovels.add(
              FavoriteNovel(
                id: novelDoc.id,
                title: d['title'] ?? '',
                coverUrl: d['imageUrl'] ?? '',
                genre: d['genre'] ?? 'General',
                chapterCount: publishedChapters,
                views: d['viewCount'] ?? 0,
                status: d['status'] ?? 'Berlanjut',
              ),
            );
          } catch (_) {
            // skip rusak
          }
        }
      }

      if (snap.docs.length < _favPageSize) {
        _hasMoreFavorites = false;
      }
    } catch (e, s) {
      log('[PROFILE] fetchFavoriteNovels error', error: e, stackTrace: s);
    } finally {
      isLoadingFavMore.value = false;
    }
  }

  void switchTab(int index) {
    if (selectedTab.value == index) return;

    selectedTab.value = index;
    scrollController.jumpTo(0);
  }


  Future<void> editNovel(String novelId) async {
    final result = await Get.toNamed(
      '/edit_novel/$novelId',
    );

    if (result == 'deleted') {
      await fetchMyNovels(refresh: true);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Get.offAllNamed(Routes.LOGIN);
  }

  String formatNumber(int number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
  }
}
