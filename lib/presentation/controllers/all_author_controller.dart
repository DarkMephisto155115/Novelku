import 'package:get/get.dart';

class Penulis {
  final String nama;
  final String foto;
  final String deskripsi;
  final int jumlahNovel;
  final String pengikut;
  final String genre;
  final bool isBaru;

  Penulis({
    required this.nama,
    required this.foto,
    required this.deskripsi,
    required this.jumlahNovel,
    required this.pengikut,
    required this.genre,
    required this.isBaru,
  });
}

class AllAuthorController extends GetxController {
  List<Penulis> penulisBaru = [
    Penulis(
      nama: "Sarah Wijaya",
      foto: "https://picsum.photos/100/100?random=10",
      deskripsi: "Penulis cerita romance yang hangat dan penuh emosi",
      jumlahNovel: 3,
      pengikut: "1.2K",
      genre: "Romance",
      isBaru: true,
    ),
    Penulis(
      nama: "Andi Pratama",
      foto: "https://picsum.photos/100/100?random=11",
      deskripsi: "Menciptakan dunia fantasi yang penuh petualangan",
      jumlahNovel: 2,
      pengikut: "856",
      genre: "Fantasy",
      isBaru: true,
    ),
    Penulis(
      nama: "Maya Indah",
      foto: "https://picsum.photos/100/100?random=12",
      deskripsi: "Spesialis cerita misteri yang penuh penasaran",
      jumlahNovel: 5,
      pengikut: "2.4K",
      genre: "Mystery",
      isBaru: true,
    ),
  ];

  List<Penulis> penulisPopuler = [
    Penulis(
      nama: "Budi Setiawan",
      foto: "https://picsum.photos/100/100?random=13",
      deskripsi: "Mengeksplorasi masa depan melalui cerita sci-fi",
      jumlahNovel: 4,
      pengikut: "3.1K",
      genre: "Sci-Fi",
      isBaru: false,
    ),
    Penulis(
      nama: "Dina Kartika",
      foto: "https://picsum.photos/100/100?random=14",
      deskripsi: "Cerita drama kehidupan yang menyentuh hati",
      jumlahNovel: 6,
      pengikut: "4.5K",
      genre: "Drama",
      isBaru: false,
    ),
  ];
}
