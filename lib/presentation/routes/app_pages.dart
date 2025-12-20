import 'package:get/get.dart';
import 'package:terra_brain/presentation/bindings/main_bindings.dart';
import 'package:terra_brain/presentation/pages/auth/genre_selection_page.dart';
import 'package:terra_brain/presentation/pages/author/author_page.dart';
import 'package:terra_brain/presentation/pages/author/author_profile_page.dart';
import 'package:terra_brain/presentation/pages/novel/all_novel_page.dart';
import 'package:terra_brain/presentation/pages/novel/novel_chapters_page.dart';
import 'package:terra_brain/presentation/pages/novel/edit_chapter_page.dart';
import 'package:terra_brain/presentation/pages/novel/edit_novel_page.dart';
import 'package:terra_brain/presentation/pages/novel/reading_page.dart';
import 'package:terra_brain/presentation/pages/profil/edit_profile_page.dart';
import 'package:terra_brain/presentation/pages/profil/edit_story_page.dart';
import 'package:terra_brain/presentation/pages/home/home_page.dart';
import 'package:terra_brain/presentation/pages/auth/login_page.dart';
import 'package:terra_brain/presentation/pages/profil/profile_page.dart';
import 'package:terra_brain/presentation/pages/auth/registration_page.dart';
import 'package:terra_brain/presentation/pages/profil/setting_page.dart';
import 'package:terra_brain/presentation/pages/auth/splash_screen.dart';
import 'package:terra_brain/presentation/pages/write/writing_page.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = '/splash';

  static final routes = [
    GetPage(
      name: '/splash',
      page: () => SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => HomePage(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfilePage(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Routes.REGISTRATION,
      page: () => const RegistrationPage(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.SPLASH,
      page: () => SplashScreen(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.SETTING,
      page: () => const SettingsPage(),
      binding: SettingBinding(),
    ),
    GetPage(
      name: Routes.Edit,
      page: () => EditProfilePage(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: Routes.EDIT_READ,
      page: () => EditStoryPage(),
      binding: EditStoryBinding(),
    ),
    GetPage(
      name: Routes.ALL_NOVEL,
      page: () => SemuaNovelPage(),
      binding: AllNovelBinding(),
    ),
    GetPage(
      name: '/list_author',
      page: () => const AuthorsPage(),
      binding: AuthorsBinding(),
    ),
    GetPage(
      name: '/author_profile/:id',
      page: () => const AuthorProfilePage(),
      binding: AuthorProfileBinding(),
    ),
    GetPage(
      name: Routes.READING,
      page: () => ReadingPage(),
      binding: ReadingBinding(),
    ),
    GetPage(
      name: Routes.GENRE_SELECTION,
      page: () => const GenreSelectionPage(),
      binding: GenreSelectionBinding(),
    ),
    GetPage(
      name: Routes.WRITING,
      page: () => WritingPage(),
      binding: WritingBinding(),
    ),
    GetPage(
      name: Routes.NOVEL_CHAPTERS,
      page: () => const NovelChaptersPage(),
      binding: NovelChaptersBinding(),
    ),
    GetPage(
      name: '/edit_novel/:id',
      page: () => EditNovelPage(),
      binding: EditNovelBinding(),
    ),
    GetPage(
      name: '/edit_chapter',
      page: () => EditChapterPage(),
      binding: EditChapterBinding(),
    ),
  ];
}
