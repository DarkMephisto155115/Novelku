import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:terra_brain/presentation/models/author_profile_model.dart';
import 'package:terra_brain/presentation/models/novel_model.dart';
import 'package:terra_brain/presentation/service/firestore_cache_service.dart';

class AuthorProfileController extends GetxController {
  static const int _novelQueryLimit = 30;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreCacheService _cacheService =
      Get.find<FirestoreCacheService>();

  final Rxn<AuthorProfile> author = Rxn<AuthorProfile>();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isFollowing = false.obs;

  late final String authorId;
  String? currentUserId;

  @override
  void onInit() {
    super.onInit();

    authorId = _resolveAuthorId();
    final user = _auth.currentUser;

    if (authorId.isEmpty) {
      errorMessage.value = 'Author ID tidak ditemukan';
      return;
    }

    if (user == null) {
      errorMessage.value = 'User belum login';
      return;
    }

    currentUserId = user.uid;

    if (authorId == currentUserId) {
      errorMessage.value = 'Tidak bisa melihat profil diri sendiri';
      return;
    }

    fetchAuthorProfile();
    checkIsFollowing();
  }

  Future<void> fetchAuthorProfile() async {
    if (authorId.isEmpty) {
      errorMessage.value = 'Author ID tidak ditemukan';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      log('[AUTHOR_PROFILE] Fetch started: $authorId');

      final authorDoc = await _cacheService.docGet(
        _firestore.collection('users').doc(authorId),
      );

      if (!authorDoc.exists) {
        errorMessage.value = 'Author tidak ditemukan';
        return;
      }

      final novelSnap = await _cacheService.queryGet(
        _firestore
            .collection('novels')
            .where('authorId', isEqualTo: authorId)
            .limit(_novelQueryLimit),
      );

      final novels =
          novelSnap.docs
              .map((d) => Novel.fromJson(d.data(), d.id))
              .where((n) => n.status != 'Draft')
              .toList();

      author.value = AuthorProfile.fromFirestore(authorDoc, novels);

      log('[AUTHOR_PROFILE] Fetch success');
    } catch (e, s) {
      log('[AUTHOR_PROFILE] ERROR: $e', stackTrace: s);
      errorMessage.value = 'Gagal memuat profil penulis';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkIsFollowing() async {
    if (authorId.isEmpty || currentUserId == null) {
      return;
    }

    try {
      final followerId = currentUserId!;
      final doc = await _cacheService.docGet(
        _firestore
            .collection('users')
            .doc(authorId)
            .collection('followers')
            .doc(followerId),
      );

      isFollowing.value = doc.exists;
    } catch (e) {
      log('[FOLLOW] Check failed: $e');
    }
  }

  Future<void> toggleFollow() async {
    if (author.value == null || authorId.isEmpty || currentUserId == null) {
      return;
    }

    final followerId = currentUserId!;
    final batch = _firestore.batch();

    final authorRef = _firestore.collection('users').doc(authorId);
    final followerRef = authorRef.collection('followers').doc(followerId);

    final followingRef = _firestore
        .collection('users')
        .doc(followerId)
        .collection('following')
        .doc(authorId);

    final currentlyFollowing = isFollowing.value;

    isFollowing.value = !currentlyFollowing;
    author.value = author.value!.copyWith(
      followerCount: currentlyFollowing
          ? author.value!.followerCount - 1
          : author.value!.followerCount + 1,
    );

    try {
      if (currentlyFollowing) {
        batch.delete(followerRef);
        batch.delete(followingRef);
        batch.update(authorRef, {
          'followers': FieldValue.increment(-1),
        });
        batch.update(_firestore.collection('users').doc(followerId), {
          'following': FieldValue.increment(-1),
        });
      } else {
        batch.set(followerRef, {
          'createdAt': FieldValue.serverTimestamp(),
        });
        batch.set(followingRef, {
          'createdAt': FieldValue.serverTimestamp(),
        });
        batch.update(authorRef, {
          'followers': FieldValue.increment(1),
        });
        batch.update(_firestore.collection('users').doc(followerId), {
          'following': FieldValue.increment(1),
        });
      }

      await batch.commit();
    } catch (e) {
      log('[FOLLOW] ERROR: $e');

      isFollowing.value = currentlyFollowing;
      author.value = author.value!.copyWith(
        followerCount: currentlyFollowing
            ? author.value!.followerCount + 1
            : author.value!.followerCount - 1,
      );
    }
  }

  String _resolveAuthorId() {
    final args = Get.arguments;
    if (args is Map && args['authorId'] != null) {
      final value = args['authorId'].toString().trim();
      if (value.isNotEmpty) {
        return value;
      }
    }

    final paramId = Get.parameters['id']?.trim();
    if (paramId != null && paramId.isNotEmpty) {
      return paramId;
    }

    return '';
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
