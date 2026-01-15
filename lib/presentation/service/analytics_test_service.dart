import 'dart:async';
import 'dart:math';
import 'package:logger/logger.dart';
import 'analytics_service.dart';

class AnalyticsTestService {
  static final AnalyticsTestService _instance =
      AnalyticsTestService._internal();
  final AnalyticsService _analyticsService = AnalyticsService();
  final Logger _logger = Logger();

  final List<String> _novelIds = [];
  final List<String> _authorIds = [];
  final List<String> _userIds = [];
  final List<String> _screenNames = [
    'home_screen',
    'discover_screen',
    'novel_detail_screen',
    'reading_screen',
    'profile_screen',
    'settings_screen',
    'library_screen',
    'search_screen',
  ];

  final List<Map<String, String>> _deviceModels = [
    {'brand': 'Apple', 'model': 'iPhone 15 Pro Max'},
    {'brand': 'Apple', 'model': 'iPhone 14'},
    {'brand': 'Samsung', 'model': 'Galaxy S24 Ultra'},
    {'brand': 'Samsung', 'model': 'Galaxy A54'},
    {'brand': 'Xiaomi', 'model': 'Redmi Note 13 Pro'},
    {'brand': 'Xiaomi', 'model': 'Xiaomi 14'},
    {'brand': 'Oppo', 'model': 'Reno 11 Pro'},
    {'brand': 'Vivo', 'model': 'V30 Pro'},
    {'brand': 'Google', 'model': 'Pixel 8 Pro'},
    {'brand': 'Realme', 'model': 'GT5'},
    {'brand': 'Infinix', 'model': 'Note 40'},
  ];

  final Random _random = Random();
  bool _isRunning = false;
  late Timer _eventTimer;

  factory AnalyticsTestService() {
    return _instance;
  }

  AnalyticsTestService._internal();

  void initialize() {
    _generateTestData();
  }

  void _generateTestData() {
    for (int i = 1; i <= 50; i++) {
      _novelIds.add('novel_$i');
      _authorIds.add('author_$i');
      _userIds.add('user_test_$i');
    }
    _logger.i('Test data initialized with ${_novelIds.length} novels');
  }

  Future<void> startSimulation({
    Duration eventInterval = const Duration(seconds: 5),
    int maxEvents = 100,
  }) async {
    if (_isRunning) {
      _logger.w('Simulation already running');
      return;
    }

    _isRunning = true;
    int eventCount = 0;

    _logger.i('Starting analytics simulation...');

    _eventTimer = Timer.periodic(eventInterval, (timer) async {
      if (eventCount >= maxEvents) {
        await stopSimulation();
        return;
      }

      final eventType = _random.nextInt(11);

      try {
        final screenName = _getRandomItem(_screenNames);
        await _analyticsService.logScreenView(
          screenName: screenName,
          screenClass: screenName,
        );

        // Explicit event to trigger active user status in Realtime
        await _analyticsService.logEvent(name: 'test_realtime_active');

        switch (eventType) {
          case 0:
            await _simulateLogin();
            break;
          case 1:
            await _simulateViewNovel();
            break;
          case 2:
            await _simulateStartReading();
            break;
          case 3:
            await _simulateFinishReading();
            break;
          case 4:
            await _simulateLikeNovel();
            break;
          case 5:
            await _simulateComment();
            break;
          case 6:
            await _simulateSearch();
            break;
          case 7:
            await _simulateCreateNovel();
            break;
          case 8:
            await _simulateFollowAuthor();
            break;
          case 9:
            await _simulateShareNovel();
            break;
          case 10:
            await _analyticsService.logAppOpen();
            break;
        }

        eventCount++;
        _logger.i('Event $eventCount/$maxEvents sent');
      } catch (e) {
        _logger.e('Error during simulation: $e');
      }
    });
  }

  Future<void> stopSimulation() async {
    if (!_isRunning) return;

    _isRunning = false;
    _eventTimer.cancel();
    _logger.i('Analytics simulation stopped');
  }

  Future<void> _simulateLogin() async {
    final userId = _getRandomItem(_userIds);
    await _analyticsService.setUserId(userId);
    await _analyticsService.logLogin(method: 'email');
    await _analyticsService.setUserProperty('user_type', 'reader');
    await _analyticsService.logUserEngagement(
      engagementTimeSeconds: 600 + _random.nextInt(600), // ~10-20 minutes
    );
  }

