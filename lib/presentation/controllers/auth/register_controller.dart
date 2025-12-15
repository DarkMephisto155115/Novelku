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

  Future<void> register() async {
    isLoading.value = true;
    if (
        email.value.isEmpty ||
        username.value.isEmpty ||
        password.value.isEmpty
        ) {
          isLoading.value = false;
      throw Exception('Semua field harus diisi');
    }

    bool passwordMatch = password.value == confirmPassword.value;
    if (!passwordMatch) {
      isLoading.value = false;
      throw Exception('Password dan konfirmasi password tidak sesuai');
    }

    bool usernameExists = await _checkUsernameExists(username.value);
    if (usernameExists) {
      isLoading.value = false;
      throw Exception('USername sudah digunakan');
    }
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.value,
        password: password.value,
      );

      String uid = userCredential.user!.uid;

      await _firestore.collection('users').doc(uid).set({
        'email': email.value,
        'username': username.value,
        "followers": 0,
        "following": 0,
        "isPremium": false,
        'created_at': FieldValue.serverTimestamp(),
        'last_login_at': FieldValue.serverTimestamp(),
        'last_logout_at': null,
        'updated_at': FieldValue.serverTimestamp(),
      });
      await loginController.bypassLogin(email.value, password.value);
      isLoading.value = false;

      Get.offAllNamed("/genre_selection");
    } on FirebaseAuthException catch (e) {
      rethrow;
      // if (e.code == 'email-already-in-use') {
      //   isLoading.value = false;
      //   throw Exception('The account already exists for that email.');
      // } else if (e.code == 'weak-password') {
      //   isLoading.value = false;
      //   throw Exception('The password is too weak.');
      // } else {
      //   isLoading.value = false;
      //   throw Exception('Registration failed: ${e.message}');
      // }
    } finally {
      isLoading.value = false;
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
