import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/app_state.dart';
import '../services/device_capabilities_service.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:battery_plus/battery_plus.dart';
import 'camera_page.dart';

class DeviceCapabilitiesPage extends StatefulWidget {
  const DeviceCapabilitiesPage({super.key});

  @override
  State<DeviceCapabilitiesPage> createState() => _DeviceCapabilitiesPageState();
}

class _DeviceCapabilitiesPageState extends State<DeviceCapabilitiesPage> {
  final DeviceCapabilitiesService _deviceService = DeviceCapabilitiesService();

  String batteryLevel = 'Loading...';
  String batteryState = 'Unknown';
  String location = 'Loading...';
  String connectivity = 'Checking...';
  String accelerometerData = 'No data';
  String gyroscopeData = 'No data';

  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  StreamSubscription<BatteryState>? _batteryStateSubscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;

  @override
  void initState() {
    super.initState();
    _initializeCapabilities();
    _startListening();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _batteryStateSubscription?.cancel();
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    super.dispose();
  }

  void _initializeCapabilities() async {
    // Request permissions
    await _deviceService.requestPermissions();

    // Initialize data
    _updateBatteryLevel();
    _updateLocation();
    _updateConnectivity();
  }

  void _startListening() {
    // Battery state changes
    _batteryStateSubscription = _deviceService.batteryStateStream.listen((
      state,
    ) {
      setState(() {
        batteryState = state.toString().split('.').last;
      });
    });

    // Connectivity changes
    _connectivitySubscription = _deviceService.connectivityStream.listen((
      result,
    ) {
      setState(() {
        connectivity = result.toString().split('.').last;
      });

      // Update app state
      final appState = Provider.of<AppState>(context, listen: false);
      appState.setConnectivity(result != ConnectivityResult.none);
    });

    // Accelerometer data
    _accelerometerSubscription = _deviceService.accelerometerStream.listen((
      event,
    ) {
      setState(() {
        accelerometerData =
            'X: ${event.x.toStringAsFixed(2)}, Y: ${event.y.toStringAsFixed(2)}, Z: ${event.z.toStringAsFixed(2)}';
      });
    });

    // Gyroscope data
    _gyroscopeSubscription = _deviceService.gyroscopeStream.listen((event) {
      setState(() {
        gyroscopeData =
            'X: ${event.x.toStringAsFixed(2)}, Y: ${event.y.toStringAsFixed(2)}, Z: ${event.z.toStringAsFixed(2)}';
      });
    });
  }

  void _updateBatteryLevel() async {
    final level = await _deviceService.getBatteryLevel();
    setState(() {
      batteryLevel = level;
    });

    // Update app state
    final appState = Provider.of<AppState>(context, listen: false);
    appState.setBatteryLevel(level);
  }

  void _updateLocation() async {
    final loc = await _deviceService.getCurrentLocation();
    setState(() {
      location = loc;
    });

    // Update app state
    final appState = Provider.of<AppState>(context, listen: false);
    appState.setLocation(loc);
  }

  void _updateConnectivity() async {
    final isConnected = await _deviceService.checkConnectivity();
    setState(() {
      connectivity = isConnected ? 'Connected' : 'Disconnected';
    });

    // Update app state
    final appState = Provider.of<AppState>(context, listen: false);
    appState.setConnectivity(isConnected);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[300] : Colors.grey[600];
    final cardColor = isDark ? Colors.grey[850] : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Device Capabilities',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromRGBO(7, 58, 74, 1),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _updateBatteryLevel();
              _updateLocation();
              _updateConnectivity();
            },
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Real-time Device Information',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 20),

              // Network Connectivity
              _CapabilityCard(
                icon: Icons.wifi,
                title: 'Network Connectivity',
                value: connectivity,
                status: appState.isConnected ? 'Connected' : 'Offline',
                statusColor: appState.isConnected ? Colors.green : Colors.red,
                cardColor: cardColor,
              ),

              const SizedBox(height: 16),

              // Battery Information
              _CapabilityCard(
                icon: Icons.battery_full,
                title: 'Battery Level',
                value: batteryLevel,
                status: batteryState,
                statusColor: _getBatteryColor(batteryLevel),
                cardColor: cardColor,
              ),

              const SizedBox(height: 16),

              // Location Services
              _CapabilityCard(
                icon: Icons.location_on,
                title: 'Location Services',
                value: location,
                status: location.contains('Lat:') ? 'Active' : 'Unavailable',
                statusColor:
                    location.contains('Lat:') ? Colors.green : Colors.orange,
                cardColor: cardColor,
              ),

              const SizedBox(height: 16),

              // Accelerometer
              _CapabilityCard(
                icon: Icons.screen_rotation,
                title: 'Accelerometer',
                value: accelerometerData,
                status: accelerometerData != 'No data' ? 'Active' : 'Inactive',
                statusColor:
                    accelerometerData != 'No data' ? Colors.green : Colors.grey,
                cardColor: cardColor,
              ),

              const SizedBox(height: 16),

              // Gyroscope
              _CapabilityCard(
                icon: Icons.rotate_right,
                title: 'Gyroscope',
                value: gyroscopeData,
                status: gyroscopeData != 'No data' ? 'Active' : 'Inactive',
                statusColor:
                    gyroscopeData != 'No data' ? Colors.green : Colors.grey,
                cardColor: cardColor,
              ),

              const SizedBox(height: 32),

              // Camera Access
              Card(
                color: cardColor,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CameraPage(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4A019).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Color(0xFFF4A019),
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Camera Access',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Test camera functionality and take photos',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: subtitleColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFFF4A019),
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // App State Summary
              Card(
                color: cardColor,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'App State Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _StatRow(
                        'User Status',
                        appState.isLoggedIn ? 'Logged In' : 'Not Logged In',
                      ),
                      _StatRow(
                        'User Email',
                        appState.userEmail.isEmpty ? 'N/A' : appState.userEmail,
                      ),
                      _StatRow(
                        'Diet Plans Loaded',
                        '${appState.dietPlans.length}',
                      ),
                      _StatRow(
                        'Packages Loaded',
                        '${appState.packages.length}',
                      ),
                      _StatRow('Battery Level', appState.batteryLevel),
                      _StatRow(
                        'Location',
                        appState.location.length > 30
                            ? '${appState.location.substring(0, 30)}...'
                            : appState.location,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getBatteryColor(String batteryLevel) {
    if (batteryLevel.contains('%')) {
      final percentage = int.tryParse(batteryLevel.replaceAll('%', '')) ?? 0;
      if (percentage > 50) return Colors.green;
      if (percentage > 20) return Colors.orange;
      return Colors.red;
    }
    return Colors.grey;
  }
}

class _CapabilityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String status;
  final Color statusColor;
  final Color? cardColor;

  const _CapabilityCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.status,
    required this.statusColor,
    this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[300] : Colors.grey[600];

    return Card(
      color: cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF0993A3), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: subtitleColor,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[300] : Colors.grey[600];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: subtitleColor, fontSize: 14)),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
