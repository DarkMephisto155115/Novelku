import 'package:get/get.dart';
import 'package:terra_brain/presentation/models/genre_model.dart';
import 'package:terra_brain/presentation/themes/theme_data.dart';


class GenreSelectionController extends GetxController {
  final RxList<Genre> genres = <Genre>[
    Genre(id: '1', name: 'Fantasi', emoji: '🧙‍♂️'),
    Genre(id: '2', name: 'Romantis', emoji: '💖'),
    Genre(id: '3', name: 'Misteri', emoji: '🕵️‍♂️'),
    Genre(id: '4', name: 'Petualangan', emoji: '🗺️'),
    Genre(id: '5', name: 'Sci-Fi', emoji: '🚀'),
    Genre(id: '6', name: 'Horor', emoji: '👻'),
    Genre(id: '7', name: 'Drama', emoji: '🎭'),
    Genre(id: '8', name: 'Komedi', emoji: '😂'),
    Genre(id: '9', name: 'Aksi', emoji: '💥'),
  ].obs;

  final RxInt selectedCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to changes in genres selection
    ever(genres, (_) {
      selectedCount.value = genres.where((genre) => genre.isSelected).length;
    });
  }

  void toggleGenre(String genreId) {
    final index = genres.indexWhere((genre) => genre.id == genreId);
    if (index != -1) {
      final genre = genres[index];
      // Jika sudah mencapai 3 dan mencoba menambah, tidak boleh
      if (selectedCount.value >= 3 && !genre.isSelected) {
        Get.snackbar(
          'Peringatan',
          'Maksimal 3 genre yang bisa dipilih',
          snackPosition: SnackPosition.BOTTOM,
          // backgroundColor: Colors.orange  ,
          // colorText: Colors.white,
          // colorText: Colors.white,
        );
        return;
      }
      
      genres[index] = genre.copyWith(isSelected: !genre.isSelected);
    }
  }

  void proceedToHome() {
    final selectedGenres = genres.where((genre) => genre.isSelected).toList();
    
    if (selectedGenres.length < 3) {
      Get.snackbar(
        'Peringatan',
        'Pilih minimal 3 genre favoritmu',
        snackPosition: SnackPosition.BOTTOM,
        // backgroundColor: Colors.orange,
        // colorText: Colors.white,
      );
      return;
    }

    // Simpan preference genre ke SharedPreferences atau database
    _saveGenrePreferences(selectedGenres);

    Get.offAllNamed('/home'); // Navigasi ke halaman utama
    Get.snackbar(
      'Berhasil!',
      'Preferensi genre telah disimpan',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppThemeData.successColor,
      colorText: AppThemeData.darkTextPrimary,
    );
  }

  void _saveGenrePreferences(List<Genre> selectedGenres) {
    // Simpan ke SharedPreferences atau database
    final genreIds = selectedGenres.map((genre) => genre.id).toList();
    print('Genre yang dipilih: $genreIds');
    
    // Contoh: Simpan ke Get Storage atau SharedPreferences
    // GetStorage().write('selected_genres', genreIds);
  }

  bool get canProceed => selectedCount.value >= 3;
}