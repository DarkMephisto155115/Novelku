import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WritingController extends GetxController {
  final judulNovelC = TextEditingController();
  final genreC = ''.obs;
  final judulBabC = TextEditingController();
  final ceritaC = TextEditingController();
  final deskripsiC = TextEditingController();

  RxInt jumlahHuruf = 0.obs;
  var coverImagePath = ''.obs;
  var isLoading = false.obs;
  var uploadProgress = 0.0.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  List<String> listGenre = [];

  @override
  void onInit() {
    super.onInit();
    fetchGenres();
    ceritaC.addListener(() {
      jumlahHuruf.value = ceritaC.text.length;
    });
  }


  Future<void> fetchGenres() async {
    try {
      log("start fetching genres");
      isLoading.value = true;

      final snapshot = await _firestore.collection('genres').get();
      log("genres fetched: ${snapshot.docs.length}");


      if (snapshot.docs.isEmpty) {
        Get.snackbar('Error', 'Tidak ada genre yang tersedia');
        return;
      }

      listGenre = snapshot.docs
          .map((doc) => doc.data()['name'] as String)
          .toList();

      if (!listGenre.contains(genreC.value)) {
        genreC.value = '';
      }

      if (kDebugMode) {
        print("Genres: $listGenre");
      }

    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil data genre');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickCoverImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1536,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        coverImagePath.value = pickedFile.path;
        if (kDebugMode) {
          print("Cover image selected: ${pickedFile.path}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image: $e');
      }
      Get.snackbar('Error', 'Gagal memilih gambar');
    }
  }

  Future<String> uploadCoverImageToStorage(File imageFile, String novelId) async {
    try {
      String fileName =
          'novels/$novelId/cover/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child(fileName);

      TaskSnapshot uploadTask = await ref.putFile(imageFile);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading cover image: $e');
      }
      throw Exception('Gagal mengunggah cover image');
    }
  }

  Future<void> saveNovel() async {
    if (!_validateInput()) {
      return;
    }

    isLoading.value = true;
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        Get.snackbar('Error', 'Anda harus login terlebih dahulu');
        return;
      }

      String novelId = _firestore.collection('novels').doc().id;

      String? coverImageUrl;
      if (coverImagePath.value.isNotEmpty) {
        File imageFile = File(coverImagePath.value);
        coverImageUrl = await uploadCoverImageToStorage(imageFile, novelId);
      }

      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      final userData = userDoc.data();
      
      if (kDebugMode) {
        print('[WRITING] Current User UID: ${currentUser.uid}');
        print('[WRITING] User Document Data: $userData');
        print('[WRITING] Name from DB: ${userData?['name']}');
        print('[WRITING] Username from DB: ${userData?['username']}');
      }
      
      final authorName = (userData?['name']?.isNotEmpty == true)
          ? (userData?['name'] ?? '')
          : (userData?['username'] ?? 'Anonymous');
      
      if (kDebugMode) {
        print('[WRITING] Final Author Name: $authorName');
      }


      // Save novel document
      final novelRef = _firestore.collection('novels').doc(novelId);

      await novelRef.set({
        'id': novelId,
        'title': judulNovelC.text.trim(),
        'description': deskripsiC.text.trim(),
        'genre': genreC.value,
        'category': genreC.value,
        'authorId': currentUser.uid,
        'authorName': authorName,
        'imageUrl': coverImageUrl ?? '',
        'likeCount': 0,
        'viewCount': 0,
        'isOngoing': true,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });

      final chapterRef = novelRef
          .collection('chapters')
          .doc();

      await chapterRef.set({
        'id': chapterRef.id,
        'chapterNumber': 1,
        'title': judulBabC.text.trim(),
        'content': ceritaC.text.trim(),
        'isPublished': 'Draft',
        'imageUrl': null,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });

      // Update user's novels array
      await _firestore.collection('users').doc(currentUser.uid).update({
        'novels': FieldValue.arrayUnion([novelId])
      }).catchError((e) {
        if (kDebugMode) {
          print('Error updating user novels: $e');
        }
      });

      isLoading.value = false;

      // Clear form
      _clearForm();

      // Show success dialog
      _showSuccessDialog();
    } catch (e) {
      isLoading.value = false;
      if (kDebugMode) {
        print('Error saving novel: $e');
      }
      Get.snackbar('Error', 'Gagal menyimpan novel: $e');
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateInput() {
    if (judulNovelC.text.trim().isEmpty) {
      _showErrorSnackbar('Judul novel harus diisi');
      return false;
    }
    if (genreC.value.isEmpty) {
      _showErrorSnackbar('Genre harus dipilih');
      return false;
    }
    if (judulBabC.text.trim().isEmpty) {
      _showErrorSnackbar('Judul bab harus diisi');
      return false;
    }
    if (ceritaC.text.trim().isEmpty) {
      _showErrorSnackbar('Cerita harus diisi');
      return false;
    }
    if (jumlahHuruf.value < 200) {
      _showErrorSnackbar('Cerita minimal 200 karakter');
      return false;
    }
    return true;
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _clearForm() {
    judulNovelC.clear();
    genreC.value = '';
    judulBabC.clear();
    ceritaC.clear();
    deskripsiC.clear();
    coverImagePath.value = '';
    jumlahHuruf.value = 0;
  }

  void _showSuccessDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('Sukses!'),
          ],
        ),
        content: const Text(
          'Novel Anda berhasil disimpan.\nAnda dapat melihatnya di halaman profil atau beranda.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.offAllNamed('/'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7A4FFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Kembali ke Beranda',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void showPreview() {
    if (judulNovelC.text.trim().isEmpty) {
      _showErrorSnackbar('Masukkan judul novel terlebih dahulu');
      return;
    }
    
    if (ceritaC.text.trim().isEmpty) {
      _showErrorSnackbar('Masukkan cerita terlebih dahulu');
      return;
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        insetPadding: const EdgeInsets.all(16),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: const Color(0xFF7A4FFF),
            elevation: 0,
            title: const Text(
              'Preview Novel',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: false,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),
          body: CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate([
                  _buildPreviewContent(),
                  const SizedBox(height: 24),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewContent() {
    final wordCount = ceritaC.text.split(RegExp(r'\s+')).length;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (coverImagePath.value.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(coverImagePath.value),
                        width: 100,
                        height: 140,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      width: 100,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          judulNovelC.text.trim(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Penulis: Author',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (genreC.value.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              genreC.value,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.favorite, size: 14, color: Colors.red),
                            const SizedBox(width: 4),
                            const Text(
                              '0',
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.menu_book, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            const Text(
                              '1',
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.visibility, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            const Text(
                              '0',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
            ],
          ),
        ),
        if (deskripsiC.text.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Deskripsi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  deskripsiC.text.trim(),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.justify,
                ),
                const Divider(height: 24),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                judulBabC.text.trim(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Bab 1',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$wordCount kata',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(wordCount / 200).ceil()} menit',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void onClose() {
    judulNovelC.dispose();
    judulBabC.dispose();
    ceritaC.dispose();
    deskripsiC.dispose();
    super.onClose();
  }
}