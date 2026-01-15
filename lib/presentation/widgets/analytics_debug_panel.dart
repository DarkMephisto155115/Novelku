import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../service/analytics_service.dart';
import '../service/analytics_test_service.dart';

class AnalyticsDebugPanel extends StatefulWidget {
  const AnalyticsDebugPanel({super.key});

  @override
  State<AnalyticsDebugPanel> createState() => _AnalyticsDebugPanelState();
}

class _AnalyticsDebugPanelState extends State<AnalyticsDebugPanel> {
  final AnalyticsService _analyticsService = AnalyticsService();
  AnalyticsTestService? _testService;

  bool _isSimulationRunning = false;
  int _eventCount = 0;
  String _appInstanceId = 'Loading...';

  late TextEditingController _bulkLoginController;
  late TextEditingController _dauController;
  late TextEditingController _retentionController;
  late TextEditingController _activeEngagementController;

  @override
  void initState() {
    super.initState();
    _bulkLoginController = TextEditingController(text: '20');
    _dauController = TextEditingController(text: '45');
    _retentionController = TextEditingController(text: '15');
    _activeEngagementController = TextEditingController(text: '60');
    _initializeTestService();
    _loadAppInstanceId();
  }

  Future<void> _loadAppInstanceId() async {
    final id = await _analyticsService.getAppInstanceId();
    if (mounted) {
      setState(() {
        _appInstanceId = id ?? 'Unknown';
      });
    }
  }

  @override
  void dispose() {
    _bulkLoginController.dispose();
    _dauController.dispose();
    _retentionController.dispose();
    _activeEngagementController.dispose();
    super.dispose();
  }

