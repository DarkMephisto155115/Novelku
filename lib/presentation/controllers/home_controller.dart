import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:video_player/video_player.dart';
import 'package:collection/collection.dart'; // untuk ListEquality

class HomeController extends GetxController {
  final box = GetStorage();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var selectedImagePath = ''.obs;
  var isImageLoading = false.obs;

  var selectedVideoPath = ''.obs;
  var isVideoPlaying = false.obs;
  VideoPlayerController? videoPlayerController;

  var stories = <Map<String, dynamic>>[].obs;
  var filteredStories = <Map<String, dynamic>>[].obs;
  var selectedCategory = ''.obs;
  var searchQuery = ''.obs;

  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    selectedCategory.value = 'All';
    _getStories();
    searchQuery.listen((_) => _applyFilter());
  }

  @override
  void onClose() {
    videoPlayerController?.dispose();
    searchController.dispose();
    super.onClose();
  }

  /// ✅ Ambil data stories dari Firestore dengan struktur baru (ada list chapters)
  void _getStories() {
    try {
      _firestore.collection('stories').snapshots().listen((snapshot) {
        final List<Map<String, dynamic>> updatedStories = snapshot.docs.map((doc) {
          final data = doc.data();

          // Ambil chapter pertama sebagai preview (bisa dikembangkan nanti)
          List<dynamic> chapters = data['chapters'] ?? [];
          String? firstImageUrl;
          String? firstChapterTitle;

          if (chapters.isNotEmpty) {
            final firstChapter = chapters.first;
            firstImageUrl = firstChapter['imageUrl'];
            firstChapterTitle = firstChapter['chapter'];
          }

          return {
            'id': doc.id,
            'title': data['title'] ?? 'Tanpa Judul',
            'author': data['author'] ?? 'Tidak diketahui',
            'category': data['category'] ?? 'Lainnya',
            'createdAt': data['createdAt'] ?? '',
            'image': firstImageUrl, // gunakan gambar dari chapter pertama
            'chapters': chapters,
            'firstChapterTitle': firstChapterTitle,
          };
        }).toList();

        // Hanya update jika datanya berbeda (hindari rebuild berlebih)
        if (!const ListEquality().equals(stories, updatedStories)) {
          stories.value = updatedStories;
          _applyFilter();
        }
      });
    } catch (e) {
      print("🔥 Error ambil stories: $e");
    }
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
    _applyFilter();
  }

  /// ✅ Filter berdasarkan kategori dan pencarian
  void _applyFilter() {
    filteredStories.value = stories.where((story) {
      final matchesCategory = selectedCategory.value == 'All' ||
          selectedCategory.value.isEmpty ||
          story['category'] == selectedCategory.value;
      final matchesSearch = story['title']
          .toString()
          .toLowerCase()
          .contains(searchQuery.value.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }
}
