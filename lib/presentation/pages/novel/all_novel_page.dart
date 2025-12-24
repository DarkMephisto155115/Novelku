import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/novel_card.dart';
import '../../controllers/all_novel_controller.dart';
import '../../controllers/setting_controller.dart';
import '../../controllers/write/writing_controller.dart';


class SemuaNovelPage extends StatelessWidget {
  const SemuaNovelPage({super.key});


  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AllNovelController());

    return Obx(() {
      final writingController = Get.find<WritingController>();
      final isDarkMode = writingController.themeController.isDarkMode;
      final bgColor = isDarkMode ? Colors.grey.shade900 : Colors.white;
      final textColor = isDarkMode ? Colors.white : Colors.black;

      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text('Semua Novel', style: TextStyle(color: textColor)),
        ),
        body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'Cari novel...',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                prefixIcon: Icon(Icons.search, color: textColor),
                filled: true,
                fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: controller.filterNovel,
            ),
            const SizedBox(height: 16),
            Obx(() => Text(
              '${controller.filteredNovels.length} novel ditemukan',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
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
    });
  }
}