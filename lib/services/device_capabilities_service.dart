import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class DeviceCapabilitiesService {
  static final DeviceCapabilitiesService _instance =
      DeviceCapabilitiesService._internal();
  factory DeviceCapabilitiesService() => _instance;
  DeviceCapabilitiesService._internal();

  final Battery _battery = Battery();
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  StreamSubscription<BatteryState>? _batterySubscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  // Battery level
  Future<String> getBatteryLevel() async {
    try {
      final batteryLevel = await _battery.batteryLevel;
      return '$batteryLevel%';
    } catch (e) {
      return 'Unknown';
    }
  }

  // Battery state stream
  Stream<BatteryState> get batteryStateStream => _battery.onBatteryStateChanged;

  // Network connectivity
  Future<bool> checkConnectivity() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  // Connectivity stream
  Stream<ConnectivityResult> get connectivityStream =>
      _connectivity.onConnectivityChanged;

  // Location services
  Future<String> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return 'Location services are disabled';
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return 'Location permissions are permanently denied';
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return 'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
    } catch (e) {
      return 'Error getting location: $e';
    }
  }

  // Accelerometer data
  Stream<AccelerometerEvent> get accelerometerStream => accelerometerEvents;

  // Gyroscope data
  Stream<GyroscopeEvent> get gyroscopeStream => gyroscopeEvents;

  // Request permissions
  Future<bool> requestPermissions() async {
    Map<Permission, PermissionStatus> permissions =
        await [
          Permission.location,
          Permission.camera,
          Permission.storage,
        ].request();

    return permissions.values.every(
      (status) => status == PermissionStatus.granted,
    );
  }

  // Dispose streams
  void dispose() {
    _connectivitySubscription?.cancel();
    _batterySubscription?.cancel();
    _accelerometerSubscription?.cancel();
  }
}
