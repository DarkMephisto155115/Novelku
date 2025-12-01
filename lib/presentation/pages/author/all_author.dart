import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/all_author_controller.dart';

class AllAuthorPage extends StatelessWidget {
  final c = Get.put(AllAuthorController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          "Semua Penulis",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("✨ Penulis Baru"),
            const SizedBox(height: 8),
            ...c.penulisBaru.map(_cardPenulis),

            const SizedBox(height: 20),
            _sectionTitle("🧑‍🎨 Penulis Populer"),
            const SizedBox(height: 8),
            ...c.penulisPopuler.map(_cardPenulis),
          ],
        ),
      ),
    );
  }

  // ------------------------------
  // WIDGET SECTION TITLE
  // ------------------------------
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // ------------------------------
  // CARD PENULIS
  // ------------------------------
  Widget _cardPenulis(Penulis d) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto Penulis
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.network(
              d.foto,
              width: 55,
              height: 55,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 12),

          // Detail Penulis
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama + Badge "Baru"
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        d.nama,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (d.isBaru)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5D9FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Baru",
                          style: TextStyle(fontSize: 11),
                        ),
                      )
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  d.deskripsi,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade700),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    // Jumlah novel
                    Row(
                      children: [
                        const Icon(Icons.menu_book, size: 16),
                        const SizedBox(width: 4),
                        Text("${d.jumlahNovel} novel",
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                      ],
                    ),

                    const SizedBox(width: 16),

                    // Followers
                    Row(
                      children: [
                        const Icon(Icons.people, size: 16),
                        const SizedBox(width: 4),
                        Text("${d.pengikut} pengikut",
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                      ],
                    ),

                    const Spacer(),

                    // Genre tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(d.genre, style: const TextStyle(fontSize: 12)),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
