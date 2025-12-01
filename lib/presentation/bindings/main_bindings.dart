import 'package:get/get.dart';
import 'package:terra_brain/presentation/controllers/LoginController.dart';
import 'package:terra_brain/presentation/controllers/all_author_controller.dart';
import 'package:terra_brain/presentation/controllers/author_controller.dart';
import 'package:terra_brain/presentation/controllers/author_profile_controller.dart';
import 'package:terra_brain/presentation/controllers/edit_profile_controller.dart';
import 'package:terra_brain/presentation/controllers/profile_controller.dart';
import 'package:terra_brain/presentation/controllers/reading_controller.dart';
import 'package:terra_brain/presentation/controllers/register_controller.dart';
import 'package:terra_brain/presentation/controllers/setting_controller.dart';
import 'package:terra_brain/presentation/controllers/story_controller.dart';
import 'package:terra_brain/presentation/themes/theme_controller.dart';

import '../controllers/all_novel_controller.dart';
import '../controllers/edit_story_controller.dart';
import '../controllers/genre_selection_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/writing_controller.dart';

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



class SensorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
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

class StoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StoryController>(
      () => StoryController(),
    );
  }
}

class EditStoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditStoryController>(
      () => EditStoryController(),
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

class AllAuthorBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AllAuthorController>(() => AllAuthorController());
  }
}