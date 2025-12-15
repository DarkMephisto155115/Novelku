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

      // Save novel document
      await _firestore.collection('novels').doc(novelId).set({
        'id': novelId,
        'title': judulNovelC.text.trim(),
        'subtitle': judulBabC.text.trim(),
        'description': deskripsiC.text.trim(),
        'genre': genreC.value,
        'category': genreC.value,
        'authorId': currentUser.uid,
        'authorName': currentUser.displayName ?? 'Anonymous',
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

  @override
  void onClose() {
    judulNovelC.dispose();
    judulBabC.dispose();
    ceritaC.dispose();
    deskripsiC.dispose();
    super.onClose();
  }
}