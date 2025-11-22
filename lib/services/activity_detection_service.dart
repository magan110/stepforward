import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

enum ActivityType { still, walking, running, cycling, unknown }

class ActivityDetectionService extends ChangeNotifier {
  ActivityType _currentActivity = ActivityType.unknown;
  double _currentSpeed = 0.0; // m/s

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;

  final List<double> _accelerometerMagnitudes = [];
  final int _windowSize = 50; // Number of samples to analyze

  ActivityType get currentActivity => _currentActivity;
  double get currentSpeed => _currentSpeed;

  String get activityName {
    switch (_currentActivity) {
      case ActivityType.still:
        return 'Still';
      case ActivityType.walking:
        return 'Walking';
      case ActivityType.running:
        return 'Running';
      case ActivityType.cycling:
        return 'Cycling';
      case ActivityType.unknown:
        return 'Unknown';
    }
  }

  void startDetection() {
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      _processAccelerometerData(event);
    });

    _gyroscopeSubscription = gyroscopeEventStream().listen((event) {
      _processGyroscopeData(event);
    });
  }

  void _processAccelerometerData(AccelerometerEvent event) {
    // Calculate magnitude of acceleration
    final magnitude = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    _accelerometerMagnitudes.add(magnitude);

    // Keep only recent samples
    if (_accelerometerMagnitudes.length > _windowSize) {
      _accelerometerMagnitudes.removeAt(0);
    }

    // Analyze when we have enough samples
    if (_accelerometerMagnitudes.length >= _windowSize) {
      _detectActivity();
    }
  }

  void _processGyroscopeData(GyroscopeEvent event) {
    // Can be used for more advanced detection
    // For now, we'll focus on accelerometer
  }

  void _detectActivity() {
    // Calculate variance and mean
    final mean =
        _accelerometerMagnitudes.reduce((a, b) => a + b) /
        _accelerometerMagnitudes.length;

    final variance =
        _accelerometerMagnitudes
            .map((x) => pow(x - mean, 2))
            .reduce((a, b) => a + b) /
        _accelerometerMagnitudes.length;

    final stdDev = sqrt(variance);

    // Detect activity based on variance and mean
    ActivityType newActivity;
    double speed;

    if (stdDev < 0.5) {
      newActivity = ActivityType.still;
      speed = 0.0;
    } else if (stdDev < 2.0 && mean < 11.0) {
      newActivity = ActivityType.walking;
      speed = 1.4; // Average walking speed ~1.4 m/s
    } else if (stdDev >= 2.0 && mean >= 11.0) {
      newActivity = ActivityType.running;
      speed = 3.0; // Average running speed ~3.0 m/s
    } else if (stdDev > 1.5 && mean < 10.5) {
      newActivity = ActivityType.cycling;
      speed = 5.0; // Average cycling speed ~5.0 m/s
    } else {
      newActivity = ActivityType.unknown;
      speed = 0.0;
    }

    if (newActivity != _currentActivity ||
        (_currentSpeed - speed).abs() > 0.1) {
      _currentActivity = newActivity;
      _currentSpeed = speed;
      notifyListeners();
      debugPrint(
        'Activity detected: ${activityName}, Speed: ${speed.toStringAsFixed(2)} m/s',
      );
    }
  }

  void stopDetection() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _accelerometerMagnitudes.clear();
  }

  @override
  void dispose() {
    stopDetection();
    super.dispose();
  }
}
