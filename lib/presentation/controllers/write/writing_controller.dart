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

  List<String> listGenre = [
    "Romance", "Action", "Drama", "Fantasy", "Comedy", "Thriller", "Fanfiction"
  ];

  @override
  void onInit() {
    super.onInit();
    ceritaC.addListener(() {
      jumlahHuruf.value = ceritaC.text.length;
    });
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
      await _firestore.collection('novels').doc(novelId).set({
        'id': novelId,
        'title': judulNovelC.text.trim(),
        'subtitle': judulBabC.text.trim(),
        'description': deskripsiC.text.trim(),
        'genre': genreC.value,
        'category': genreC.value,
        'authorId': currentUser.uid,
        'authorName': authorName,
        'imageUrl': coverImageUrl ?? '',
        'likeCount': 0,
        'viewCount': 0,
        'isOngoing': true,
        'chapters': [
          {
            'chapter': 1,
            'title': judulBabC.text.trim(),
            'content': ceritaC.text.trim(),
            'createdAt': DateTime.now(),
            'imageUrl': null,
          }
        ],
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
    if (jumlahHuruf.value < 50) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (coverImagePath.value.isNotEmpty)
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            child: Image.file(
              File(coverImagePath.value),
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                judulNovelC.text.trim(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              if (genreC.value.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7A4FFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    genreC.value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (deskripsiC.text.trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  deskripsiC.text.trim(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Divider(
                color: Colors.grey.shade300,
                height: 1,
              ),
              const SizedBox(height: 24),
              Text(
                judulBabC.text.trim(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
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
                    '${ceritaC.text.length} karakter',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(ceritaC.text.length / 200).ceil()} menit',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SelectableText(
                ceritaC.text.trim(),
                style: TextStyle(
                  fontSize: 16,
                  height: 1.8,
                  color: Colors.grey.shade900,
                ),
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