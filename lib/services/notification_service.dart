import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    _initialized = true;
  }

  Future<void> showGoalReminderNotification(
    int currentSteps,
    int goalSteps,
  ) async {
    final remaining = goalSteps - currentSteps;
    if (remaining <= 0) return;

    const androidDetails = AndroidNotificationDetails(
      'goal_reminders',
      'Goal Reminders',
      channelDescription: 'Notifications to remind you about your step goals',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1,
      '🎯 Almost There!',
      'Only $remaining steps to your goal! Keep moving!',
      details,
    );
  }

  Future<void> showInactivityAlert() async {
    const androidDetails = AndroidNotificationDetails(
      'inactivity_alerts',
      'Inactivity Alerts',
      channelDescription: 'Alerts when you have been inactive',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      2,
      '⏰ Time to Move!',
      'You\'ve been sitting for a while. Take a short walk!',
      details,
    );
  }

  Future<void> showMotivationalQuote() async {
    final quotes = [
      'Every step counts! Keep going! 💪',
      'You\'re doing amazing! Don\'t stop now! 🌟',
      'Small steps lead to big changes! 🚀',
      'Your body will thank you later! ❤️',
      'Movement is medicine! Keep walking! 🏃',
      'Progress, not perfection! 🎯',
      'One step at a time! You got this! 💯',
      'Stay active, stay healthy! 🌈',
    ];

    final quote = quotes[Random().nextInt(quotes.length)];

    const androidDetails = AndroidNotificationDetails(
      'motivational_quotes',
      'Motivational Quotes',
      channelDescription: 'Daily motivational quotes',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(3, '💡 Daily Motivation', quote, details);
  }

  Future<void> showAchievementNotification(String badgeName) async {
    const androidDetails = AndroidNotificationDetails(
      'achievements',
      'Achievements',
      channelDescription: 'Notifications for unlocked achievements',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      4,
      '🏆 Achievement Unlocked!',
      'You earned the "$badgeName" badge! Congratulations!',
      details,
    );
  }

  Future<void> showGoalCompletedNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'goal_completed',
      'Goal Completed',
      channelDescription: 'Notifications when you complete your daily goal',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      5,
      '🎉 Goal Completed!',
      'Amazing! You\'ve reached your daily step goal!',
      details,
    );
  }

  // Persistent notification showing current stats
  Future<void> showPersistentStatsNotification({
    required int steps,
    required String calories,
    required String distance,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'persistent_stats',
      'Step Counter Stats',
      channelDescription:
          'Ongoing notification showing your step count and stats',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true, // Makes it persistent
      autoCancel: false,
      showWhen: false,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(
        '$steps steps • $calories kcal • $distance km',
        contentTitle: '🚶 Step Counter Active',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: true,
      presentSound: false,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0, // Use ID 0 for persistent notification
      '🚶 Step Counter Active',
      '$steps steps • $calories kcal • $distance km',
      details,
    );
  }

  Future<void> cancelPersistentNotification() async {
    await _notifications.cancel(0);
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
