import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';
import 'dart:convert';

/// Repository for managing packages in SQLite
/// Implements offline-first architecture with sync capabilities
class PackageRepository {
  /// Insert a package into local database
  Future<int> insertPackage(Map<String, dynamic> package) async {
    final db = await AppDatabase.instance;

    // Create a copy to avoid modifying the original
    final Map<String, dynamic> packageData = Map<String, dynamic>.from(package);

    // Handle field name mapping from JSON to database
    if (packageData['suitableFor'] != null) {
      packageData['suitable_for'] = packageData['suitableFor'];
      packageData.remove('suitableFor');
    }

    // Handle price conversion from string to double
    if (packageData['price'] is String) {
      final String priceStr = packageData['price'] as String;
      // Extract numeric value from "700 LKR" format
      final RegExp numericRegex = RegExp(r'(\d+(?:\.\d+)?)');
      final Match? match = numericRegex.firstMatch(priceStr);
      if (match != null) {
        packageData['price'] = double.parse(match.group(1)!);
      } else {
        packageData['price'] = 0.0; // Default fallback
      }
    }

    // Handle originalPrice field name and conversion
    if (packageData['originalPrice'] != null) {
      if (packageData['originalPrice'] is String) {
        final String originalPriceStr = packageData['originalPrice'] as String;
        final RegExp numericRegex = RegExp(r'(\d+(?:\.\d+)?)');
        final Match? match = numericRegex.firstMatch(originalPriceStr);
        if (match != null) {
          packageData['original_price'] = double.parse(match.group(1)!);
        } else {
          packageData['original_price'] = null;
        }
      }
      packageData.remove('originalPrice');
    }

    // Convert lists to JSON strings for storage
    packageData['features'] =
        packageData['features'] != null
            ? jsonEncode(packageData['features'])
            : null;
    packageData['includes'] =
        packageData['includes'] != null
            ? jsonEncode(packageData['includes'])
            : null;
    packageData['suitable_for'] =
        packageData['suitable_for'] != null
            ? jsonEncode(packageData['suitable_for'])
            : null;

    packageData['sync_status'] = SyncStatus.pendingInsert;
    packageData['updated_at'] = DateTime.now().toIso8601String();

    final id = await db.insert(
      'packages',
      packageData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Add to sync queue
    await _addToSyncQueue('packages', id, 'INSERT', packageData);

    print('📦 Package inserted: $id');
    return id;
  }

  /// Get all packages from local database
  Future<List<Map<String, dynamic>>> getAllPackages() async {
    final db = await AppDatabase.instance;
    final List<Map<String, dynamic>> packages = await db.query(
      'packages',
      orderBy: 'updated_at DESC',
    );

    // Convert JSON strings back to lists
    return packages.map((package) {
      if (package['features'] != null) {
        package['features'] = jsonDecode(package['features']);
      }
      if (package['includes'] != null) {
        package['includes'] = jsonDecode(package['includes']);
      }
      if (package['suitable_for'] != null) {
        package['suitable_for'] = jsonDecode(package['suitable_for']);
      }
      return package;
    }).toList();
  }

  /// Get package by ID
  Future<Map<String, dynamic>?> getPackageById(int id) async {
    final db = await AppDatabase.instance;
    final List<Map<String, dynamic>> result = await db.query(
      'packages',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      final package = result.first;
      // Convert JSON strings back to lists
      if (package['features'] != null) {
        package['features'] = jsonDecode(package['features']);
      }
      if (package['includes'] != null) {
        package['includes'] = jsonDecode(package['includes']);
      }
      if (package['suitable_for'] != null) {
        package['suitable_for'] = jsonDecode(package['suitable_for']);
      }
      return package;
    }
    return null;
  }

  /// Update package
  Future<void> updatePackage(int id, Map<String, dynamic> package) async {
    final db = await AppDatabase.instance;

    // Convert lists to JSON strings
    package['features'] =
        package['features'] != null ? jsonEncode(package['features']) : null;
    package['includes'] =
        package['includes'] != null ? jsonEncode(package['includes']) : null;
    package['suitable_for'] =
        package['suitable_for'] != null
            ? jsonEncode(package['suitable_for'])
            : null;

    package['sync_status'] = SyncStatus.pendingUpdate;
    package['updated_at'] = DateTime.now().toIso8601String();

    await db.update('packages', package, where: 'id = ?', whereArgs: [id]);

    // Add to sync queue
    await _addToSyncQueue('packages', id, 'UPDATE', package);

    print('📦 Package updated: $id');
  }

  /// Delete package
  Future<void> deletePackage(int id) async {
    final db = await AppDatabase.instance;

    await db.update(
      'packages',
      {
        'sync_status': SyncStatus.pendingDelete,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    // Add to sync queue
    await _addToSyncQueue('packages', id, 'DELETE', {'id': id});

    print('📦 Package marked for deletion: $id');
  }

  /// Get packages that need to be synced with server
  Future<List<Map<String, dynamic>>> getUnsyncedPackages() async {
    final db = await AppDatabase.instance;
    return await db.query(
      'packages',
      where: 'sync_status != ?',
      whereArgs: [SyncStatus.synced],
    );
  }

  /// Mark package as synced with server
  Future<void> markAsSynced(int localId, int? serverId) async {
    final db = await AppDatabase.instance;
    await db.update(
      'packages',
      {
        'sync_status': SyncStatus.synced,
        'server_id': serverId,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [localId],
    );

    print('✅ Package $localId marked as synced (server_id: $serverId)');
  }

  /// Load initial data from JSON (migration helper)
  Future<void> loadInitialData(List<Map<String, dynamic>> jsonPackages) async {
    final db = await AppDatabase.instance;

    // Check if data already exists
    final count =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM packages'),
        ) ??
        0;

    if (count > 0) {
      print('📦 Packages already exist in database, skipping initial load');
      return;
    }

    print('📦 Loading ${jsonPackages.length} packages from JSON...');

    for (var package in jsonPackages) {
      // Set as synced since this is initial data
      package['sync_status'] = SyncStatus.synced;
      package['created_at'] = DateTime.now().toIso8601String();
      package['updated_at'] = DateTime.now().toIso8601String();

      await insertPackage(package);
    }

    print('✅ Initial package data loaded successfully');
  }

  /// Add operation to sync queue
  Future<void> _addToSyncQueue(
    String tableName,
    int recordId,
    String action,
    Map<String, dynamic> data,
  ) async {
    final db = await AppDatabase.instance;
    await db.insert('sync_queue', {
      'table_name': tableName,
      'record_id': recordId,
      'action': action,
      'data': jsonEncode(data),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Clear all packages (for testing)
  Future<void> clearAllPackages() async {
    final db = await AppDatabase.instance;
    await db.delete('packages');
    print('🗑️ All packages cleared');
  }
}
