import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WriteController extends GetxController {
  final RxBool isConnected = false.obs;
  final RxBool isUploading = false.obs;
  var userId = ''.obs;
  var username = ''.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Connectivity _connectivity = Connectivity();
  final GetStorage _storage = GetStorage();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnection();
    _initializeStorage();
    _monitorConnection();
    _getLocalData();
    _getWriterName();
  }

  Future<String?> _getLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? localUserId = prefs.getString('userId');
    if (localUserId != null) {
      userId.value = localUserId;
    }
    return localUserId;
  }

  Future<void> _initializeStorage() async {
    await GetStorage.init();
  }

  void _monitorConnection() {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((result) {
          if (result.contains(ConnectivityResult.wifi) ||
              result.contains(ConnectivityResult.mobile)) {
            isConnected.value = true;
            _showConnectionSnackbar(isConnected.value);
            print("anda kembali online");
            _checkLocalPendingUploads();
          } else {
            isConnected.value = false;
            _showConnectionSnackbar(isConnected.value);
            print("anda offline");
          }
        });
  }

  void _showConnectionSnackbar(bool status) {
    // if (status) {
    //   Get.snackbar(
    //     "Internet Connected",
    //     "You are now online.",
    //     backgroundColor: Colors.green,
    //     colorText: Colors.white,
    //     snackPosition: SnackPosition.BOTTOM,
    //   );
    // } else {
    //   Get.snackbar(
    //     "Internet Disconnected",
    //     "You are offline.",
    //     backgroundColor: Colors.red,
    //     colorText: Colors.white,
    //     snackPosition: SnackPosition.BOTTOM,
    //   );
    // }
  }

  Future<void> _checkInitialConnection() async {
    var result = await _connectivity.checkConnectivity();
    if (result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.mobile)) {
      isConnected.value = true;
    } else {
      isConnected.value = false;
    }
    print("isConnected awal: ${isConnected.value}");
  }

  Future<void> _getWriterName() async {
    if (userId.value.isEmpty) {
      return;
    }
    try {
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(userId.value).get();
      if (userDoc.exists && userDoc.data() != null) {
        username.value = userDoc['username'] ?? 'Unknown Author';
      }
    } catch (e) {
      print('Error saat mengambil username: $e');
    }
  }

  Future<String?> _uploadFileToStorage(File file, String path) async {
    if (!file.existsSync()) {
      print("File tidak ditemukan: ${file.path}");
      return null;
    }

    try {
      if (isConnected.value) {
        final Reference storageRef = FirebaseStorage.instance.ref().child(path);
        final UploadTask uploadTask = storageRef.putFile(file);
        final TaskSnapshot snapshot = await uploadTask;
        return await snapshot.ref.getDownloadURL();
      } else {
        Directory dir = await getApplicationDocumentsDirectory();
        String localPath = "${dir.path}/${path.split('/').last}";
        await file.copy(localPath);
        _addToPendingUploads(localPath, path);
      }
    } catch (e) {
      print("Error saat mengunggah file: $e");
      rethrow;
    }
    return null;
  }

  void _addToPendingUploads(String localPath, String firebasePath) {
    try {
      List<String> pendingUploads =
      (_storage.read('pending_files') as List<dynamic>? ?? [])
          .cast<String>();
      pendingUploads.add(jsonEncode({
        "localPath": localPath,
        "firebasePath": firebasePath,
      }));
      _storage.write('pending_files', pendingUploads);
      print("Disimpan ke pending uploads: $pendingUploads");
    } catch (e) {
      print("Gagal menambahkan ke pending uploads: $e");
    }
  }

  Future<String> saveFileLocally(File file, String filename) async {
    try {
      Directory dir = await getApplicationDocumentsDirectory();
      String filePath = "${dir.path}/$filename";
      await file.copy(filePath);
      return filePath;
    } catch (e) {
      rethrow;
    }
  }

  // Upload Data to Firebase Firestore
  Future<void> uploadData({
    required String title,
    required String content,
    required String chapter,
    required String category,
    File? imageFile,
  }) async {
    try {
      isUploading.value = true;

      // ✅ Pastikan username sudah ada
      if (username.value.isEmpty) {
        await _getWriterName();
      }

      String? imageUrl;

      // ✅ Upload Image kalau ada
      if (imageFile != null) {
        String imagePath =
            'images/${DateTime.now().millisecondsSinceEpoch}.png';
        imageUrl = await _uploadFileToStorage(imageFile, imagePath);
      }

      String createdAt = DateTime.now().toIso8601String();

      // ✅ Cari apakah sudah ada story dengan judul yang sama
      QuerySnapshot existingStories = await FirebaseFirestore.instance
          .collection('stories')
          .where('title', isEqualTo: title)
          .get();

      if (existingStories.docs.isNotEmpty) {
        // 🔹 Kalau ada → tambahkan chapter ke story pertama yang ditemukan
        DocumentSnapshot storyDoc = existingStories.docs.first;

        // Ambil list chapters yang sudah ada
        List<dynamic> chapters = storyDoc['chapters'] ?? [];

        chapters.add({
          "chapter": chapter,
          "content": content,
          "imageUrl": imageUrl,
          "createdAt": createdAt,
        });

        await FirebaseFirestore.instance
            .collection('stories')
            .doc(storyDoc.id)
            .update({
          "chapters": chapters,
          "updatedAt": createdAt,
        });

        Get.snackbar(
          "Chapter Added",
          "Chapter baru ditambahkan ke cerita '$title'.",
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
        print("Berhasil menambahkan chapter baru ke story $title");
      } else {
        // 🔹 Kalau belum ada → buat story baru
        Map<String, dynamic> data = {
          "title": title,
          "writerId": userId.value,
          "author": username.value,
          "category": category,
          "createdAt": createdAt,
          "chapters": [
            {
              "chapter": chapter,
              "content": content,
              "imageUrl": imageUrl,
              "createdAt": createdAt,
            }
          ]
        };

        await FirebaseFirestore.instance.collection('stories').add(data);

        Get.snackbar(
          "Story Created",
          "Cerita baru '$title' berhasil dibuat.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        print("Berhasil membuat story baru dengan judul $title");
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to upload data: $e",
        backgroundColor: Get.theme.disabledColor,
        colorText: Get.theme.colorScheme.onError,
      );
      print("Gagal upload data (uploadData): $e");
    } finally {
      isUploading.value = false;
    }
  }



  void _saveDataLocally(Map<String, dynamic> data) {
    if (data.isEmpty) return;
    List<String> pendingUploads =
    (_storage.read('pending_uploads') as List<dynamic>? ?? [])
        .map((item) => item.toString())
        .toList();
    pendingUploads.add(jsonEncode(data));
    _storage.write('pending_uploads', pendingUploads);
  }

  void _checkLocalPendingUploads() async {
    if (isConnected.value) {
      List<String> filesPending =
      (_storage.read('pending_files') as List<dynamic>? ?? [])
          .cast<String>();
      List<String> dataPending =
      (_storage.read('pending_uploads') as List<dynamic>? ?? [])
          .cast<String>();

      if (filesPending.isNotEmpty || dataPending.isNotEmpty) {
        print("Starting upload process for pending files and data...");

        List<String> updatedFilesPending = [];
        for (var item in filesPending) {
          try {
            Map<String, dynamic> fileData = jsonDecode(item);
            if (fileData.containsKey("localPath") &&
                fileData.containsKey("firebasePath")) {
              String localPath = fileData["localPath"];
              String firebasePath = fileData["firebasePath"];
              File localFile = File(localPath);
              if (localFile.existsSync()) {
                String? downloadUrl =
                await _uploadFileToStorage(localFile, firebasePath);
                if (downloadUrl == null) {
                  updatedFilesPending.add(item);
                }
              } else {
                updatedFilesPending.add(item);
              }
            }
          } catch (e) {
            updatedFilesPending.add(item);
          }
        }

        if (updatedFilesPending.isNotEmpty) {
          _storage.write('pending_files', updatedFilesPending);
        } else {
          _storage.remove('pending_files');
        }

        List<String> updatedDataPending = [];
        for (var item in dataPending) {
          try {
            Map<String, dynamic> data = jsonDecode(item);
            if (data.containsKey('title')) {
              await _firestore.collection('stories').add(data);
              print("Data successfully uploaded to Firestore: $data");
            } else {
              updatedDataPending.add(item);
            }
          } catch (e) {
            updatedDataPending.add(item);
          }
        }

        if (updatedDataPending.isNotEmpty) {
          _storage.write('pending_uploads', updatedDataPending);
        } else {
          _storage.remove('pending_uploads');
          Get.snackbar("Succes", "Semua pending data telah di upload");
        }
      }
    }
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }
}
