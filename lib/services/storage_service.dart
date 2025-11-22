import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static const String _boxName = 'step_data';
  static const String _settingsBoxName = 'settings';
  static const String _profileBoxName = 'profile';
  static const String _gamificationBoxName = 'gamification';

  late Box _box;
  late Box _settingsBox;
  late Box _profileBox;
  late Box _gamificationBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
    _profileBox = await Hive.openBox(_profileBoxName);
    _gamificationBox = await Hive.openBox(_gamificationBoxName);
  }

  // Clear all data - useful for starting fresh
  Future<void> clearAllData() async {
    await _box.clear();
    await _settingsBox.clear();
    await _profileBox.clear();
    await _gamificationBox.clear();
  }

  // Save daily steps
  Future<void> saveDailySteps(DateTime date, int steps) async {
    final key = _getDateKey(date);
    await _box.put(key, steps);
  }

  // Get steps for a specific date
  int getStepsForDate(DateTime date) {
    final key = _getDateKey(date);
    return _box.get(key, defaultValue: 0);
  }

  // Get steps for the last 7 days
  Map<DateTime, int> getWeeklySteps() {
    final Map<DateTime, int> weeklySteps = {};
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      weeklySteps[date] = getStepsForDate(date);
    }
    return weeklySteps;
  }

  // Save daily goal
  Future<void> saveDailyGoal(int goal) async {
    await _settingsBox.put('daily_goal', goal);
  }

  // Get daily goal
  int getDailyGoal() {
    return _settingsBox.get('daily_goal', defaultValue: 10000);
  }

  // User Profile
  Future<void> saveUserProfile(
    double height,
    double weight,
    String gender,
  ) async {
    await _profileBox.put('height', height);
    await _profileBox.put('weight', weight);
    await _profileBox.put('gender', gender);
  }

  Map<String, dynamic> getUserProfile() {
    return {
      'height': _profileBox.get('height', defaultValue: 170.0),
      'weight': _profileBox.get('weight', defaultValue: 70.0),
      'gender': _profileBox.get('gender', defaultValue: 'Male'),
    };
  }

  // Gamification
  Future<void> saveLifetimeSteps(int steps) async {
    await _gamificationBox.put('lifetime_steps', steps);
  }

  int getLifetimeSteps() {
    return _gamificationBox.get('lifetime_steps', defaultValue: 0);
  }

  Future<void> saveLevel(int level) async {
    await _gamificationBox.put('level', level);
  }

  int getLevel() {
    return _gamificationBox.get('level', defaultValue: 1);
  }

  Future<void> unlockBadge(String badgeId) async {
    final List<String> badges = getUnlockedBadges();
    if (!badges.contains(badgeId)) {
      badges.add(badgeId);
      await _gamificationBox.put('badges', badges);
    }
  }

  List<String> getUnlockedBadges() {
    return List<String>.from(
      _gamificationBox.get('badges', defaultValue: <String>[]),
    );
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  Future<void> saveLastPedometerSteps(int steps) async {
    await _box.put('last_pedometer_steps', steps);
  }

  int getLastPedometerSteps() {
    return _box.get('last_pedometer_steps', defaultValue: 0);
  }

  // Notification settings
  void saveNotificationSetting(String key, bool value) {
    _settingsBox.put('notification_$key', value);
  }

  bool getNotificationSetting(String key) {
    return _settingsBox.get('notification_$key', defaultValue: true);
  }

  // Sound settings
  void saveSoundSetting(bool value) {
    _settingsBox.put('sound_enabled', value);
  }

  bool getSoundSetting() {
    return _settingsBox.get('sound_enabled', defaultValue: true);
  }
}