  Future<void> _initializeTestService() async {
    try {
      _testService = AnalyticsTestService();
      _testService!.initialize();
    } catch (e) {
      debugPrint('Error creating test service: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Debug Panel'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSection(
              title: 'Simulation Control',
              children: [
                ElevatedButton.icon(
                  onPressed:
                      _isSimulationRunning ? null : _startContinuousSimulation,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Auto Simulation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _isSimulationRunning ? _stopSimulation : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop Simulation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Status: ${_isSimulationRunning ? 'Running' : 'Stopped'}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Events sent: $_eventCount'),
                      const Divider(),
                      SelectableText(
                        'App Instance ID: $_appInstanceId',
                        style: const TextStyle(fontSize: 12, color: Colors.blue),
                        textAlign: TextAlign.center,
                      ),
                      const Text(
                        '(Use this ID in Firebase DebugView)',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Bulk Operations',
              children: [
                _buildInputField(
                  controller: _activeEngagementController,
                  label: 'Active Engagement Count',
                  buttonText: 'Simulate Active',
                  onPressed: (v) => _simulateActiveEngagement(int.tryParse(v) ?? 30),
                ),
                const SizedBox(height: 8),
                _buildInputField(
                  controller: _bulkLoginController,
                  label: 'Bulk Login Count',
                  buttonText: 'Simulate Logins',
                  onPressed: (v) => _bulkLogin(int.tryParse(v) ?? 20),
                ),
                const SizedBox(height: 8),
                _buildInputField(
                  controller: _dauController,
                  label: 'Daily Active Users Count',
                  buttonText: 'Simulate DAU',
                  onPressed: (v) =>
                      _simulateDailyActiveUsers(int.tryParse(v) ?? 45),
                ),
                const SizedBox(height: 8),
                _buildInputField(
                  controller: _retentionController,
                  label: 'Retention Users (count)',
                  buttonText: 'Simulate Retention',
                  onPressed: (v) => _simulateRetention(int.tryParse(v) ?? 15),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Individual Events',
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSmallButton('Login', _simulateLogin),
                    _buildSmallButton('View Novel', _simulateViewNovel),
                    _buildSmallButton('Start Reading', _simulateStartReading),
                    _buildSmallButton('Finish Reading', _simulateFinishReading),
                    _buildSmallButton('Like', _simulateLike),
                    _buildSmallButton('Comment', _simulateComment),
                    _buildSmallButton('Search', _simulateSearch),
                    _buildSmallButton('Create Novel', _simulateCreateNovel),
                    _buildSmallButton('Follow', _simulateFollowAuthor),
                    _buildSmallButton('Share', _simulateShareNovel),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'User Properties',
              children: [
                ElevatedButton(
                  onPressed: _setUserProperties,
                  child: const Text('Set User Properties'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  /// 🔥 FIXED — NO HORIZONTAL SCROLL, NO INFINITE WIDTH
  Widget _buildInputField({
  required TextEditingController controller,
  required String label,
  required String buttonText,
  required Function(String) onPressed,
}) {
  return Row(
    children: [
      SizedBox(
        width: 200,
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      SizedBox(
        width: 140, // 🔒 LEBAR DIKUNCI
        height: 56,
        child: ElevatedButton(
          onPressed: () => onPressed(controller.text),
          child: Text(buttonText),
        ),
      ),
    ],
  );
}


  Widget _buildSmallButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  // ================= SIMULATION METHODS =================

  Future<void> _startContinuousSimulation() async {
    if (_testService == null) {
      Get.snackbar('Error', 'Test service not initialized');
      return;
    }
    setState(() => _isSimulationRunning = true);
    await _testService!.startSimulation(
      eventInterval: const Duration(seconds: 5),
      maxEvents: 50,
    );
  }

  Future<void> _stopSimulation() async {
    if (_testService == null) return;
    setState(() => _isSimulationRunning = false);
    await _testService!.stopSimulation();
  }

  Future<void> _simulateLogin() async {
    await _analyticsService.setUserId(
      'user_${DateTime.now().millisecondsSinceEpoch}',
    );
    await _analyticsService.logLogin(method: 'email');
    _incrementEventCount();
  }

  Future<void> _simulateViewNovel() async {
    await _analyticsService.logViewNovel(
      novelId: 'novel_${DateTime.now().millisecondsSinceEpoch}',
      novelTitle: 'Test Novel',
      authorId: 'author_1',
      genre: 'Fantasy',
    );
    _incrementEventCount();
  }

  Future<void> _simulateStartReading() async {
    await _analyticsService.logStartReading(
      novelId: 'novel_1',
      novelTitle: 'Test Novel',
      chapterId: 'chapter_1',
      chapterNumber: 1,
    );
    _incrementEventCount();
  }

  Future<void> _simulateFinishReading() async {
    await _analyticsService.logFinishReading(
      novelId: 'novel_1',
      novelTitle: 'Test Novel',
      chapterId: 'chapter_1',
      chapterNumber: 1,
      readingDurationSeconds: 3600, // Increased to 60 minutes
    );
    _incrementEventCount();
  }

  Future<void> _simulateLike() async {
    await _analyticsService.logLikeNovel(
      novelId: 'novel_1',
      novelTitle: 'Test Novel',
    );
    _incrementEventCount();
  }

  Future<void> _simulateComment() async {
    await _analyticsService.logComment(
      novelId: 'novel_1',
      novelTitle: 'Test Novel',
      commentLength: 'long',
    );
    _incrementEventCount();
  }

  Future<void> _simulateSearch() async {
    await _analyticsService.logSearchNovel(
      searchQuery: 'fantasy',
      resultsCount: 25,
    );
    _incrementEventCount();
  }

  Future<void> _simulateCreateNovel() async {
    await _analyticsService.logCreateNovel(
      novelId: 'novel_new_${DateTime.now().millisecondsSinceEpoch}',
      novelTitle: 'New Novel',
      genre: 'Romance',
    );
    _incrementEventCount();
  }

  Future<void> _simulateFollowAuthor() async {
    await _analyticsService.logFollowAuthor(
      authorId: 'author_1',
      authorName: 'Test Author',
    );
    _incrementEventCount();
  }

  Future<void> _simulateShareNovel() async {
    await _analyticsService.logShareNovel(
      novelId: 'novel_1',
      novelTitle: 'Test Novel',
      method: 'facebook',
    );
    _incrementEventCount();
  }

  Future<void> _setUserProperties() async {
    await _analyticsService.setUserProperty('user_type', 'reader');
    await _analyticsService.setUserProperty('country', 'Indonesia');
    Get.snackbar('Success', 'User properties set');
  }

  Future<void> _simulateActiveEngagement(int count) async {
    if (_testService == null) return;
    final safeCount = count > 10 ? 10 : count;
    await _testService!.simulateDailyActiveUsers(safeCount);
    setState(() => _eventCount += safeCount);
    Get.snackbar('Success', 'Simulated $safeCount active users with engagement');
  }

  Future<void> _bulkLogin(int count) async {
    if (_testService == null) return;
    final safeCount = count > 10 ? 10 : count;
    await _testService!.simulateBulkLogin(safeCount);
    setState(() => _eventCount += safeCount);
  }

  Future<void> _simulateDailyActiveUsers(int count) async {
    if (_testService == null) return;
    final safeCount = count > 10 ? 10 : count;
    await _testService!.simulateDailyActiveUsers(safeCount);
    setState(() => _eventCount += safeCount);
  }

  Future<void> _simulateRetention(int userCount) async {
    if (_testService == null) return;
    final safeCount = userCount > 10 ? 10 : userCount;
    await _testService!.simulateRetention(safeCount, 5);
    setState(() => _eventCount += (safeCount * 15));
  }

  void _incrementEventCount() {
    setState(() => _eventCount++);
  }
}
