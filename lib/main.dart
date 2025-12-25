import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terra_brain/firebase_options.dart';
import 'package:terra_brain/presentation/app.dart';
import 'package:terra_brain/presentation/service/firestore_cache_service.dart';
import 'package:terra_brain/presentation/service/notif_handler.dart';
import 'package:terra_brain/presentation/themes/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  Get.put<SharedPreferences>(prefs);

  Get.put<ThemeController>(ThemeController(), permanent: true);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  Get.put<FirestoreCacheService>(FirestoreCacheService(), permanent: true);

  // await NotificationHandler().initialize();

  runApp(const MyApp());
}