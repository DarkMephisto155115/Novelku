import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_brain/presentation/controllers/auth/register_controller.dart';
import 'package:terra_brain/presentation/routes/app_pages.dart';
import 'package:terra_brain/presentation/themes/theme_data.dart';

class RegistrationPage extends GetView<RegistrationController> {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(),
              SizedBox(height: 40),
              _buildRegisterForm(),
            ],
          ),
        ),
      ),
    );
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
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Image.asset(
            'assets/icons/novelku_logo.png',
            width: 100,
            height: 100,
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

  Widget _buildRegisterForm() {
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
        child: Column(
          children: [
            // Label Daftar
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Daftar',
                style: Get.theme.textTheme.displayMedium,
              ),
            ),
            SizedBox(height: 24),

            // Email Field
            _buildEmailField(),
            SizedBox(height: 16),

            // Username Field
            _buildUsernameField(),
            SizedBox(height: 16),

            // Password Field
            _buildPasswordField(),
            SizedBox(height: 16),

            // Confirm Password Field
            _buildConfirmPasswordField(),
            SizedBox(height: 20),

            _buildRegisterButton(),
            SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Sudah punya akun? ',
                  style: Get.theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Get.offNamed(Routes.LOGIN);
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Masuk',
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
          // controller: controller.emailController,
          onChanged: (value) => controller.email.value = value,
          style: TextStyle(
            color: Get.theme.textTheme.bodyLarge?.color,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Get.theme.inputDecorationTheme.fillColor,
            hintText: 'user@example.com',
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
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Username',
          style: Get.theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Get.theme.textTheme.bodyLarge?.color,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          // controller: controller.usernameController,
          onChanged: (value) => controller.username.value = value,
          style: TextStyle(
            color: Get.theme.textTheme.bodyLarge?.color,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Get.theme.inputDecorationTheme.fillColor,
            hintText: 'user_name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            hintStyle: TextStyle(color: Get.theme.hintColor),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Username harus diisi';
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
        Obx(() => TextFormField(
              // controller: controller.passwordController,
              onChanged: (value) => controller.password.value = value,
              obscureText: controller.passwordHidden.value,
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
                    controller.passwordHidden.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: controller.passwordHidden.value
                        ? Get.theme.textTheme.bodyMedium?.color
                            ?.withOpacity(0.6)
                        : AppThemeData.primaryColor.withOpacity(0.8),
                  ),
                  onPressed: controller.togglePasswordVisibility,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password harus diisi';
                }
                if (value.length < 6) {
                  return 'Password minimal 6 karakter';
                }
                return null;
              },
            )),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Konfirmasi Password',
          style: Get.theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Get.theme.textTheme.bodyLarge?.color,
          ),
        ),
        SizedBox(height: 8),
        Obx(() => TextFormField(
              // controller: controller.confirmPasswordController,
              onChanged: (value) => controller.confirmPassword.value = value,
              obscureText: controller.confirmPasswordHidden.value,
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
                    controller.confirmPasswordHidden.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: controller.confirmPasswordHidden.value
                        ? Get.theme.textTheme.bodyMedium?.color
                            ?.withOpacity(0.6)
                        : AppThemeData.primaryColor.withOpacity(0.8),
                  ),
                  onPressed: controller.toggleConfirmPasswordVisibility,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Konfirmasi password harus diisi';
                }
                if (value != controller.password.value) {
                  return 'Password tidak cocok';
                }
                return null;
              },
            )),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : () async {
                    final success = await controller.register();
                    if (success) {
                      // _showSuccessSnackbar('Berhasil mendaftar akun');
                      // await Future.delayed(const Duration(milliseconds: 800));
                      Get.offAllNamed('/genre_selection');
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
                        'Daftar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.person_add, size: 20),
                    ],
                  ),
          ),
        ));
  }

  // void _showSuccessSnackbar(String message) {
  //   Future.microtask(() {
  //     Get.snackbar(
  //       'Berhasil',
  //       message,
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: Colors.green,
  //       colorText: Colors.white,
  //       duration: const Duration(seconds: 2),
  //       margin: const EdgeInsets.all(12),
  //       borderRadius: 12,
  //       isDismissible: true,
  //       dismissDirection: DismissDirection.horizontal,
  //     );
  //   });
  // }

  // void _showErrorSnackbar(String message) {
  //   Future.microtask(() {
  //     Get.snackbar(
  //       'Registrasi Gagal',
  //       message,
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //       duration: const Duration(seconds: 3),
  //       margin: const EdgeInsets.all(12),
  //       borderRadius: 12,
  //       isDismissible: true,
  //       dismissDirection: DismissDirection.horizontal,
  //     );
  //   });
  // }
}
