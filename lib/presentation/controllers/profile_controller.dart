import 'package:flutter/material.dart';
  import 'package:get/get.dart';
  // import 'package:terra_brain/presentation/model/user_profile_model.dart';
import 'package:terra_brain/presentation/models/profile_model.dart';

  class ProfileController extends GetxController {
    final Rx<UserProfile> user = UserProfile(
      id: '1',
      name: 'Dewi Lestari',
      username: '@dewilestari',
      bio: 'Pencinta sastra dan penulis pemula.\nSuka menulis cerita fantasi dan romance.',
      profileImage: '',
      isPremium: false,
      novelCount: 8,
      readCount: 127,
      followerCount: 2453,
      followingCount: 89,

      // =============================
      // NOVEL SAYA (untuk grid 3 kolom)
      // =============================
      myNovels: [
        UserNovel(
          id: '1',
          title: 'Dunia Fantasi',
          author: 'Penulis A',
          coverUrl: 'https://i.pinimg.com/564x/07/e8/0a/07e80af602edfed53c64b7c2769a6266.jpg',
          category: 'Fantasy', 
          views: 1250,
        ),
        UserNovel(
          id: '2',
          title: 'Misteri Malam',
          author: 'Penulis C',
          coverUrl: 'https://i.pinimg.com/564x/14/39/5d/14395da9d845a70d820ee974c46b2d64.jpg',
          category: 'Mystery', views: 999,
        ),
        UserNovel(
          id: '3',
          title: 'Cinta di Musim Semi',
          author: 'Penulis B',
          coverUrl: 'https://i.pinimg.com/564x/4f/89/5d/4f895d361b5c2bca65bdf0de6ca1f49b.jpg',
          category: 'Romance', views: 2045,
        ),

      ],

      // =============================
      // FAVORIT (card besar horizontal)
      // =============================
      favoriteNovels: [
        FavoriteNovel(
          id: '1',
          title: 'Petualangan di Negeri Ajaib',
          coverUrl: 'https://i.pinimg.com/564x/70/77/04/707704eef02ec1e95f00b761ddcb6805.jpg',
          genre: 'Fantasy',
          chapterCount: 25,
          views: 8500,
          status: 'Berlanjut',
        ),
        FavoriteNovel(
          id: '2',
          title: 'Cinta di Ujung Senja',
          coverUrl: 'https://i.pinimg.com/564x/e9/0b/0a/e90b0a93aafd8cd1ee49f332ce4f2cee.jpg',
          genre: 'Romance',
          chapterCount: 15,
          views: 5200,
          status: 'Berlanjut',
        ),
        FavoriteNovel(
          id: '3',
          title: 'Rahasia Istana Tua',
          coverUrl: 'https://i.pinimg.com/564x/93/c8/d0/93c8d0db8defc4093742ac139ba40c2f.jpg',
          genre: 'Mystery',
          chapterCount: 32,
          views: 12100,
          status: 'Selesai',
        ),
      ],
    ).obs;

    // TAB INDEX: 0 = Novel Saya, 1 = Favorit
    final RxInt selectedTab = 0.obs;

    void switchTab(int index) {
      selectedTab.value = index;
    }

    void upgradeToPremium() {
      final current = user.value;

      user.value = current.copyWith(isPremium: true);

      Get.snackbar(
        'Premium Activated!',
        'Selamat! Anda sekarang pengguna premium',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }

    String formatNumber(int number) {
      if (number >= 1000) {
        return '${(number / 1000).toStringAsFixed(1)}K';
      }
      return number.toString();
    }

    void editProfile() {
      Get.snackbar(
        'Edit Profil',
        'Fitur edit profil akan segera tersedia',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }