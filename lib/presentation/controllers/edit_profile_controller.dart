import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileController extends GetxController {
  var fullName = "Dewi Lestari".obs;
  var username = "dewileStari".obs;
  var email = "dewi.lestari@email.com".obs;
  var bio = "".obs;

  var profileImage = Rx<XFile?>(null);

  Future pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      profileImage.value = picked;
    }
  }

  void saveChanges() {
    // Logic simpan ke backend atau database
    Get.snackbar("Berhasil", "Perubahan profil disimpan.");
  }
}
