import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_brain/presentation/controllers/auth/LoginController.dart';
import 'package:terra_brain/presentation/controllers/write/writing_controller.dart';
import 'package:terra_brain/presentation/routes/app_pages.dart';
import 'package:terra_brain/presentation/themes/theme_data.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final writingController = Get.find<WritingController>();
      final isDarkMode = writingController.themeController.isDarkMode;
      final bgColor = isDarkMode ? Colors.grey.shade900 : Colors.white;

      return Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildHeader(),
                SizedBox(height: 40),
                _buildLoginForm(),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppThemeData.primaryColor,
                AppThemeData.pinkColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: AppThemeData.primaryColor.withOpacity(0.3),
                blurRadius: 1,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              'assets/icons/novelku_logo.png',
              width: 100,
              height: 100,
            ),
          ),
        ),
        SizedBox(height: 20),
        Text(
          'NovelKu',
          style: Get.theme.textTheme.displayLarge?.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'Baca dan Tulis Novelmu',
          style: Get.theme.textTheme.bodyMedium?.copyWith(
            fontSize: 16,
            color: Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: controller.formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                'Masuk',
                style: Get.theme.textTheme.headlineMedium,
              ),
            ),
            SizedBox(height: 24),
            _buildEmailField(),
            SizedBox(height: 16),
            _buildPasswordField(),
            SizedBox(height: 16),
            _buildForgotPassword(),
            SizedBox(height: 16),
            _buildLoginButton(),
            SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Belum punya akun? ',
                  style: Get.theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Get.offNamed(Routes.REGISTRATION);
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Daftar Sekarang',
                    style: TextStyle(
                      color: Get.theme.primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: Get.theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Get.theme.textTheme.bodyLarge?.color,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller.emailController,
          onChanged: (_) => controller.clearEmailError(),
          style: TextStyle(
            color: Get.theme.textTheme.bodyLarge?.color,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Get.theme.inputDecorationTheme.fillColor,
            hintText: 'Masukkan email anda',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            hintStyle: TextStyle(color: Get.theme.hintColor),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Email harus diisi';
            }
            if (!GetUtils.isEmail(value)) {
              return 'Format email tidak valid';
            }
            if (controller.emailError.value.isNotEmpty) {
              return controller.emailError.value;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: Get.theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Get.theme.textTheme.bodyLarge?.color,
          ),
        ),
        SizedBox(height: 8),
        Obx(
          () => TextFormField(
            controller: controller.passwordController,
            onChanged: (_) => controller.clearPasswordError(),
            obscureText: !controller.isPasswordHidden.value,
            style: TextStyle(
              color: Get.theme.textTheme.bodyLarge?.color,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Get.theme.inputDecorationTheme.fillColor,
              hintText: '••••••••',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              hintStyle: TextStyle(color: Get.theme.hintColor),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.isPasswordHidden.value
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: controller.isPasswordHidden.value
                      ? AppThemeData.primaryColor.withOpacity(0.8)
                      : Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
                onPressed: controller.togglePasswordVisibility,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password harus diisi';
              }
              if (controller.passwordError.value.isNotEmpty) {
                return controller.passwordError.value;
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => Get.snackbar(
            'Info', 'Fitur lupa password belum tersedia',
            backgroundColor: Colors.blue, colorText: Colors.white),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'Lupa Password?',
          style: TextStyle(
            color: Get.theme.primaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : () async {
                  final success = await controller.login();
                  
                  if (success) {
                    Get.offAllNamed(Routes.HOME);
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Get.theme.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            minimumSize: Size(double.infinity, 50),
            padding: EdgeInsets.symmetric(vertical: 14),
          ),
          child: controller.isLoading.value
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Masuk',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
        ),
      ),
    );
  }

  // void _showSuccessSnackbar(String message) {
  //   if (Get.isSnackbarOpen) {
  //     Get.closeCurrentSnackbar();
  //   }
  //   Get.snackbar(
  //     'Berhasil',
  //     message,
  //     snackPosition: SnackPosition.BOTTOM,
  //     backgroundColor: Colors.green,
  //     colorText: Colors.white,
  //     duration: const Duration(seconds: 2),
  //     margin: const EdgeInsets.all(12),
  //     borderRadius: 12,
  //     isDismissible: true,
  //     dismissDirection: DismissDirection.horizontal,
  //   );
  // }

  // void _showErrorSnackbar(String message) {
  //   if (Get.isSnackbarOpen) {
  //     Get.closeCurrentSnackbar();
  //   }
  //   Get.snackbar(
  //     'Login Gagal',
  //     message,
  //     snackPosition: SnackPosition.BOTTOM,
  //     backgroundColor: Colors.red,
  //     colorText: Colors.white,
  //     duration: const Duration(seconds: 3),
  //     margin: const EdgeInsets.all(12),
  //     borderRadius: 12,
  //     isDismissible: true,
  //     dismissDirection: DismissDirection.horizontal,
  //   );
  // }
}
