import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart';
import 'package:logger/logger.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final Logger _logger = Logger();

  DateTime? _sessionStart;

  factory AnalyticsService() {
    return _instance;
  }

  AnalyticsService._internal();

  Future<void> setUserId(String userId) async {
    try {
      await _analytics.setUserId(id: userId);
      _logger.i('User ID set: $userId');
    } catch (e) {
      _logger.e('Error setting user ID: $e');
    }
  }

  Future<void> setUserProperty(String name, String value) async {
    try {
      final cleanName = name.length > 24 ? name.substring(0, 24) : name;
      final cleanValue = value.length > 36 ? value.substring(0, 36) : value;
      await _analytics.setUserProperty(name: cleanName, value: cleanValue);
      _logger.i('User property set: $cleanName = $cleanValue');
    } catch (e) {
      _logger.e('Error setting user property: $e');
    }
  }

  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      final cleanName = name.length > 40 ? name.substring(0, 40) : name;
      final cleanParams = _cleanParameters(parameters);
      await _analytics.logEvent(name: cleanName, parameters: cleanParams);
      _logger.i('Event logged: $cleanName with params: $cleanParams');
    } catch (e) {
      _logger.e('Error logging event: $e');
    }
  }

  Map<String, Object>? _cleanParameters(Map<String, Object>? params) {
    if (params == null) return null;

    final cleaned = <String, Object>{};
    params.forEach((key, value) {
      try {
        final cleanKey = key.length > 40 ? key.substring(0, 40) : key;
        if (value is String) {
          cleaned[cleanKey] =
              value.length > 100 ? value.substring(0, 100) : value;
        } else if (value is int || value is double || value is bool) {
          cleaned[cleanKey] = value;
        } else {
          final valString = value.toString();
          cleaned[cleanKey] =
              valString.length > 100 ? valString.substring(0, 100) : valString;
        }
      } catch (e) {
        _logger.w('Skipping parameter $key: $e');
      }
    });

    return cleaned.isEmpty ? null : cleaned;
  }

  Future<String?> getAppInstanceId() async {
    try {
      return await _analytics.appInstanceId;
    } catch (e) {
      _logger.e('Error getting app instance ID: $e');
      return null;
    }
  }

  Future<void> logLogin({
    required String method,
  }) async {
    await logEvent(
      name: 'login',
      parameters: {
        'method': method,
      },
    );
    await _logSessionStart();
  }

  Future<void> _logSessionStart() async {
    await logEvent(
      name: 'app_session_start',
    );
  }

  Future<void> logSignUp({
    required String method,
  }) async {
    await logEvent(
      name: 'sign_up',
      parameters: {
        'method': method,
      },
    );
    await _logSessionStart();
  }

  Future<void> logViewItem({
    required String itemId,
    required String itemName,
    required String itemCategory,
  }) async {
    await logEvent(
      name: 'view_item',
      parameters: {
        'item_id': itemId,
        'item_name': itemName,
        'content_type': itemCategory,
      },
    );
  }

  Future<void> logViewNovel({
    required String novelId,
    required String novelTitle,
    required String authorId,
    required String genre,
  }) async {
    await logEvent(
      name: 'view_novel',
      parameters: {
        'novel_id': novelId,
        'novel_title': novelTitle,
        'author_id': authorId,
        'genre': genre,
      },
    );
  }

  Future<void> logStartReading({
    required String novelId,
    required String novelTitle,
    required String chapterId,
    required int chapterNumber,
  }) async {
    await logEvent(
      name: 'start_reading',
      parameters: {
        'novel_id': novelId,
        'novel_title': novelTitle,
        'chapter_id': chapterId,
        'chapter_number': chapterNumber,
      },
    );
  }

  Future<void> logFinishReading({
    required String novelId,
    required String novelTitle,
    required String chapterId,
    required int chapterNumber,
    required int readingDurationSeconds,
  }) async {
    await logEvent(
      name: 'finish_reading',
      parameters: {
        'novel_id': novelId,
        'novel_title': novelTitle,
        'chapter_id': chapterId,
        'chapter_number': chapterNumber,
        'duration_seconds': readingDurationSeconds,
      },
    );
  }

  Future<void> logCreateNovel({
    required String novelId,
    required String novelTitle,
    required String genre,
  }) async {
    await logEvent(
      name: 'create_novel',
      parameters: {
        'novel_id': novelId,
        'novel_title': novelTitle,
        'genre': genre,
      },
    );
  }

  Future<void> logPublishChapter({
    required String novelId,
    required String novelTitle,
    required String chapterId,
    required int chapterNumber,
    required int wordCount,
  }) async {
    await logEvent(
      name: 'publish_chapter',
      parameters: {
        'novel_id': novelId,
        'novel_title': novelTitle,
        'chapter_id': chapterId,
        'chapter_number': chapterNumber,
        'word_count': wordCount,
      },
    );
  }

  Future<void> logLikeNovel({
    required String novelId,
    required String novelTitle,
  }) async {
    await logEvent(
      name: 'like_novel',
      parameters: {
        'novel_id': novelId,
        'novel_title': novelTitle,
      },
    );
  }

  Future<void> logComment({
    required String novelId,
    required String novelTitle,
    required String commentLength,
  }) async {
    await logEvent(
      name: 'comment',
      parameters: {
        'novel_id': novelId,
        'novel_title': novelTitle,
        'comment_length': commentLength,
      },
    );
  }

  Future<void> logSearchNovel({
    required String searchQuery,
    required int resultsCount,
  }) async {
    await logEvent(
      name: 'search_novel',
      parameters: {
        'search_query': searchQuery,
        'results_count': resultsCount,
      },
    );
  }

  Future<void> logShareNovel({
    required String novelId,
    required String novelTitle,
    required String method,
  }) async {
    await logEvent(
      name: 'share_novel',
      parameters: {
        'novel_id': novelId,
        'novel_title': novelTitle,
        'share_method': method,
      },
    );
  }

  Future<void> logViewAuthorProfile({
    required String authorId,
    required String authorName,
  }) async {
    await logEvent(
      name: 'view_author_profile',
      parameters: {
        'author_id': authorId,
        'author_name': authorName,
      },
    );
  }

  Future<void> logFollowAuthor({
    required String authorId,
    required String authorName,
  }) async {
    await logEvent(
      name: 'follow_author',
      parameters: {
        'author_id': authorId,
        'author_name': authorName,
      },
    );
  }

  Future<void> logSessionStart() async {
    await logEvent(name: 'app_session_start');
  }

  Future<void> logSessionEnd() async {
    await logEvent(name: 'app_session_end');
  }

  Future<void> logDailyActiveUser() async {
    await logEvent(name: 'user_daily_active');
  }

  Future<void> logUserEngagement({
    required int engagementTimeSeconds,
  }) async {
    // 'user_engagement' is a reserved event name in Firebase and cannot be logged manually.
    // We use 'app_engagement' instead to track custom engagement metrics.
    await logEvent(
      name: 'app_engagement',
      parameters: {
        'engagement_time_msec': engagementTimeSeconds * 1000,
      },
    );
  }

  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
      _logger.i('Screen view logged: $screenName');
    } catch (e) {
      _logger.e('Error logging screen view: $e');
    }
  }

  Future<void> setDeviceProperties({
    required String appVersion,
    required String osVersion,
    required String deviceModel,
    required String deviceBrand,
    String? locale,
  }) async {
    await setUserProperty('app_version', appVersion);
    await setUserProperty('os_version', osVersion);
    await setUserProperty('device_model', deviceModel);
    await setUserProperty('device_brand', deviceBrand);
    if (locale != null) {
      await setUserProperty('user_locale', locale);
    }
  }

  void startSession() {
    _sessionStart = DateTime.now();
    _logger.i('Session started');
  }

  Future<void> endSession() async {
    if (_sessionStart != null) {
      final duration = DateTime.now().difference(_sessionStart!).inSeconds;
      await logUserEngagement(engagementTimeSeconds: duration);
      _logger.i('Session ended with duration: $duration seconds');
    }
  }

  Future<void> logAppOpen() async {
    try {
      await _analytics.logAppOpen();
      _logger.i('App open logged (official)');
    } catch (e) {
      _logger.e('Error logging app open: $e');
    }
  }

  Future<void> setConsent({required bool granted}) async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(granted);
      _logger.i('Analytics collection enabled: $granted');
    } catch (e, s) {
      _logger.e('Error setting analytics consent: $e\n$s');
    }
  }

  Future<void> logAppInstall({
    required String installSource,
  }) async {
    await logEvent(
      name: 'app_install_custom',
      parameters: {
        'install_source': installSource,
      },
    );
  }
}
