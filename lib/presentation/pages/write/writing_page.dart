import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/write/writing_controller.dart';

class WritingPage extends StatelessWidget {
  final c = Get.put(WritingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          "Tulis Novel",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
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
                      onPressed: c.isLoading.value ? null : () => c.saveNovel(),
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
        child: Column(
          children: [
            _cardCoverImage(),
            const SizedBox(height: 16),
            _cardInformasiNovel(),
            const SizedBox(height: 16),
            _cardDeskripsi(),
            const SizedBox(height: 16),
            _cardTulisCerita(),
            const SizedBox(height: 16),
            _cardTipsMenulis(),
          ],
        ),
      ),
    );
  }

  Widget _cardCoverImage() {
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
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade400,
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
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap untuk memilih cover',
                            style: TextStyle(
                              color: Colors.grey.shade600,
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
          TextField(
            controller: c.judulNovelC,
            decoration: _inputDecoration("Masukkan judul novel"),
          ),
          const SizedBox(height: 16),
          _label("Genre"),
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: _fieldDecoration(),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: c.genreC.value.isEmpty ? null : c.genreC.value,
                  hint: const Text("Pilih Genre"),
                  isExpanded: true,
                  onChanged: (val) {
                    if (val != null) c.genreC.value = val;
                  },
                  items: c.listGenre
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
          TextField(
            controller: c.judulBabC,
            decoration: _inputDecoration("Masukkan judul bab"),
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
  Widget _cardTulisCerita() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title("Tulis Cerita"),
          const SizedBox(height: 8),
          Obx(
            () => Align(
              alignment: Alignment.centerRight,
              child: Text(
                "${c.jumlahHuruf} karakter",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: c.ceritaC,
            maxLines: 12,
            decoration: _inputDecoration(
              "Mulai tulis ceritamu di sini...\n\nContoh:\nDi sebuah desa kecil yang terletak di kaki gunung...",
            ).copyWith(
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tips: Gunakan paragraf untuk memudahkan pembaca. Gunakan dialog untuk membuat cerita lebih hidup.",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          )
        ],
      ),
    );
  }

  // =============================
  // CARD TIPS MENULIS
  // =============================
  Widget _cardTipsMenulis() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(color: const Color(0xFFF7EDFF)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title("Tips Menulis Novel", color: Colors.purple),
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
  Widget _label(String text) =>
      Text(text, style: const TextStyle(fontWeight: FontWeight.w600));

  Widget _title(String text, {Color color = Colors.black}) => Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: color,
        ),
      );

  Widget _bullet(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("• "),
            Expanded(child: Text(text)),
          ],
        ),
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      );

  BoxDecoration _boxDecoration({Color? color}) => BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      );

  BoxDecoration _fieldDecoration() => BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      );
}
