import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terra_brain/firebase_options.dart';
import 'package:terra_brain/presentation/app.dart';
import 'package:terra_brain/presentation/service/firestore_cache_service.dart';
import 'package:terra_brain/presentation/service/analytics_service.dart';
// import 'package:terra_brain/presentation/service/notif_handler.dart';
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

  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  Get.put<FirestoreCacheService>(FirestoreCacheService(), permanent: true);

  final analyticsService = AnalyticsService();
  Get.put<AnalyticsService>(analyticsService, permanent: true);

  await _initializeAnalytics(analyticsService);

  // await NotificationHandler().initialize();

  runApp(const MyApp());
}

Future<void> _initializeAnalytics(AnalyticsService analyticsService) async {
  try {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final packageInfo = await _getPackageInfo();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      await analyticsService.setDeviceProperties(
        appVersion: packageInfo['version'] ?? '1.0.0',
        osVersion: androidInfo.version.release,
        deviceModel: androidInfo.model,
        deviceBrand: androidInfo.brand,
      );
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfoPlugin.iosInfo;
      await analyticsService.setDeviceProperties(
        appVersion: packageInfo['version'] ?? '1.0.0',
        osVersion: iosInfo.systemVersion,
        deviceModel: iosInfo.model,
        deviceBrand: 'Apple',
      );
    }

    await analyticsService.setConsent(granted: true);
    await analyticsService.logAppOpen();
    analyticsService.startSession();
  } catch (e) {
    debugPrint('Error initializing analytics: $e');
  }
}

Future<Map<String, String?>> _getPackageInfo() async {
  try {
    final prefs = Get.find<SharedPreferences>();
    final version = prefs.getString('app_version') ?? '1.0.0';
    return {'version': version};
  } catch (e) {
    return {'version': '1.0.0'};
  }
}
