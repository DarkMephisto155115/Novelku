import 'package:get/get.dart';
import '../models/novel_item.dart';

class AllNovelController extends GetxController {
  var novels = <NovelItem>[].obs;
  var filteredNovels = <NovelItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDummyData();
  }

  void loadDummyData() {
    final dummy = [
      NovelItem(
        id: '1',
        title: 'Dunia Fantasi',
        author: 'Penulis A',
        coverUrl: 'https://picsum.photos/200/300?random=20',
        genre: ['Fantasy', 'Adventure'],
        rating: 4.8,
        chapters: 120,
        readers: 34000,
        isNew: true,
      ),
      NovelItem(
        id: '2',
        title: 'Cinta di Musim Semi',
        author: 'Penulis B',
        coverUrl: 'https://picsum.photos/200/300?random=21',
        genre: ['Romance', 'Drama'],
        rating: 4.6,
        chapters: 89,
        readers: 27000,
      ),
      NovelItem(
        id: '3',
        title: 'Misteri Malam',
        author: 'Penulis C',
        coverUrl: 'https://picsum.photos/200/300?random=22',
        genre: ['Mystery', 'Horror'],
        rating: 4.9,
        chapters: 102,
        readers: 41000,
        isNew: true,
      ),
      NovelItem(
        id: '4',
        title: 'Petualangan Hebat',
        author: 'Penulis D',
        coverUrl: 'https://picsum.photos/200/300?random=23',
        genre: ['Adventure', 'Fantasy'],
        rating: 4.7,
        chapters: 140,
        readers: 39000,
      ),
      NovelItem(
        id: '5',
        title: 'Kisah Sci-Fi',
        author: 'Penulis E',
        coverUrl: 'https://picsum.photos/200/300?random=24',
        genre: ['Sci-Fi', 'Action'],
        rating: 4.5,
        chapters: 75,
        readers: 22000,
      ),
      NovelItem(
        id: '6',
        title: 'Drama Kehidupan',
        author: 'Penulis F',
        coverUrl: 'https://picsum.photos/200/300?random=25',
        genre: ['Drama', 'Romance'],
        rating: 4.4,
        chapters: 68,
        readers: 18000,
      ),
    ];

    novels.assignAll(dummy);
    filteredNovels.assignAll(dummy);
  }

  void filterNovel(String keyword) {
    if (keyword.isEmpty) {
      filteredNovels.assignAll(novels);
    } else {
      filteredNovels.assignAll(
        novels.where(
              (e) => e.title.toLowerCase().contains(keyword.toLowerCase()),
        ),
      );
    }
  }
}
