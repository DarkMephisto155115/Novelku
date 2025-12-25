import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  var email = ''.obs;
  var username = ''.obs;
  var password = ''.obs;
  var confirmPassword = ''.obs;
  var passwordHidden = true.obs;
  var confirmPasswordHidden = true.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var hasError = false.obs;
  var emailError = ''.obs;
  var usernameError = ''.obs;
  var passwordError = ''.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController birthDateController = TextEditingController();

  void togglePasswordVisibility() {
    passwordHidden.value = !passwordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    confirmPasswordHidden.value = !confirmPasswordHidden.value;
  }

  void clearErrors() {
    hasError.value = false;
    errorMessage.value = '';
    emailError.value = '';
    usernameError.value = '';
    passwordError.value = '';
  }

  void clearEmailError() {
    if (emailError.value.isNotEmpty) {
      emailError.value = '';
    }
  }

  void clearUsernameError() {
    if (usernameError.value.isNotEmpty) {
      usernameError.value = '';
    }
  }

  void clearPasswordError() {
    if (passwordError.value.isNotEmpty) {
      passwordError.value = '';
    }
  }

  Future<bool> register() async {
    clearErrors();
    if (!formKey.currentState!.validate()) {
      return false;
    }

    String emailVal = email.value.trim();
    String usernameVal = username.value.trim();
    String passwordVal = password.value;

    bool usernameExists = await _checkUsernameExists(usernameVal);
    if (usernameExists) {
      hasError.value = true;
      errorMessage.value = 'Username sudah digunakan';
      usernameError.value = errorMessage.value;
      formKey.currentState?.validate();
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
        'is_premium': false,
        'created_at': FieldValue.serverTimestamp(),
        'last_login_at': FieldValue.serverTimestamp(),
        'last_logout_at': null,
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Save session locally
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userId', uid);

      isLoading.value = false;
      return true;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      hasError.value = true;

      String message;
      if (e.code == 'email-already-in-use') {
        message = 'Email sudah terdaftar';
        emailError.value = message;
      } else if (e.code == 'weak-password') {
        message = 'Password terlalu lemah';
        passwordError.value = message;
      } else if (e.code == 'invalid-email') {
        message = 'Format email tidak valid';
        emailError.value = message;
      } else {
        message = 'Pendaftaran gagal. Silakan coba lagi';
        passwordError.value = message;
      }

      errorMessage.value = message;
      formKey.currentState?.validate();
      return false;
    } catch (e) {
      isLoading.value = false;
      hasError.value = true;
      errorMessage.value = 'Terjadi kesalahan. Silakan coba lagi';
      passwordError.value = errorMessage.value;
      formKey.currentState?.validate();
      if (kDebugMode) {
        print("Registration error: $e");
      }
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
