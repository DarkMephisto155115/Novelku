import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terra_brain/presentation/routes/app_pages.dart';
import 'package:terra_brain/presentation/themes/theme_controller.dart';

class LoginController extends GetxController {
  var isPasswordHidden = false.obs;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ThemeController get themeController => Get.find<ThemeController>();

  final isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleTheme() {
    themeController.toggleTheme();
  }

  void bypassLogin(String email, String password) async {
    emailController.text = email;
    passwordController.text = password;
    login();
  }

  Future<void> login() async {
    String email = emailController.text;
    String password = passwordController.text;
    isLoading.value = true;

    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
            email: email, password: password);

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userId', userCredential.user!.uid);

        // Get.snackbar('Success', 'Logged in successfully',
        //     backgroundColor: Colors.green, colorText: Colors.white);

        isLoading.value = false;
 
        // Get.offAllNamed(Routes.HOME);
      } on FirebaseAuthException catch (e) {
        isLoading.value = false;
        rethrow;
        // String message;
        // if (e.code == 'user-not-found') {
        //   message = ' No user  found for that email. ';
        // } else if (e.code == 'wrong-password') {
        //   message = 'Wrong password provider';
        // } else {
        //   message = 'Login failed. Please try again!';
        // }
        // Get.snackbar('Login Failed ', message,
        //     backgroundColor: Colors.red, colorText: Colors.white);
      } catch (e) {
        isLoading.value = false;
        rethrow;
        // Get.snackbar('Error', 'An unexpeted error ocurred.',
        //     backgroundColor: Colors.red, colorText: Colors.white);
      }
    } else {
      isLoading.value = false;
      throw Exception('Email dan password harus diisi');
      // Get.snackbar('Error', 'Please enter email and password',
      //     backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  void onClose() {
    // emailController.dispose();
    // passwordController.dispose();
    super.onClose();
  }
}
