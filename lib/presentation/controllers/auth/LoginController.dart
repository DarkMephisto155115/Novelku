import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terra_brain/presentation/themes/theme_controller.dart';

class LoginController extends GetxController {
  var isPasswordHidden = false.obs;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String userID = '';

  ThemeController get themeController => Get.find<ThemeController>();

  final isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleTheme() {
    themeController.toggleTheme();
  }

  Future<void> bypassLogin(String email, String password) async {
    emailController.text = email;
    passwordController.text = password;
    await login();
  }

  Future<bool> login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    
    if (email.isEmpty || password.isEmpty) {
      hasError.value = true;
      errorMessage.value = 'Email dan password harus diisi';
      return false;
    }

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userId', userCredential.user!.uid);

      isLoading.value = false;
      return true;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      hasError.value = true;

      String message;
      if (e.code == 'user-not-found') {
        message = 'Email tidak terdaftar';
      } else if (e.code == 'wrong-password') {
        message = 'Password salah';
      } else if (e.code == 'invalid-email') {
        message = 'Format email tidak valid';
      } else if (e.code == 'user-disabled') {
        message = 'Akun ini telah dinonaktifkan';
      } else {
        message = 'Login gagal. Silakan coba lagi';
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

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
