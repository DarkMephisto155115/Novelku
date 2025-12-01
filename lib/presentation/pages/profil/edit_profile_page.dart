import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/edit_profile_controller.dart';


class EditProfilePage extends StatelessWidget {
  final c = Get.put(EditProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profil"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // PROFILE IMAGE
            Obx(() {
              return GestureDetector(
                onTap: c.pickImage,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: const Color(0xffF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: c.profileImage.value == null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.camera_alt,
                            color: Color(0xff9C27B0), size: 40),
                        SizedBox(height: 8),
                        Text("Klik ikon kamera untuk mengubah foto profil"),
                      ],
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(c.profileImage.value!.path),
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FULL NAME
                  const Text("Nama Lengkap"),
                  const SizedBox(height: 8),
                  Obx(() {
                    return TextField(
                      controller: TextEditingController(text: c.fullName.value),
                      onChanged: (v) => c.fullName.value = v,
                      decoration: inputStyle(),
                    );
                  }),

                  const SizedBox(height: 16),

                  // USERNAME
                  const Text("Username"),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text("@ "),
                      Expanded(
                        child: Obx(() {
                          return TextField(
                            controller:
                            TextEditingController(text: c.username.value),
                            onChanged: (v) => c.username.value = v,
                            decoration: inputStyle(),
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Username hanya boleh mengandung huruf, angka, dan underscore",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),

                  const SizedBox(height: 16),

                  // EMAIL
                  const Text("Email"),
                  const SizedBox(height: 8),
                  Obx(() {
                    return TextField(
                      controller: TextEditingController(text: c.email.value),
                      onChanged: (v) => c.email.value = v,
                      decoration: inputStyle(),
                    );
                  }),

                  const SizedBox(height: 16),

                  // BIO
                  const Text("Bio"),
                  const SizedBox(height: 8),
                  Obx(() {
                    return TextField(
                      controller: TextEditingController(text: c.bio.value),
                      onChanged: (v) => c.bio.value = v,
                      maxLines: 4,
                      decoration: inputStyle(),
                    );
                  }),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Obx(() => Text(
                      "${c.bio.value.length}/150 karakter",
                      style:
                      const TextStyle(fontSize: 12, color: Colors.grey),
                    )),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // BUTTON SAVE
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Simpan Perubahan"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff9C27B0),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: c.saveChanges,
              ),
            ),

            const SizedBox(height: 10),

            // BUTTON CANCEL
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Colors.grey.shade400),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Get.back(),
                child: const Text("Batal"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration inputStyle() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xffF5F5F5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xff9C27B0)),
      ),
    );
  }
}
