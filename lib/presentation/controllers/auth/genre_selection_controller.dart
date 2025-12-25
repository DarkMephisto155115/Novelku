import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terra_brain/presentation/models/genre_model.dart';
import 'package:terra_brain/presentation/service/firestore_cache_service.dart';
import 'package:terra_brain/presentation/themes/theme_data.dart';


class GenreSelectionController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreCacheService _cacheService =
      Get.find<FirestoreCacheService>();

  final RxList<Genre> genres = <Genre>[].obs;

  late String userID;
  final RxInt selectedCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    await loadUserId();
    await fetchGenres();

    ever(genres, (_) {
      selectedCount.value =
          genres.where((genre) => genre.isSelected).length;
    });
  }

  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userID = prefs.getString("userId") ?? "";
  }

  Future<void> fetchGenres() async {
    try {
      final genresRef = _firestore.collection('genres');
      final snapshot = await _cacheService.queryGet(genresRef);
      if (_setGenres(snapshot)) {
        return;
      }

      if (snapshot.metadata.isFromCache) {
        final refreshed =
            await _cacheService.queryGet(genresRef, forceRefresh: true);
        _setGenres(refreshed);
      }
    } catch (e) {
      print("Error fetching genres: $e");
      Get.snackbar("Error", "Gagal memuat genre");
    }
  }

  bool _setGenres(QuerySnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.docs.isEmpty) {
      Get.snackbar("Info", "Genre belum tersedia");
      genres.clear();
      return true;
    }

    final list = snapshot.docs.map((doc) {
      final data = doc.data();
      return Genre.fromMap(
        data,
        doc.id,
      );
    }).toList();

    genres.assignAll(list);
    return false;
  }


  void toggleGenre(String genreId) {
    final index = genres.indexWhere((genre) => genre.id == genreId);
    if (index != -1) {
      final genre = genres[index];
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

  Future<void> saveSelectedGenres(List<Genre> selectedGenres) async {
      final userRef = _firestore.collection('users').doc(userID);
      final old = await userRef.collection("selectedGenres").get();

      for (var doc in old.docs) {
        await doc.reference.delete();
      }

      for (var genre in selectedGenres) {
        await userRef.collection("selectedGenres").doc(genre.id).set({
          "name": genre.name,
          "emoji": genre.emoji,
        });
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

    saveSelectedGenres(selectedGenres);
    Get.offAllNamed('/home');
    Get.snackbar(
      'Berhasil!',
      'Preferensi genre telah disimpan',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppThemeData.successColor,
      colorText: AppThemeData.darkTextPrimary,
    );
  }

  bool get canProceed => selectedCount.value >= 3;
}