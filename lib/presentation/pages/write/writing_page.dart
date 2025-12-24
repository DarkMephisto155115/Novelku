import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/write/writing_controller.dart';
import '../../controllers/setting_controller.dart';

class WritingPage extends StatelessWidget {
  final c = Get.put(WritingController());

  late Color bgColor;
  late Color appBarBgColor;
  late Color textColor;
  late Color cardColor;
  late Color inputBgColor;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDarkMode = c.themeController.isDarkMode;
      bgColor = isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100;
      appBarBgColor = isDarkMode ? Colors.grey.shade900 : Colors.white;
      textColor = isDarkMode ? Colors.white : Colors.black;
      cardColor = isDarkMode ? Colors.grey.shade800 : Colors.white;
      inputBgColor = isDarkMode ? Colors.grey.shade700 : Colors.grey.shade100;
      
      final coverBgColor = isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200;
      final coverBorderColor = isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400;
      final placeholderTextColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;

      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: appBarBgColor,
          elevation: 0.5,
          centerTitle: true,
          title: Text(
            "Tulis Novel",
            style: TextStyle(color: textColor),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: textColor),
            onPressed: () {
              Navigator.of(Get.context!).maybePop();
            },
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      visualDensity: VisualDensity.compact,
                      minimumSize: const Size(0, 36),
                    ),
                    onPressed: () => c.showPreview(),
                    child: const Text(
                      "Preview",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Obx(() => ElevatedButton(
                        onPressed:
                            c.isLoading.value ? null : () => c.saveNovel(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7A4FFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          minimumSize: const Size(0, 36),
                        ),
                        child: c.isLoading.value
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Simpan",
                                style: TextStyle(fontSize: 14),
                              ),
                      )),
                  const SizedBox(width: 8),
                ],
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: c.formKey,
            child: Column(
              children: [
                _cardCoverImage(coverBgColor, coverBorderColor, placeholderTextColor),
                const SizedBox(height: 16),
                _cardInformasiNovel(),
                const SizedBox(height: 16),
                _cardDeskripsi(),
                const SizedBox(height: 16),
                _cardTulisCerita(placeholderTextColor),
                const SizedBox(height: 16),
                _cardTipsMenulis(),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _cardCoverImage(Color coverBgColor, Color coverBorderColor, Color placeholderTextColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title("Cover Novel (Optional)"),
          const SizedBox(height: 12),
          Obx(
            () => GestureDetector(
              onTap: () => c.pickCoverImage(),
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: coverBgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: coverBorderColor,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  image: c.coverImagePath.value.isNotEmpty
                      ? DecorationImage(
                          image: FileImage(File(c.coverImagePath.value)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: c.coverImagePath.value.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 48,
                            color: placeholderTextColor,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap untuk memilih cover',
                            style: TextStyle(
                              color: placeholderTextColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
          ),
          Obx(() {
            if (c.coverImagePath.value.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton.icon(
                  onPressed: () => c.coverImagePath.value = '',
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Hapus Cover'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
        ],
      ),
    );
  }

  // =============================
  // CARD INFORMASI NOVEL
  // =============================
  Widget _cardInformasiNovel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title("Informasi Novel"),
          const SizedBox(height: 16),
          _label("Judul Novel"),
          Obx(
            () => TextFormField(
              controller: c.judulNovelC,
              decoration: _inputDecoration("Masukkan judul novel").copyWith(
                errorText: c.judulNovelC.text.isEmpty && c.isLoading.value
                    ? null
                    : null,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Judul novel harus diisi';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          _label("Genre"),
          Obx(
            () {
              if (c.errorMessage.value.isNotEmpty && c.listGenre.isEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              c.errorMessage.value,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return DropdownButtonFormField<String>(
                value: c.genreC.value.isEmpty ? null : c.genreC.value,
                decoration: _inputDecoration("Pilih Genre"),
                items: c.listGenre
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(e),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) c.genreC.value = val;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Genre harus dipilih';
                  }
                  return null;
                },
              );
            },
          ),
          const SizedBox(height: 16),
          _label("Status Publikasi"),
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: _fieldDecoration(),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: c.selectedStatus.value,
                  isExpanded: true,
                  onChanged: (val) {
                    if (val != null) c.selectedStatus.value = val;
                  },
                  items: c.statusOptions
                      .map(
                        (e) => DropdownMenuItem<String>(
                          value: e,
                          child: Text(e),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _label("Judul Bab Pertama"),
          TextFormField(
            controller: c.judulBabC,
            decoration: _inputDecoration("Masukkan judul bab"),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Judul bab harus diisi';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // =============================
  // CARD DESKRIPSI
  // =============================
  Widget _cardDeskripsi() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title("Deskripsi Novel (Optional)"),
          const SizedBox(height: 16),
          TextField(
            controller: c.deskripsiC,
            maxLines: 3,
            decoration: _inputDecoration(
              "Tulis deskripsi singkat novel Anda...",
            ).copyWith(
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  // =============================
  // CARD TULIS CERITA
  // =============================
  Widget _cardTulisCerita(Color placeholderTextColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title("Tulis Cerita"),
          const SizedBox(height: 8),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${c.jumlahHuruf} karakter",
                  style: TextStyle(
                    color: c.jumlahHuruf.value <
                            WritingController.minCharacterCount
                        ? Colors.orange
                        : placeholderTextColor,
                    fontSize: 12,
                    fontWeight: c.jumlahHuruf.value <
                            WritingController.minCharacterCount
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                if (c.jumlahHuruf.value < WritingController.minCharacterCount)
                  Text(
                    'Kurang ${WritingController.minCharacterCount - c.jumlahHuruf.value} karakter',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => TextFormField(
              controller: c.ceritaC,
              maxLines: 12,
              style: TextStyle(
                fontSize: c.getFontSize(),
                fontFamily: c.getFontFamilyValue(c.getFontFamily()),
                height: 1.6,
              ),
              decoration: _inputDecoration(
                "Mulai tulis ceritamu di sini...\n\nContoh:\nDi sebuah desa kecil yang terletak di kaki gunung...",
              ).copyWith(
                contentPadding: const EdgeInsets.all(16),
                errorText: c.jumlahHuruf.value <
                            WritingController.minCharacterCount &&
                        c.ceritaC.text.isNotEmpty
                    ? 'Minimal ${WritingController.minCharacterCount} karakter'
                    : null,
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.orange),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Cerita harus diisi';
                }
                if (value.length < WritingController.minCharacterCount) {
                  return 'Minimal ${WritingController.minCharacterCount} karakter';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tips: Gunakan paragraf untuk memudahkan pembaca. Gunakan dialog untuk membuat cerita lebih hidup.",
            style: TextStyle(
              fontSize: 12,
              color: c.themeController.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
          )
        ],
      ),
    );
  }

  // =============================
  // CARD TIPS MENULIS
  // =============================
  Widget _cardTipsMenulis() {
    final tipsBgColor = c.themeController.isDarkMode 
        ? Colors.purple.shade900 
        : const Color(0xFFF7EDFF);
    final tipsTextColor = c.themeController.isDarkMode 
        ? Colors.purple.shade300 
        : Colors.purple;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(color: tipsBgColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title("Tips Menulis Novel", color: tipsTextColor),
          const SizedBox(height: 8),
          _bullet("Buat outline cerita sebelum mulai menulis"),
          _bullet("Kembangkan karakter yang kuat dan menarik"),
          _bullet("Gunakan deskripsi yang detail namun tidak berlebihan"),
          _bullet("Buat konflik yang menarik untuk menggerakkan cerita"),
          _bullet("Edit dan revisi setelah selesai menulis"),
        ],
      ),
    );
  }

  // =============================
  // WIDGET UTILITAS
  // =============================
  Widget _label(String text) => Text(text,
      style: TextStyle(fontWeight: FontWeight.w600, color: textColor));

  Widget _title(String text, {Color? color}) => Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: color ?? textColor,
        ),
      );

  Widget _bullet(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("• ", style: TextStyle(color: textColor)),
            Expanded(child: Text(text, style: TextStyle(color: textColor))),
          ],
        ),
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: inputBgColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      );

  BoxDecoration _boxDecoration({Color? color, Color? shadow}) => BoxDecoration(
        color: color ?? cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadow ?? (c.themeController.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      );

  BoxDecoration _fieldDecoration() => BoxDecoration(
        color: inputBgColor,
        borderRadius: BorderRadius.circular(10),
      );
}