  Future<void> _simulateViewNovel() async {
    final novelId = _getRandomItem(_novelIds);
    final authorId = _getRandomItem(_authorIds);
    final genres = ['Fantasy', 'Romance', 'Mystery', 'Sci-Fi', 'Drama'];
    final genre = _getRandomItem(genres);

    await _analyticsService.logViewNovel(
      novelId: novelId,
      novelTitle: 'Novel Title $novelId',
      authorId: authorId,
      genre: genre,
    );
  }

  Future<void> _simulateStartReading() async {
    final novelId = _getRandomItem(_novelIds);
    final chapterNum = _random.nextInt(50) + 1;

    await _analyticsService.logStartReading(
      novelId: novelId,
      novelTitle: 'Novel Title $novelId',
      chapterId: 'chapter_$chapterNum',
      chapterNumber: chapterNum,
    );
  }

  Future<void> _simulateFinishReading() async {
    final novelId = _getRandomItem(_novelIds);
    final chapterNum = _random.nextInt(50) + 1;
    final readingTime = _random.nextInt(3600) + 300;

    await _analyticsService.logFinishReading(
      novelId: novelId,
      novelTitle: 'Novel Title $novelId',
      chapterId: 'chapter_$chapterNum',
      chapterNumber: chapterNum,
      readingDurationSeconds: readingTime,
    );
  }

  Future<void> _simulateLikeNovel() async {
    final novelId = _getRandomItem(_novelIds);

    await _analyticsService.logLikeNovel(
      novelId: novelId,
      novelTitle: 'Novel Title $novelId',
    );
  }

  Future<void> _simulateComment() async {
    final novelId = _getRandomItem(_novelIds);
    final commentLengths = ['short', 'medium', 'long'];
    final commentLength = _getRandomItem(commentLengths);

    await _analyticsService.logComment(
      novelId: novelId,
      novelTitle: 'Novel Title $novelId',
      commentLength: commentLength,
    );
  }

  Future<void> _simulateSearch() async {
    final queries = ['fantasy', 'romance', 'mystery', 'adventure', 'sci-fi'];
    final query = _getRandomItem(queries);
    final resultsCount = _random.nextInt(100) + 1;

    await _analyticsService.logSearchNovel(
      searchQuery: query,
      resultsCount: resultsCount,
    );
  }

  Future<void> _simulateCreateNovel() async {
    final novelId = 'novel_created_${_random.nextInt(1000)}';
    final genres = ['Fantasy', 'Romance', 'Mystery', 'Sci-Fi', 'Drama'];
    final genre = _getRandomItem(genres);

    await _analyticsService.logCreateNovel(
      novelId: novelId,
      novelTitle: 'New Novel ${_random.nextInt(1000)}',
      genre: genre,
    );
  }

  Future<void> _simulateFollowAuthor() async {
    final authorId = _getRandomItem(_authorIds);

    await _analyticsService.logFollowAuthor(
      authorId: authorId,
      authorName: 'Author Name $authorId',
    );
  }

  Future<void> _simulateShareNovel() async {
    final novelId = _getRandomItem(_novelIds);
    final shareMethods = ['facebook', 'twitter', 'whatsapp', 'email', 'link'];
    final method = _getRandomItem(shareMethods);

    await _analyticsService.logShareNovel(
      novelId: novelId,
      novelTitle: 'Novel Title $novelId',
      method: method,
    );
  }

  Future<void> simulateBulkLogin(int count) async {
    _logger.i('Simulating $count logins...');
    for (int i = 0; i < count; i++) {
      final userId = 'bulk_user_${DateTime.now().millisecondsSinceEpoch}_$i';
      await _analyticsService.setUserId(userId);
      
      // Randomize device
      final device = _getRandomItem(_deviceModels);
      await _analyticsService.setDeviceProperties(
        appVersion: '1.0.${_random.nextInt(10)}',
        osVersion: 'Android ${_random.nextInt(5) + 10}',
        deviceModel: device['model']!,
        deviceBrand: device['brand']!,
      );

      await _analyticsService.setUserProperty('user_type', 'new_user');
      await _analyticsService.setUserProperty('user_cohort', 'bulk_test');

      _analyticsService.startSession();
      await _analyticsService.logLogin(method: 'email');
      await _analyticsService.logEvent(name: 'test_realtime_active');

      final screenName = _getRandomItem(_screenNames);
      await _analyticsService.logScreenView(
        screenName: screenName,
        screenClass: screenName,
      );

      await _analyticsService.logUserEngagement(
        engagementTimeSeconds: 1200 + _random.nextInt(600), // ~20-30 minutes
      );
      await _analyticsService.endSession();

      await Future.delayed(const Duration(milliseconds: 200));
    }
    _logger.i('Bulk login simulation completed');
  }

