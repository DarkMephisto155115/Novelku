import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:terra_brain/presentation/themes/theme_data.dart';

class EditProfileController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  // ==========================
  // TEXT CONTROLLERS
  // ==========================
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final bioController = TextEditingController();

  // ==========================
  // STATE
  // ==========================
  final Rx<File?> profileImage = Rx<File?>(null);
  final RxBool isLoading = false.obs;
  final RxString bioCharCount = '0/150'.obs;
  final RxBool imageRemoved = false.obs;

  // ==========================
  // ORIGINAL DATA (UNTUK DETEKSI PERUBAHAN)
  // ==========================
  late String originalName;
  late String originalUsername;
  late String originalEmail;
  late String originalBio;
  final RxString originalProfileImageUrl = ''.obs;

  String get uid => _auth.currentUser!.uid;

  // ==========================
  // INIT
  // ==========================
  @override
  void onInit() {
    super.onInit();
    _loadUserProfile();
    bioController.addListener(_updateBioCharCount);
  }

  @override
  void onClose() {
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    bioController.dispose();
    super.onClose();
  }

  // ==========================
  // LOAD DATA DARI FIRESTORE
  // ==========================
  Future<void> _loadUserProfile() async {
    try {
      isLoading.value = true;

      final doc =
          await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        throw 'Data user tidak ditemukan';
      }

      final data = doc.data()!;

      originalName = data['name'] ?? '';
      originalUsername = data['username'] ?? '';
      originalEmail = data['email'] ?? '';
      originalBio = data['bio'] ?? '';
      originalProfileImageUrl.value = data['imageUrl'] ?? '';

      nameController.text = originalName;
      usernameController.text = originalUsername;
      emailController.text = originalEmail;
      bioController.text = originalBio;

      bioCharCount.value = '${originalBio.length}/150';
      imageRemoved.value = false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat profil: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================
  // IMAGE PICKER
  // ==========================
  Future<void> pickProfileImage() async {
    final picker = ImagePicker();
    final image =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (image != null) {
      profileImage.value = File(image.path);
    }
  }

  Future<void> takeProfilePhoto() async {
    final picker = ImagePicker();
    final image =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 80);

    if (image != null) {
      profileImage.value = File(image.path);
    }
  }

  void removeProfileImage() {
    profileImage.value = null;
    imageRemoved.value = true;
  }

  // ==========================
  // VALIDATION
  // ==========================
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama wajib diisi';
    }
    return null;
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) return 'Username wajib diisi';
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username tidak valid';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email wajib diisi';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Format email salah';
    }
    return null;
  }

  String? validateBio(String? value) {
    if (value != null && value.length > 150) {
      return 'Bio maksimal 150 karakter';
    }
    return null;
  }

  void _updateBioCharCount() {
    bioCharCount.value = '${bioController.text.length}/150';
  }

  // ==========================
  // SAVE CHANGES
  // ==========================
  Future<void> saveChanges() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      String? imageUrl;
      bool imageChanged = false;

      // UPLOAD FOTO JIKA ADA
      if (profileImage.value != null) {
        final ref =
            _storage.ref().child('profile_images/$uid.jpg');

        await ref.putFile(profileImage.value!);
        imageUrl = await ref.getDownloadURL();
        imageChanged = true;
      } else if(imageRemoved.value){
        // HAPUS FOTO DI STORAGE JIKA DIHAPUS
        final ref = _storage.ref().child('profile_images/$uid.jpg');
        await ref.delete();
        imageUrl = null;
        imageChanged = true;
      }

      // UPDATE FIRESTORE
      final updateData = {
        'name': nameController.text.trim(),
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'bio': bioController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (imageChanged) {
        updateData['imageUrl'] = imageUrl!;
      }
      
      await _firestore.collection('users').doc(uid).update(updateData);

      profileImage.value = null;
      imageRemoved.value = false;
      
      Get.back(result: true);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan profil: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void cancelEditing() {
    profileImage.value = null;
    imageRemoved.value = false;
    Get.back();
  }

  bool get hasChanges {
    final imageChanged = profileImage.value != null || imageRemoved.value;
    
    return nameController.text != originalName ||
        usernameController.text != originalUsername ||
        emailController.text != originalEmail ||
        bioController.text != originalBio ||
        imageChanged;
  }
}
