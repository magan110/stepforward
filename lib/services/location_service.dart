import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

class LocationService extends ChangeNotifier {
  Position? _currentPosition;
  Position? _previousPosition;
  double _totalDistance = 0.0; // in meters
  bool _isTracking = false;

  StreamSubscription<Position>? _positionSubscription;

  Position? get currentPosition => _currentPosition;
  double get totalDistance => _totalDistance;
  double get totalDistanceKm => _totalDistance / 1000;
  bool get isTracking => _isTracking;

  Future<bool> checkPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permissions are denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permissions are permanently denied');
      return false;
    }

    return true;
  }

  Future<void> startTracking() async {
    if (_isTracking) return;

    final hasPermission = await checkPermissions();
    if (!hasPermission) {
      debugPrint('Cannot start tracking without location permission');
      return;
    }

    _isTracking = true;
    _totalDistance = 0.0;
    _previousPosition = null;

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    _positionSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
            _updatePosition(position);
          },
        );

    notifyListeners();
  }

  void _updatePosition(Position position) {
    _currentPosition = position;

    if (_previousPosition != null) {
      // Calculate distance between previous and current position
      final distance = Geolocator.distanceBetween(
        _previousPosition!.latitude,
        _previousPosition!.longitude,
        position.latitude,
        position.longitude,
      );

      // Only add distance if it's reasonable (not a GPS jump)
      if (distance < 100) {
        // Less than 100 meters per update
        _totalDistance += distance;
      }
    }

    _previousPosition = position;
    notifyListeners();

    debugPrint('Location updated: ${position.latitude}, ${position.longitude}');
    debugPrint('Total distance: ${totalDistanceKm.toStringAsFixed(2)} km');
  }

  void stopTracking() {
    _isTracking = false;
    _positionSubscription?.cancel();
    _positionSubscription = null;
    notifyListeners();
  }

  void resetDistance() {
    _totalDistance = 0.0;
    _previousPosition = null;
    notifyListeners();
  }

  Future<Position?> getCurrentLocation() async {
    final hasPermission = await checkPermissions();
    if (!hasPermission) return null;

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}
