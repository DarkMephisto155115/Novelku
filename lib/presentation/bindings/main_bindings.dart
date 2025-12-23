import 'package:get/get.dart';
import 'package:terra_brain/presentation/controllers/auth/LoginController.dart';
import 'package:terra_brain/presentation/controllers/author/author_controller.dart';
import 'package:terra_brain/presentation/controllers/author/author_profile_controller.dart';
import 'package:terra_brain/presentation/controllers/novel/edit_chapter_controller.dart';
import 'package:terra_brain/presentation/controllers/novel/edit_novel_controller.dart';
import 'package:terra_brain/presentation/controllers/profile/edit_profile_controller.dart';
import 'package:terra_brain/presentation/controllers/premium_controller.dart';
import 'package:terra_brain/presentation/controllers/profile/profile_controller.dart';
import 'package:terra_brain/presentation/controllers/reading_controller.dart';
import 'package:terra_brain/presentation/controllers/auth/register_controller.dart';
import 'package:terra_brain/presentation/controllers/setting_controller.dart';
import 'package:terra_brain/presentation/themes/theme_controller.dart';

import '../controllers/all_novel_controller.dart';
import '../controllers/auth/genre_selection_controller.dart';
import '../controllers/novel_chapters_controller.dart';
import '../controllers/write/writing_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {}
}

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(
      () => LoginController(),
    );
  }
}

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(
      () => ProfileController(),
    );
  }
}

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegistrationController>(
      () => RegistrationController(),
    );
  }
}

class SettingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(
      () => SettingsController(),
    );
  }
}

class EditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditProfileController>(
      () => EditProfileController(),
    );
  }
}

class AuthorsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthorsController>(() => AuthorsController());
  }
}

class AuthorProfileBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthorProfileController>(() => AuthorProfileController());
  }
}

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ThemeController>(
      () => ThemeController(),
    );
    Get.lazyPut<PremiumController>(
      () => PremiumController(),
      fenix: true,
    );
  }
}

class AllNovelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AllNovelController>(
      () => AllNovelController(),
    );
  }
}

class ReadingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReadingController>(
      () => ReadingController(),
    );
  }
}

class GenreSelectionBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GenreSelectionController>(() => GenreSelectionController());
  }
}

class WritingBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WritingController>(() => WritingController());
  }
}

class NovelChaptersBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NovelChaptersController>(() => NovelChaptersController());
  }
}

class EditNovelBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditNovelController>(() => EditNovelController());
  }
}

class EditChapterBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditChapterController>(() => EditChapterController());
  }
}
