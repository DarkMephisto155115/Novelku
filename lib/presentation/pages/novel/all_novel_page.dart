import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/novel_card.dart';
import '../../controllers/all_novel_controller.dart';


class SemuaNovelPage extends StatelessWidget {
  const SemuaNovelPage({super.key});


  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AllNovelController());


    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Novel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari novel...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: controller.filterNovel,
            ),
            const SizedBox(height: 16),
            Obx(() => Text(
              '${controller.filteredNovels.length} novel ditemukan',
              style: const TextStyle(fontWeight: FontWeight.bold),
            )),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(
                    () => GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: controller.filteredNovels.length,
                  itemBuilder: (context, index) {
                    final novel = controller.filteredNovels[index];


                    // Gunakan widget custom grid item
                    return AllNovelGridItem(novel: novel);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}