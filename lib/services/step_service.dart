import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:step_counter_app/services/storage_service.dart';
import 'package:step_counter_app/services/notification_service.dart';

class StepService extends ChangeNotifier {
  final StorageService _storageService;
  final NotificationService _notificationService = NotificationService();

  StepService(this._storageService);

  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;

  int _steps = 0;
  int _lastPedometerSteps = 0;
  String _status = '?';

  // New stats
  double _distance = 0.0; // km
  double _calories = 0.0; // kcal
  int _activeTime = 0; // minutes

  int get steps => _steps;
  String get status => _status;
  double get distance => _distance;
  double get calories => _calories;
  int get activeTime => _activeTime;

  final StreamController<int> _stepController =
      StreamController<int>.broadcast();
  Stream<int> get stepStream => _stepController.stream;

  Future<void> init() async {
    await _notificationService.init();
    await _checkPermissions();
    _loadSavedSteps();
    _initPedometer();

    // Show initial notification
    _updateNotification();
  }

  void _loadSavedSteps() {
    final now = DateTime.now();
    _steps = _storageService.getStepsForDate(now);
    _lastPedometerSteps = _storageService.getLastPedometerSteps();

    // If we have no saved steps, we're starting fresh - reset the offset
    if (_steps == 0 && _lastPedometerSteps == 0) {
      // The offset will be set when we receive the first pedometer reading
      debugPrint('Starting fresh - will reset offset on first reading');
    }

    _calculateStats();
    notifyListeners();
  }

  Future<void> _checkPermissions() async {
    if (await Permission.activityRecognition.request().isGranted) {
      // Permission granted
    } else {
      // Handle permission denied
      debugPrint('Activity recognition permission denied');
    }
  }

  void _initPedometer() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _stepCountStream = Pedometer.stepCountStream;

    _stepCountStream.listen(_onStepCount).onError(_onStepCountError);
    _pedestrianStatusStream
        .listen(_onPedestrianStatus)
        .onError(_onPedestrianStatusError);
  }

  void _onStepCount(StepCount event) {
    final int pedometerSteps = event.steps;

    // If this is the first reading after clearing data, set the offset
    if (_steps == 0 && _lastPedometerSteps == 0) {
      // Set the current pedometer reading as our baseline
      _lastPedometerSteps = pedometerSteps;
      _storageService.saveLastPedometerSteps(_lastPedometerSteps);
      debugPrint('Set initial offset: $pedometerSteps');
      return; // Don't count these as new steps
    }

    // Calculate delta
    int delta = pedometerSteps - _lastPedometerSteps;

    // Handle reboot (pedometer resets to 0)
    if (delta < 0) {
      delta = pedometerSteps;
    }

    // Update daily steps
    _steps += delta;
    _lastPedometerSteps = pedometerSteps;

    // Save state
    _storageService.saveLastPedometerSteps(_lastPedometerSteps);
    _checkDailyReset(); // Save _steps to daily storage

    // Update lifetime steps
    int lifetimeSteps = _storageService.getLifetimeSteps();
    lifetimeSteps += delta;
    _storageService.saveLifetimeSteps(lifetimeSteps);

    _calculateStats();

    _stepController.add(_steps);
    notifyListeners();
    _updateNotification();
    debugPrint('Steps: $_steps');
  }

  void _calculateStats() {
    final profile = _storageService.getUserProfile();
    final double height = profile['height']; // cm

    // Stride length (approx 0.415 * height)
    final double strideLength = height * 0.415 / 100; // meters
    _distance = (_steps * strideLength) / 1000; // km

    // Calories (approx 0.04 kcal per step)
    _calories = _steps * 0.04;

    // Active time (approx 100 steps per minute)
    _activeTime = (_steps / 100).ceil();
  }

  void _checkDailyReset() {
    final now = DateTime.now();
    _storageService.saveDailySteps(now, _steps);
  }

  void _updateNotification() {
    _notificationService.showPersistentStatsNotification(
      steps: _steps,
      calories: _calories.toStringAsFixed(0),
      distance: _distance.toStringAsFixed(2),
    );
  }

  void _onPedestrianStatus(PedestrianStatus event) {
    _status = event.status;
    notifyListeners();
    debugPrint('Status: $_status');
  }

  void _onStepCountError(error) {
    debugPrint('Step Count Error: $error');
    _steps = 0;
    notifyListeners();
  }

  void _onPedestrianStatusError(error) {
    debugPrint('Pedestrian Status Error: $error');
    _status = 'Error';
    notifyListeners();
  }

  @override
  void dispose() {
    _notificationService.cancelPersistentNotification();
    _stepController.close();
    super.dispose();
  }
}
