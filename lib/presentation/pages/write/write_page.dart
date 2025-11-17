import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:terra_brain/presentation/controllers/write_controller.dart';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';

class WriteStoryPage extends StatefulWidget {
  const WriteStoryPage({super.key});

  @override
  _WriteStoryPageState createState() => _WriteStoryPageState();
}

class _WriteStoryPageState extends State<WriteStoryPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _storyController = TextEditingController();
  final TextEditingController _chapterController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final WriteController _controller = Get.put(WriteController());

  File? _selectedImage;
  File? _selectedVideo;
  VideoPlayerController? _videoPlayerController;

  final List<String> _categories = [
    'Komedi',
    'Horor',
    'Romansa',
    'Thriller',
    'Fantasi',
    'Fiksi Ilmiah',
    'Misteri',
    'Aksi'
  ];
  String? _selectedCategory;

  // 🔹 Fungsi untuk menampilkan snackbar dengan gaya konsisten
  void _showSnackbar(String title, String message, {bool success = false}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: success ? Colors.green : Colors.redAccent,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      borderRadius: 10,
      duration: const Duration(seconds: 3),
      icon: Icon(
        success ? Icons.check_circle : Icons.warning,
        color: Colors.white,
      ),
    );
  }

  // 🔹 Fungsi validasi field sebelum upload
  bool _validateFields() {
    if (_selectedCategory == null) {
      _showSnackbar("Error", "Silakan pilih kategori cerita.");
      return false;
    } else if (_chapterController.text.isEmpty) {
      _showSnackbar("Error", "Chapter tidak boleh kosong.");
      return false;
    } else if (_titleController.text.isEmpty) {
      _showSnackbar("Error", "Judul cerita tidak boleh kosong.");
      return false;
    } else if (_titleController.text.length < 5) {
      _showSnackbar("Error", "Judul terlalu pendek. Minimal 5 karakter.");
      return false;
    } else if (_storyController.text.isEmpty) {
      _showSnackbar("Error", "Konten cerita tidak boleh kosong.");
      return false;
    } else if (_storyController.text.length < 50) {
      _showSnackbar("Error", "Cerita terlalu singkat, minimal 50 karakter.");
      return false;
    } else if (_titleController.text.length > 60) {
      _showSnackbar("Error", "Judul terlalu panjang. Maksimal 60 karakter.");
      return false;
    }else if (_storyController.text.length > 20000) {
      _showSnackbar("Error", "Cerita terlalu Panjang Maksimal 20.000 karakter.");
      return false;
    }
    return true;
  }

  // 🔹 Fungsi untuk menyimpan cerita
  void _saveStory() async {
    if (!_validateFields()) return;

    try {
      await _controller.uploadData(
        title: _titleController.text,
        content: _storyController.text.replaceAll('\n', '\\n'),
        imageFile: _selectedImage,
        category: _selectedCategory!,
        chapter: _chapterController.text,
      );

      _showSnackbar("Sukses", "Cerita berhasil diunggah!", success: true);

      // Kosongkan semua field setelah sukses
      _titleController.clear();
      _chapterController.clear();
      _storyController.clear();
      setState(() {
        _selectedImage = null;
        _selectedVideo = null;
        _selectedCategory = null;
        _videoPlayerController?.dispose();
        _videoPlayerController = null;
      });

      // Kembali ke home
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(context, '/home');
      });
    } catch (e) {
      _showSnackbar("Error", "Gagal mengunggah cerita: $e");
    }
  }

  Widget _statusConnectionWidget() {
    return Obx(
          () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _controller.isConnected.value ? Icons.wifi : Icons.wifi_off,
            color: _controller.isConnected.value ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(
            _controller.isConnected.value ? "Online" : "Offline",
            style: TextStyle(
              color: _controller.isConnected.value ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickMedia(String type, ImageSource source) async {
    XFile? file;

    try {
      if (type == 'image') {
        file = await _picker.pickImage(source: source);
        if (file != null) {
          setState(() {
            _selectedImage = File(file!.path);
            _selectedVideo = null;
            _videoPlayerController?.dispose();
          });
        }
      } else if (type == 'video') {
        file = await _picker.pickVideo(source: source);
        if (file != null) {
          setState(() {
            _selectedVideo = File(file!.path);
            _selectedImage = null;
            _videoPlayerController = VideoPlayerController.file(_selectedVideo!)
              ..addListener(() {
                if (_videoPlayerController!.value.position ==
                    _videoPlayerController!.value.duration) {
                  setState(() {
                    _videoPlayerController!.pause();
                  });
                }
              })
              ..initialize().then((_) {
                setState(() {});
              }).catchError((e) {
                _showSnackbar("Error", "Gagal memuat video: $e");
              });
          });
        }
      }
    } catch (e) {
      _showSnackbar("Error", "Terjadi kesalahan saat memilih media: $e");
    }
  }

  Widget _imageVideoPreview() {
    if (_selectedImage != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              _selectedImage!,
              fit: BoxFit.cover,
              height: 200,
              width: double.infinity,
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 30),
              onPressed: () {
                setState(() {
                  _selectedImage = null;
                });
              },
            ),
          ),
        ],
      );
    } else if (_selectedVideo != null &&
        _videoPlayerController != null &&
        _videoPlayerController!.value.isInitialized) {
      return Stack(
        children: [
          SizedBox(
            height: 200,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: VideoPlayer(_videoPlayerController!),
            ),
          ),
          Center(
            child: IconButton(
              icon: Icon(
                _videoPlayerController!.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
                color: Colors.white,
                size: 50,
              ),
              onPressed: () {
                setState(() {
                  if (_videoPlayerController!.value.isPlaying) {
                    _videoPlayerController!.pause();
                  } else {
                    _videoPlayerController!.play();
                  }
                });
              },
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 30),
              onPressed: () {
                setState(() {
                  _selectedVideo = null;
                  _videoPlayerController?.dispose();
                  _videoPlayerController = null;
                });
              },
            ),
          ),
        ],
      );
    }
    return const Text(
      'Ketuk untuk menambahkan gambar atau video',
      style: TextStyle(color: Colors.grey, fontSize: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        backgroundColor: Colors.deepPurple[700],
        title: const Text(
          'Tulis Ceritamu',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          _statusConnectionWidget(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔹 Dropdown kategori
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.deepPurpleAccent),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  icon: const Icon(Icons.arrow_drop_down,
                      color: Colors.deepPurpleAccent),
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: Colors.white),
                  dropdownColor: Colors.grey[900],
                  hint: const Text("Pilih Genre",
                      style: TextStyle(color: Colors.grey)),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                  },
                  items: _categories.map<DropdownMenuItem<String>>(
                        (String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    },
                  ).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Input Chapter
            TextField(
              controller: _chapterController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Chapter cerita mu',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Media Picker
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(15)),
                  ),
                  builder: (context) {
                    return Wrap(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.camera_alt,
                              color: Colors.deepPurple),
                          title: const Text('Ambil Gambar'),
                          onTap: () {
                            Navigator.pop(context);
                            _pickMedia('image', ImageSource.camera);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.image,
                              color: Colors.deepPurple),
                          title: const Text('Pilih Gambar dari Galeri'),
                          onTap: () {
                            Navigator.pop(context);
                            _pickMedia('image', ImageSource.gallery);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.videocam,
                              color: Colors.deepPurple),
                          title: const Text('Rekam Video'),
                          onTap: () {
                            Navigator.pop(context);
                            _pickMedia('video', ImageSource.camera);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.video_library,
                              color: Colors.deepPurple),
                          title: const Text('Pilih Video dari Galeri'),
                          onTap: () {
                            Navigator.pop(context);
                            _pickMedia('video', ImageSource.gallery);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.deepPurpleAccent),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.deepPurple[700]!, Colors.deepPurple[300]!],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurpleAccent.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(child: _imageVideoPreview()),
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Input Judul
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Judul Ceritamu',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Input Cerita
            TextField(
              controller: _storyController,
              style: const TextStyle(color: Colors.white),
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Tulis ceritamu...',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Tombol Unggah
            Obx(() {
              if (_controller.isUploading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return ElevatedButton(
                onPressed: _saveStory,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.deepPurple[600],
                  padding:
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Unggah Cerita',
                    style: TextStyle(fontSize: 18)),
              );
            }),
          ],
        ),
      ),
    );
  }
}
