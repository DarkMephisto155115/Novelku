import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:terra_brain/presentation/themes/theme_data.dart';

class EditProfileController extends GetxController {
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final bioController = TextEditingController();

  final Rx<File?> profileImage = Rx<File?>(null);
  final RxBool isLoading = false.obs;
  final RxString bioCharCount = '0/150'.obs;

  final String originalName = 'Dewi Lestari';
  final String originalUsername = 'dewilestari';
  final String originalEmail = 'dewi.lestari@gmail.com';
  final String originalBio = 'Pencinta sastra dan penulis pemula. Suka menulis cerita fantasi dan romance.';

  @override
  void onInit() {
    super.onInit();
    nameController.text = originalName;
    usernameController.text = originalUsername;
    emailController.text = originalEmail;
    bioController.text = originalBio;
    bioCharCount.value = '${originalBio.length}/150';
    
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

  void _updateBioCharCount() {
    final text = bioController.text;
    bioCharCount.value = '${text.length}/150';
  }

  Future<void> pickProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );
      
      if (image != null) {
        profileImage.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memilih gambar: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> takeProfilePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );
      
      if (photo != null) {
        profileImage.value = File(photo.path);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengambil foto: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppThemeData.errorColor,
        colorText: Colors.white,
      );
    }
  }

  void removeProfileImage() {
    profileImage.value = null;
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username harus diisi';
    }
    
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username hanya boleh mengandung huruf, angka, dan underscore';
    }
    
    if (value.length < 3) {
      return 'Username minimal 3 karakter';
    }
    
    if (value.length > 20) {
      return 'Username maksimal 20 karakter';
    }
    
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama lengkap harus diisi';
    }
    
    if (value.length < 2) {
      return 'Nama terlalu pendek';
    }
    
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email harus diisi';
    }
    
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Format email tidak valid';
    }
    
    return null;
  }

  String? validateBio(String? value) {
    if (value != null && value.length > 150) {
      return 'Bio maksimal 150 karakter';
    }
    
    return null;
  }

  Future<void> saveChanges() async {
    final nameError = validateName(nameController.text);
    final usernameError = validateUsername(usernameController.text);
    final emailError = validateEmail(emailController.text);
    final bioError = validateBio(bioController.text);

    if (nameError != null || usernameError != null || emailError != null || bioError != null) {
      Get.snackbar(
        'Error',
        'Harap perbaiki kesalahan pada form',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppThemeData.errorColor,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    await Future.delayed(Duration(seconds: 2));

    isLoading.value = false;

    Get.snackbar(
      'Berhasil',
      'Profil berhasil diperbarui',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppThemeData.successColor,
      colorText: Colors.white,
    );

    Get.back();
  }

  void cancelEditing() {
    Get.back();
  }

  bool get hasChanges {
    return nameController.text != originalName ||
        usernameController.text != originalUsername ||
        emailController.text != originalEmail ||
        bioController.text != originalBio ||
        profileImage.value != null;
  }

  void resetForm() {
    nameController.text = originalName;
    usernameController.text = originalUsername;
    emailController.text = originalEmail;
    bioController.text = originalBio;
    profileImage.value = null;
  }
}