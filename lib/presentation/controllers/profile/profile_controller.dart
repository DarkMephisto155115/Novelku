import 'dart:async';
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
    myNovels: const [],
    favoriteNovels: const [],
  ).obs;

  final RxBool isLoading = false.obs;
  final RxInt selectedTab = 0.obs;

  late final String? userId;

  @override
  void onInit() async {
    super.onInit();
    logProfile('onInit called');

    final SharedPreferences _preferences = await SharedPreferences.getInstance();
    userId = _preferences.getString('userId');

    logProfile('User ID', userId);

    isLoading.value = true;

    _fetchUserProfile();
    _fetchStaticData();
  }


  @override
  void onClose() {
    logProfile('onClose called, cancelling stream');
    super.onClose();
  }


  Future<void> _fetchUserProfile() async {
    logProfile('Fetching user profile');

    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return;

      final data = doc.data()!;

      user.value = user.value.copyWith(
        name: data['name'] ?? '',
        username: data['username'] ?? '',
        bio: data['bio'] ?? '',
        profileImage:
        (data['imageUrl'] is String && data['imageUrl'].toString().isNotEmpty)
            ? data['imageUrl']
            : null,
        isPremium: data['isPremium'] ?? false,
        novelCount: data['novelCount'] ?? 0,
        readCount: data['readCount'] ?? 0,
        followerCount: data['followerCount'] ?? 0,
        followingCount: data['followingCount'] ?? 0,
      );

      logProfile('User profile loaded');
    } catch (e, s) {
      log('[PROFILE] User profile fetch error', error: e, stackTrace: s);
    }
  }


  void logProfile(String message, [Object? data]) {
    log(
      '[PROFILE] $message${data != null ? ' -> $data' : ''}',
      name: 'ProfileController',
    );
  }

  Future<void> _fetchStaticData() async {
    logProfile('Fetching static data started');

    try {
      logProfile('Fetching my novels');
      final novelSnap = await _firestore
          .collection('novels')
          .where('authorId', isEqualTo: userId)
          .get();

      logProfile('My novels count', novelSnap.docs.length);

      final myNovels = novelSnap.docs.map((doc) {
        final d = doc.data();
        logProfile('My novel', {
          'id': doc.id,
          'title': d['title'],
        });

        return UserNovel(
          id: doc.id,
          title: d['title'] ?? '',
          author: d['authorName'] ?? '',
          coverUrl: d['imageUrl'] ?? '',
          category: (d['genre'] is List && (d['genre'] as List).isNotEmpty)
              ? (d['genre'] as List).first.toString()
              : d['genre'] ?? 'General',
          views: d['viewCount'] ?? 0,
        );
      }).toList();

      logProfile('Fetching favorite novels');
      final favSnap = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();

      final futures = favSnap.docs.map<Future<FavoriteNovel?>>((doc) async {
        final data = doc.data();
        final novelRef = data['novelRef'];

        if (novelRef == null || novelRef is! DocumentReference) {
          return null;
        }

        try {
          final novelDoc = await novelRef.get();
          if (!novelDoc.exists) return null;

          final novelData = novelDoc.data() as Map<String, dynamic>;

          final chapters = novelData['chapters'];
          final chapterList =
          chapters is List ? chapters : <dynamic>[];

          return FavoriteNovel(
            id: novelDoc.id,
            title: novelData['title'] ?? '',
            coverUrl: novelData['imageUrl'] ?? '',
            genre: (novelData['genre'] is List &&
                (novelData['genre'] as List).isNotEmpty)
                ? (novelData['genre'] as List).first.toString()
                : novelData['genre'] ?? 'General',
            chapterCount: chapterList.length,
            views: novelData['viewCount'] ?? 0,
            status: chapterList.isEmpty ? 'Belum Mulai' : 'Berlanjut',
          );
        } catch (e) {
          log('[PROFILE] Favorite novel fetch error: $e');
          return null;
        }
      }).toList();

      final favoriteNovels =
      (await Future.wait(futures)).whereType<FavoriteNovel>().toList();

      // ---------- READING STATS ----------
      logProfile('Fetching reading stats');
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data() ?? {};

      logProfile('Reading stats', {
        'totalChaptersRead': userData['totalChaptersRead'],
        'totalWordsRead': userData['totalWordsRead'],
        'readingStreak': userData['readingStreak'],
      });

      user.value = user.value.copyWith(
        myNovels: myNovels,
        favoriteNovels: favoriteNovels,
        novelCount: myNovels.length,
        totalChaptersRead: userData['totalChaptersRead'] ?? 0,
        totalWordsRead: userData['totalWordsRead'] ?? 0,
        readingStreak: userData['readingStreak'] ?? 0,
      );

      logProfile('Static data applied to state');
    } catch (e, s) {
      log('[PROFILE] Static fetch error', error: e, stackTrace: s);
    } finally {
      isLoading.value = false;
    }
  }

  void switchTab(int index) {
    selectedTab.value = index;
  }

  Future<void> editProfile() async {
    final result = await Get.toNamed('/edit_profile');
    if (result == true) {
      log('[PROFILE] Returned from edit profile');
    } else {
      log('Eror: ?');
    }
  }

  Future<void> upgradeToPremium() async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isPremium': true,
      });

      Get.snackbar(
        'Premium Activated',
        'Akun Anda sekarang premium',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal upgrade premium',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> logout() async {
    await _firestore.collection('users').doc(userId).update(
      {
        'last_logout_at': DateTime.now(),
      },
    );
    await _auth.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Get.offAllNamed(Routes.LOGIN);
  }

  String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}