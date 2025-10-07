import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class ApiDemoPage extends StatefulWidget {
  const ApiDemoPage({super.key});

  @override
  State<ApiDemoPage> createState() => _ApiDemoPageState();
}

class _ApiDemoPageState extends State<ApiDemoPage> {
  final _testResults = <String, String>{};
  bool _isRunning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Laravel API Demo'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 22),
        backgroundColor: const Color.fromARGB(255, 9, 60, 77),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // API Configuration Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🔧 API Configuration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Base URL: ${ApiConfig.baseUrl}'),
                    Text('Environment: ${ApiConfig.environmentName}'),
                    Text('Timeout: ${ApiConfig.connectTimeout}ms'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            ApiConfig.isLocalhost
                                ? Colors.orange.withOpacity(0.1)
                                : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        ApiConfig.isLocalhost
                            ? 'Development Mode'
                            : 'Production Mode',
                        style: TextStyle(
                          color:
                              ApiConfig.isLocalhost
                                  ? Colors.orange
                                  : Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Test Actions
            const Text(
              '🧪 API Tests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _isRunning ? null : _testConnection,
                  icon: const Icon(Icons.network_check),
                  label: const Text('Test Connection'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 9, 60, 77),
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isRunning ? null : _testPackages,
                  icon: const Icon(Icons.local_dining),
                  label: const Text('Test Packages'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isRunning ? null : _testDietPlans,
                  icon: const Icon(Icons.restaurant_menu),
                  label: const Text('Test Diet Plans'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isRunning ? null : _runAllTests,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Run All Tests'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Test Results
            const Text(
              '📊 Test Results',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Expanded(
              child:
                  _isRunning
                      ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: Color.fromARGB(255, 9, 60, 77),
                            ),
                            SizedBox(height: 16),
                            Text('Running API tests...'),
                          ],
                        ),
                      )
                      : _testResults.isEmpty
                      ? const Center(
                        child: Text(
                          'No tests run yet.\nTap a test button to get started!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _testResults.length,
                        itemBuilder: (context, index) {
                          final entry = _testResults.entries.elementAt(index);
                          final isSuccess =
                              entry.value.contains('✅') ||
                              entry.value.contains('SUCCESS');

                          return Card(
                            color:
                                isSuccess
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                            child: ListTile(
                              leading: Icon(
                                isSuccess ? Icons.check_circle : Icons.error,
                                color: isSuccess ? Colors.green : Colors.red,
                              ),
                              title: Text(entry.key),
                              subtitle: Text(entry.value),
                              isThreeLine: entry.value.length > 50,
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          _testResults.isNotEmpty
              ? FloatingActionButton(
                onPressed: _clearResults,
                backgroundColor: const Color.fromARGB(255, 9, 60, 77),
                child: const Icon(Icons.clear, color: Colors.white),
              )
              : null,
    );
  }

  Future<void> _testConnection() async {
    if (mounted) setState(() => _isRunning = true);

    try {
      final isConnected = await ApiService.testConnection();
      _addResult(
        'Connection Test',
        isConnected
            ? '✅ SUCCESS: Laravel API is reachable at ${ApiConfig.baseUrl}'
            : '❌ FAILED: Could not connect to Laravel API. Check if server is running.',
      );
    } catch (e) {
      _addResult('Connection Test', '❌ ERROR: $e');
    }

    if (mounted) setState(() => _isRunning = false);
  }

  Future<void> _testPackages() async {
    if (mounted) setState(() => _isRunning = true);

    try {
      final packages = await ApiService.fetchPackages();
      _addResult(
        'Packages API',
        '✅ SUCCESS: Loaded ${packages.length} packages from ${ApiConfig.fullPackagesUrl}',
      );
    } catch (e) {
      _addResult('Packages API', '❌ FAILED: $e');
    }

    if (mounted) setState(() => _isRunning = false);
  }

  Future<void> _testDietPlans() async {
    if (mounted) setState(() => _isRunning = true);

    try {
      final dietPlans = await ApiService.fetchDietPlans();
      _addResult(
        'Diet Plans API',
        '✅ SUCCESS: Loaded ${dietPlans.length} diet plans from ${ApiConfig.fullDietPlansUrl}',
      );
    } catch (e) {
      _addResult('Diet Plans API', '❌ FAILED: $e');
    }

    if (mounted) setState(() => _isRunning = false);
  }

  Future<void> _runAllTests() async {
    if (mounted) {
      setState(() {
        _isRunning = true;
        _testResults.clear();
      });
    }

    // Test connection first
    await _testConnection();
    await Future.delayed(const Duration(milliseconds: 500));

    // Test packages
    await _testPackages();
    await Future.delayed(const Duration(milliseconds: 500));

    // Test diet plans
    await _testDietPlans();

    // Check auth token
    try {
      final hasToken = await ApiService.hasValidToken();
      _addResult(
        'Authentication',
        hasToken
            ? '✅ SUCCESS: Valid auth token found'
            : '⚠️ INFO: No auth token (user not logged in)',
      );
    } catch (e) {
      _addResult('Authentication', '❌ ERROR: $e');
    }

    if (mounted) setState(() => _isRunning = false);

    // Show summary
    final successCount =
        _testResults.values.where((result) => result.contains('✅')).length;
    final totalCount = _testResults.length;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tests completed: $successCount/$totalCount successful'),
        backgroundColor:
            successCount == totalCount ? Colors.green : Colors.orange,
      ),
    );
  }

  void _addResult(String test, String result) {
    if (mounted) {
      setState(() {
        _testResults[test] = result;
      });
    }
  }

  void _clearResults() {
    if (mounted) {
      setState(() {
        _testResults.clear();
      });
    }
  }
}
