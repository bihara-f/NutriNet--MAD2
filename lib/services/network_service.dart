import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  static NetworkService? _instance;

  factory NetworkService() {
    _instance ??= NetworkService._internal();
    return _instance!;
  }

  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();

  // Check if device has internet connectivity
  Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();

      // If no connectivity, return false immediately
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // Even if connected to WiFi/Mobile, check actual internet access
      return await _hasActualInternetAccess();
    } catch (e) {
      print('Error checking connectivity: $e');
      return false;
    }
  }

  // Check actual internet access by pinging a reliable server
  Future<bool> _hasActualInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (e) {
      print('Error checking internet access: $e');
      return false;
    }
  }

  // Get connectivity type
  Future<ConnectivityResult> getConnectivityType() async {
    try {
      return await _connectivity.checkConnectivity();
    } catch (e) {
      print('Error getting connectivity type: $e');
      return ConnectivityResult.none;
    }
  }

  // Get connectivity status as string
  Future<String> getConnectivityStatus() async {
    final connectivityType = await getConnectivityType();
    final hasInternet = await hasInternetConnection();

    switch (connectivityType) {
      case ConnectivityResult.wifi:
        return hasInternet ? 'WiFi Connected' : 'WiFi Connected (No Internet)';
      case ConnectivityResult.mobile:
        return hasInternet
            ? 'Mobile Data Connected'
            : 'Mobile Data Connected (No Internet)';
      case ConnectivityResult.ethernet:
        return hasInternet
            ? 'Ethernet Connected'
            : 'Ethernet Connected (No Internet)';
      case ConnectivityResult.none:
        return 'No Connection';
      default:
        return 'Unknown Connection';
    }
  }

  // Listen to connectivity changes
  Stream<ConnectivityResult> get connectivityStream =>
      _connectivity.onConnectivityChanged;

  // Check if should attempt sync (has internet)
  Future<bool> shouldAttemptSync() async {
    return await hasInternetConnection();
  }

  // Check server reachability
  Future<bool> canReachServer(String serverUrl) async {
    try {
      if (!await hasInternetConnection()) {
        return false;
      }

      // Extract hostname from URL
      final uri = Uri.parse(serverUrl);
      final hostname = uri.host;

      final result = await InternetAddress.lookup(hostname);
      return result.isNotEmpty;
    } catch (e) {
      print('Error checking server reachability: $e');
      return false;
    }
  }
}
