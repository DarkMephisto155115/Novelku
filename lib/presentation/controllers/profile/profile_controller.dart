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
  // ===============================
  // FIREBASE
  // ===============================
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===============================
  // STATE (NON-NULL UNTUK UI)
  // ===============================
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

  final RxBool isLoading = true.obs;
  final RxInt selectedTab = 0.obs;

  late final String userId;

  // ===============================
  // STREAM SUBSCRIPTIONS
  // ===============================
  late final StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> _userSub;

  // ===============================
  // LIFECYCLE
  // ===============================
  @override
  void onInit() {
    super.onInit();

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      log('[PROFILE] User belum login');
      return;
    }

    userId = currentUser.uid;

    _listenUserProfile();   // REALTIME
    _fetchStaticData();     // ONE-TIME
  }

  @override
  void onClose() {
    _userSub.cancel();
    super.onClose();
  }

  // ===============================
  // REALTIME USER LISTENER
  // ===============================
  void _listenUserProfile() {
    _userSub = _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((doc) {
      if (!doc.exists) return;

      final data = doc.data()!;

      user.value = user.value.copyWith(
        name: data['name'] ?? '',
        username: data['username'] ?? '',
        bio: data['bio'] ?? '',
        profileImage: data['imageUrl'],
        isPremium: data['isPremium'] ?? false,
        novelCount: data['novelCount'] ?? user.value.myNovels.length,
        readCount: data['readCount'] ?? 0,
        followerCount: data['followerCount'] ?? 0,
        followingCount: data['followingCount'] ?? 0,
      );

      isLoading.value = false;
      log('[PROFILE] Realtime profile updated');
    }, onError: (e) {
      log('[PROFILE] Realtime error: $e');
    });
  }

  // ===============================
  // ONE-TIME DATA (LIST BESAR)
  // ===============================
  Future<void> _fetchStaticData() async {
    try {
      // ---------- MY NOVELS ----------
      final novelSnap = await _firestore
          .collection('stories')
          .where('writerId', isEqualTo: userId)
          .get();

      final myNovels = novelSnap.docs.map((doc) {
        final d = doc.data();
        return UserNovel(
          id: doc.id,
          title: d['title'] ?? '',
          author: d['author'] ?? '',
          coverUrl: d['coverUrl'] ?? '',
          category: d['category'] ?? '',
          views: d['views'] ?? 0,
        );
      }).toList();

      // ---------- FAVORITES ----------
      final favSnap = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();

      final favoriteNovels = favSnap.docs.map((doc) {
        final d = doc.data();
        return FavoriteNovel(
          id: doc.id,
          title: d['title'] ?? '',
          coverUrl: d['coverUrl'] ?? '',
          genre: d['genre'] ?? '',
          chapterCount: d['chapterCount'] ?? 0,
          views: d['views'] ?? 0,
          status: d['status'] ?? '',
        );
      }).toList();

      // ---------- UPDATE USER ----------
      user.value = user.value.copyWith(
        myNovels: myNovels,
        favoriteNovels: favoriteNovels,
        novelCount: myNovels.length,
      );

      log('[PROFILE] Static data loaded');
    } catch (e, s) {
      log('[PROFILE] Static fetch error: $e', stackTrace: s);
    }
  }

  // ===============================
  // UI ACTIONS
  // ===============================
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

  // ===============================
  // PREMIUM
  // ===============================
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

  // ===============================
  // LOGOUT
  // ===============================
  Future<void> logout() async {
    await _auth.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Get.offAllNamed(Routes.LOGIN);
  }

  // ===============================
  // UTIL
  // ===============================
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