  Future<void> simulateDailyActiveUsers(int count) async {
    _logger.i('Simulating $count daily active users...');
    for (int i = 0; i < count; i++) {
      final userId = 'dau_user_${DateTime.now().millisecondsSinceEpoch}_$i';
      await _analyticsService.setUserId(userId);

      // Randomize device
      final device = _getRandomItem(_deviceModels);
      await _analyticsService.setDeviceProperties(
        appVersion: '1.2.${_random.nextInt(5)}',
        osVersion: 'Android ${_random.nextInt(4) + 11}',
        deviceModel: device['model']!,
        deviceBrand: device['brand']!,
      );

      await _analyticsService.setUserProperty('user_type', 'active_user');
      await _analyticsService.setUserProperty('user_cohort', 'dau_test');

      _analyticsService.startSession();
      await _analyticsService.logAppOpen();
      await _analyticsService.logDailyActiveUser();
      await _analyticsService.logEvent(name: 'test_realtime_active');

      final screenName = _getRandomItem(_screenNames);
      await _analyticsService.logScreenView(
        screenName: screenName,
        screenClass: screenName,
      );

      await _analyticsService.logUserEngagement(
        engagementTimeSeconds: 3600 + _random.nextInt(600), // ~60-70 minutes
      );
      await _analyticsService.endSession();

      await Future.delayed(const Duration(milliseconds: 150));
    }
    _logger.i('Daily active users simulation completed');
  }

  Future<void> simulateUserEngagement(int count, int engagementSeconds) async {
    _logger.i('Simulating $count engagement events...');
    for (int i = 0; i < count; i++) {
      await _analyticsService.logUserEngagement(
        engagementTimeSeconds: engagementSeconds + _random.nextInt(1800),
      );
      await Future.delayed(const Duration(milliseconds: 100));
    }
    _logger.i('User engagement simulation completed');
  }

  Future<void> simulateRetention(int userCount, int sessionCount) async {
    _logger.i(
        'Simulating retention with $userCount users, $sessionCount sessions each...');
    for (int u = 0; u < userCount; u++) {
      final userId = 'retention_user_$u';
      await _analyticsService.setUserId(userId);

      // Randomize device for each retention user
      final device = _getRandomItem(_deviceModels);
      await _analyticsService.setDeviceProperties(
        appVersion: '1.1.0',
        osVersion: 'Android 13',
        deviceModel: device['model']!,
        deviceBrand: device['brand']!,
      );

      await _analyticsService.setUserProperty('user_cohort', 'retention_test');

      for (int s = 0; s < sessionCount; s++) {
        _analyticsService.startSession();
        await _analyticsService.logAppOpen();

        final screenName = _getRandomItem(_screenNames);
        await _analyticsService.logScreenView(
          screenName: screenName,
          screenClass: screenName,
        );

        await _analyticsService.logUserEngagement(
          engagementTimeSeconds: 2400 + _random.nextInt(600), // ~40-50 minutes
        );
        await Future.delayed(const Duration(milliseconds: 100));

        final actions = _random.nextInt(3) + 1;
        for (int a = 0; a < actions; a++) {
          await _simulateRandomAction();
          await Future.delayed(const Duration(milliseconds: 100));
        }

        await _analyticsService.endSession();
        await Future.delayed(const Duration(milliseconds: 150));
      }
    }
    _logger.i('Retention simulation completed');
  }

  Future<void> _simulateRandomAction() async {
    final actions = [
      _simulateViewNovel,
      _simulateStartReading,
      _simulateLikeNovel,
      _simulateComment,
      _simulateSearch,
    ];

    final action = _getRandomItem(actions);
    await action();
  }

  T _getRandomItem<T>(List<T> list) {
    if (list.isEmpty) {
      _logger.w('Attempted to get random item from empty list');
      throw StateError('Cannot get random item from empty list');
    }
    return list[_random.nextInt(list.length)];
  }

  bool get isRunning => _isRunning;
}
