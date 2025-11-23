import 'package:get/get.dart';
import 'package:terra_brain/presentation/bindings/main_bindings.dart';
import 'package:terra_brain/presentation/pages/API_page.dart';
import 'package:terra_brain/presentation/pages/profil/edit_profile_page.dart';
import 'package:terra_brain/presentation/pages/profil/edit_story_page.dart';
import 'package:terra_brain/presentation/pages/favorite_page.dart';
import 'package:terra_brain/presentation/pages/gps_page.dart';
import 'package:terra_brain/presentation/pages/home/home_page.dart';
import 'package:terra_brain/presentation/pages/login/login_page.dart';
import 'package:terra_brain/presentation/pages/profil/profile_story_page.dart';
import 'package:terra_brain/presentation/pages/login/registration_page.dart';
import 'package:terra_brain/presentation/pages/profil/setting_page.dart';
import 'package:terra_brain/presentation/pages/login/splash_screen.dart';
import 'package:terra_brain/presentation/pages/home/story_page.dart';
import 'package:terra_brain/presentation/pages/write/write_page.dart';

import '../pages/profil/profile_page.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = '/splash';

  static final routes = [
    GetPage(
      name: '/splash',
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomePage(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileScreen(),
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
        name: Routes.API,
        page: () => const BestSellerListScreen(),
        binding: APIBinding()),
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashScreen(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.SETTING,
      page: () => const SettingPage(),
      binding: SettingBinding(),
    ),
    GetPage(
      name: Routes.FAVORITE,
      page: () => const FavoritesPage(),
      binding: FavoriteBinding(),
    ),
    GetPage(
      name: Routes.WRITE,
      page: () => const WriteStoryPage(),
      binding: SensorBinding(),
    ),
    GetPage(
      name: Routes.GPS,
      page: () => const GpsPage(),
      binding: GpsBinding(),
    ),
    GetPage(
      name: Routes.Edit,
      page: () => const EditProfilePage(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: Routes.READ,
      page: () => const StoryPage(),
      binding: StoryBinding(),
    ),
    GetPage(
      name: Routes.PROFILE_READ,
      page: () => const ProfileStoryPage(),
      binding: StoryBinding(),
    ),
    GetPage(
      name: Routes.EDIT_READ,
      page: () => EditStoryPage(),
      binding: EditStoryBinding(),
    ),
  ];
}
