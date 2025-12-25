import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_brain/presentation/controllers/profile/edit_profile_controller.dart';

class EditProfilePage extends GetView<EditProfileController> {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Edit Profil',
          style: Get.theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Get.theme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: controller.cancelEditing,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileImageSection(),
              SizedBox(height: 24),
              Divider(
                color: Get.theme.dividerColor.withOpacity(0.3),
                height: 1,
              ),
              SizedBox(height: 24),
              _buildFormSection(),
              SizedBox(height: 32),
              _buildActionButtons(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Klik ikon kamera untuk mengubah foto profil',
            style: Get.theme.textTheme.bodyMedium?.copyWith(
              color: Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              Obx(
                () {
                  final File? localImage = controller.profileImage.value;
                  final String imageUrl =
                      controller.originalProfileImageUrl.value;

                  return Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Get.theme.primaryColor.withOpacity(0.2),
                      border: Border.all(
                        color: Get.theme.primaryColor,
                        width: 3,
                      ),
                      image: localImage != null
                          ? DecorationImage(
                              image: FileImage(localImage),
                              fit: BoxFit.cover,
                            )
                          : imageUrl.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(imageUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                    ),
                    child: localImage == null && imageUrl.isEmpty
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: Get.theme.primaryColor,
                          )
                        : null,
                  );
                },
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Get.theme.primaryColor,
                    border: Border.all(
                      color: Get.theme.scaffoldBackgroundColor,
                      width: 3,
                    ),
                  ),
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.camera_alt,
                        color: Colors.white, size: 20),
                    offset: const Offset(0, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      if (value == 'gallery') {
                        controller.pickProfileImage();
                      } else if (value == 'camera') {
                        controller.takeProfilePhoto();
                      } else if (value == 'remove') {
                        controller.removeProfileImage();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'gallery',
                        child: Row(
                          children: [
                            Icon(Icons.photo_library, size: 20),
                            SizedBox(width: 8),
                            Text('Pilih dari Galeri'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'camera',
                        child: Row(
                          children: [
                            Icon(Icons.camera_alt, size: 20),
                            SizedBox(width: 8),
                            Text('Ambil Foto'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'remove',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Hapus Foto',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormField(
            label: 'Nama Lengkap',
            controller: controller.nameController,
            hintText: 'Masukkan nama lengkap',
            validator: controller.validateName,
            prefixIcon: Icons.person_outline,
          ),
          SizedBox(height: 20),
          _buildFormField(
            label: 'Username',
            controller: controller.usernameController,
            hintText: 'Masukkan username',
            validator: controller.validateUsername,
            prefixText: '@',
            helperText:
                'Username hanya boleh mengandung huruf, angka, dan underscore',
          ),
          SizedBox(height: 20),
          _buildFormField(
            label: 'Email',
            controller: controller.emailController,
            hintText: 'Masukkan email',
            validator: controller.validateEmail,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            readOnly: true,
          ),
          SizedBox(height: 20),
          _buildBioField(),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    String? Function(String?)? validator,
    IconData? prefixIcon,
    String? prefixText,
    String? helperText,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Get.theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        if (helperText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              helperText,
              style: Get.theme.textTheme.bodySmall?.copyWith(
                color: Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
          ),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          style: TextStyle(
            color: readOnly 
                ? Get.theme.textTheme.bodyLarge?.color?.withOpacity(0.6) 
                : Get.theme.textTheme.bodyLarge?.color,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: Get.theme.hintColor)
                : null,
            prefixText: prefixText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Get.theme.dividerColor.withOpacity(0.5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Get.theme.dividerColor.withOpacity(0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Get.theme.primaryColor,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: readOnly 
                ? Get.theme.disabledColor.withOpacity(0.1) 
                : Get.theme.inputDecorationTheme.fillColor,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          keyboardType: keyboardType,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bio',
          style: Get.theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller.bioController,
          style: TextStyle(
            color: Get.theme.textTheme.bodyLarge?.color,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: 'Ceritakan tentang dirimu...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Get.theme.dividerColor.withOpacity(0.5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Get.theme.dividerColor.withOpacity(0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Get.theme.primaryColor,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Get.theme.inputDecorationTheme.fillColor,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            counterText: '',
          ),
          maxLines: 4,
          maxLength: 150,
          validator: controller.validateBio,
        ),
        Obx(
          () => Align(
            alignment: Alignment.centerRight,
            child: Text(
              controller.bioCharCount.value,
              style: Get.theme.textTheme.bodySmall?.copyWith(
                color: Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Obx(
          () => SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed:
                  controller.isLoading.value ? null : controller.saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Get.theme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
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
                  : Text(
                      'Simpan Perubahan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: controller.cancelEditing,
            style: OutlinedButton.styleFrom(
              foregroundColor: Get.theme.textTheme.bodyMedium?.color,
              side: BorderSide(
                color: Get.theme.dividerColor.withValues(alpha: 0.5),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Batal',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
