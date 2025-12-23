import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:terra_brain/presentation/controllers/auth/LoginController.dart';

class RegistrationController extends GetxController {
  var email = ''.obs;
  var username = ''.obs;
  var password = ''.obs;
  var confirmPassword = ''.obs;
  var passwordHidden = true.obs;
  var confirmPasswordHidden = true.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var hasError = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LoginController loginController = Get.find<LoginController>();

  TextEditingController birthDateController = TextEditingController();

  void togglePasswordVisibility() {
    passwordHidden.value = !passwordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    confirmPasswordHidden.value = !confirmPasswordHidden.value;
  }

  Future<bool> register() async {
    hasError.value = false;
    errorMessage.value = '';

    String emailVal = email.value.trim();
    String usernameVal = username.value.trim();
    String passwordVal = password.value;
    String confirmPasswordVal = confirmPassword.value;

    if (emailVal.isEmpty || usernameVal.isEmpty || passwordVal.isEmpty) {
      hasError.value = true;
      errorMessage.value = 'Semua field harus diisi';
      return false;
    }

    if (passwordVal != confirmPasswordVal) {
      hasError.value = true;
      errorMessage.value = 'Password dan konfirmasi password tidak sesuai';
      return false;
    }

    if (passwordVal.length < 6) {
      hasError.value = true;
      errorMessage.value = 'Password minimal 6 karakter';
      return false;
    }

    bool usernameExists = await _checkUsernameExists(usernameVal);
    if (usernameExists) {
      hasError.value = true;
      errorMessage.value = 'Username sudah digunakan';
      return false;
    }

    isLoading.value = true;

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailVal,
        password: passwordVal,
      );

      String uid = userCredential.user!.uid;

      await _firestore.collection('users').doc(uid).set({
        'email': emailVal,
        'username': usernameVal,
        'authorId': uid,
        'followers': 0,
        'following': 0,
        'isPremium': false,
        'created_at': FieldValue.serverTimestamp(),
        'last_login_at': FieldValue.serverTimestamp(),
        'last_logout_at': null,
        'updated_at': FieldValue.serverTimestamp(),
      });

      await loginController.bypassLogin(emailVal, passwordVal);
      isLoading.value = false;

      return true;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      hasError.value = true;

      String message;
      if (e.code == 'email-already-in-use') {
        message = 'Email sudah terdaftar';
      } else if (e.code == 'weak-password') {
        message = 'Password terlalu lemah';
      } else if (e.code == 'invalid-email') {
        message = 'Format email tidak valid';
      } else {
        message = 'Pendaftaran gagal. Silakan coba lagi';
      }

      errorMessage.value = message;
      return false;
    } catch (e) {
      isLoading.value = false;
      hasError.value = true;
      errorMessage.value = 'Terjadi kesalahan. Silakan coba lagi';
      return false;
    }
  }

  Future<bool> _checkUsernameExists(String username) async {
    try {
      var snapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty; 
    } catch (e) {
      if (kDebugMode) {
        print("Error checking username: $e");
      }
      return false;
    }
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email harus diisi';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Format email tidak valid';
    }
    return null;
  }

  @override
  void onClose() {
    birthDateController.dispose();
    super.onClose();
  }
}
