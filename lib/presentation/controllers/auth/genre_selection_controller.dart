import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terra_brain/presentation/models/genre_model.dart';
import 'package:terra_brain/presentation/themes/theme_data.dart';


class GenreSelectionController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<Genre> genres = <Genre>[].obs;

  late String userID;
  final RxInt selectedCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserId();
    fetchGenres();

    ever(genres, (_) {
      selectedCount.value = genres.where((genre) => genre.isSelected).length;
    });
  }

  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userID = prefs.getString("userId") ?? "";

    if (userID.isEmpty) {
      print("❌ userID tidak ditemukan di SharedPreferences");
    } else {
      print("✅ userID ditemukan: $userID");
    }
  }

  Future<void> fetchGenres() async {
    try {
      final snapshot = await _firestore.collection('genres').get();

      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        return Genre.fromMap({
          "id": doc.id,
          "name": data["name"],
          "emoji": data["emoji"],
        });
      }).toList();

      genres.assignAll(list);
    } catch (e) {
      print("Error fetching genres: $e");
      Get.snackbar("Error", "Gagal memuat genre");
    }
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
    try {
      final userRef = _firestore.collection('users').doc(userID);

      for (var genre in selectedGenres) {
        await userRef.collection("selectedGenres").doc(genre.id).set({
          "name": genre.name,
          "emoji": genre.emoji,
        });
      }
    } catch (e) {
      print("Error saving genre subcollection: $e");
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