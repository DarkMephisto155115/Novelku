import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WritingController extends GetxController {
  final judulNovelC = TextEditingController();
  final genreC = ''.obs;
  final judulBabC = TextEditingController();
  final ceritaC = TextEditingController();

  RxInt jumlahKata = 0.obs;

  @override
  void onInit() {
    super.onInit();
    ceritaC.addListener(() {
      jumlahKata.value =
      ceritaC.text.trim().isEmpty ? 0 : ceritaC.text.trim().split(RegExp(r"\s+")).length;
    });
  }

  List<String> listGenre = [
    "Romance", "Action", "Drama", "Fantasy", "Comedy"
  ];
}