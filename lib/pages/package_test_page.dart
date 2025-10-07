import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../services/database_restoration.dart';

class PackageTestPage extends StatefulWidget {
  const PackageTestPage({super.key});

  @override
  State<PackageTestPage> createState() => _PackageTestPageState();
}

class _PackageTestPageState extends State<PackageTestPage> {
  List<Map<String, dynamic>> packages = [];
  Map<String, int> dbStats = {};
  bool isLoading = true;
  String statusMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPackageTest();
  }

  Future<void> _loadPackageTest() async {
    setState(() {
      isLoading = true;
      statusMessage = 'Loading packages...';
    });

    try {
      // Load packages from JSON
      final jsonString = await rootBundle.loadString(
        'assets/data/packages.json',
      );
      final List<dynamic> packagesJson = json.decode(jsonString);

      // Get database stats
      final restoration = DatabaseRestoration();
      final stats = await restoration.getDatabaseStats();

      setState(() {
        packages = packagesJson.cast<Map<String, dynamic>>();
        dbStats = stats;
        statusMessage =
            'Loaded ${packages.length} packages from JSON, ${stats['packages']} from DB';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        statusMessage = 'Error loading packages: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _restoreDatabase() async {
    setState(() {
      isLoading = true;
      statusMessage = 'Restoring database...';
    });

    try {
      final restoration = DatabaseRestoration();
      final success = await restoration.restoreAllData();

      if (success) {
        await _loadPackageTest(); // Refresh data
        setState(() {
          statusMessage = 'Database restored successfully!';
        });
      } else {
        setState(() {
          statusMessage = 'Database restoration failed';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = 'Error during restoration: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Package Test',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromRGBO(7, 58, 74, 1),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPackageTest,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status: $statusMessage',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'JSON Packages: ${packages.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'DB Packages: ${dbStats['packages'] ?? 0}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'DB Diet Plans: ${dbStats['dietPlans'] ?? 0}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'DB Users: ${dbStats['users'] ?? 0}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _restoreDatabase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Restore Database'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _loadPackageTest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Refresh Data'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Package List
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : packages.isEmpty
                      ? const Center(child: Text('No packages found'))
                      : ListView.builder(
                        itemCount: packages.length,
                        itemBuilder: (context, index) {
                          final package = packages[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text('${package['id']}'),
                              ),
                              title: Text(package['title'] ?? 'Unknown'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(package['price'] ?? 'No price'),
                                  Text(package['category'] ?? 'No category'),
                                ],
                              ),
                              trailing: Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
