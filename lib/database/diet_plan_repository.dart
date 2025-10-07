import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';
import 'dart:convert';

/// Repository for managing diet plans in SQLite
/// Implements offline-first architecture with sync capabilities
class DietPlanRepository {
  /// Insert a diet plan into local database
  Future<int> insertDietPlan(Map<String, dynamic> dietPlan) async {
    final db = await AppDatabase.instance;

    // Convert meals list to JSON string for storage
    dietPlan['meals'] =
        dietPlan['meals'] != null ? jsonEncode(dietPlan['meals']) : null;

    dietPlan['sync_status'] = SyncStatus.pendingInsert;
    dietPlan['updated_at'] = DateTime.now().toIso8601String();

    final id = await db.insert(
      'diet_plans',
      dietPlan,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Add to sync queue
    await _addToSyncQueue('diet_plans', id, 'INSERT', dietPlan);

    print('🥗 Diet plan inserted: $id');
    return id;
  }

  /// Get all diet plans from local database
  Future<List<Map<String, dynamic>>> getAllDietPlans() async {
    final db = await AppDatabase.instance;
    final List<Map<String, dynamic>> dietPlans = await db.query(
      'diet_plans',
      orderBy: 'updated_at DESC',
    );

    // Convert JSON strings back to lists
    return dietPlans.map((dietPlan) {
      if (dietPlan['meals'] != null) {
        dietPlan['meals'] = jsonDecode(dietPlan['meals']);
      }
      return dietPlan;
    }).toList();
  }

  /// Get diet plan by ID
  Future<Map<String, dynamic>?> getDietPlanById(int id) async {
    final db = await AppDatabase.instance;
    final List<Map<String, dynamic>> result = await db.query(
      'diet_plans',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      final dietPlan = result.first;
      // Convert JSON string back to list
      if (dietPlan['meals'] != null) {
        dietPlan['meals'] = jsonDecode(dietPlan['meals']);
      }
      return dietPlan;
    }
    return null;
  }

  /// Update diet plan
  Future<void> updateDietPlan(int id, Map<String, dynamic> dietPlan) async {
    final db = await AppDatabase.instance;

    // Convert meals list to JSON string
    dietPlan['meals'] =
        dietPlan['meals'] != null ? jsonEncode(dietPlan['meals']) : null;

    dietPlan['sync_status'] = SyncStatus.pendingUpdate;
    dietPlan['updated_at'] = DateTime.now().toIso8601String();

    await db.update('diet_plans', dietPlan, where: 'id = ?', whereArgs: [id]);

    // Add to sync queue
    await _addToSyncQueue('diet_plans', id, 'UPDATE', dietPlan);

    print('🥗 Diet plan updated: $id');
  }

  /// Delete diet plan
  Future<void> deleteDietPlan(int id) async {
    final db = await AppDatabase.instance;

    await db.update(
      'diet_plans',
      {
        'sync_status': SyncStatus.pendingDelete,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    // Add to sync queue
    await _addToSyncQueue('diet_plans', id, 'DELETE', {'id': id});

    print('🥗 Diet plan marked for deletion: $id');
  }

  /// Get diet plans that need to be synced with server
  Future<List<Map<String, dynamic>>> getUnsyncedDietPlans() async {
    final db = await AppDatabase.instance;
    return await db.query(
      'diet_plans',
      where: 'sync_status != ?',
      whereArgs: [SyncStatus.synced],
    );
  }

  /// Mark diet plan as synced with server
  Future<void> markAsSynced(int localId, int? serverId) async {
    final db = await AppDatabase.instance;
    await db.update(
      'diet_plans',
      {
        'sync_status': SyncStatus.synced,
        'server_id': serverId,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [localId],
    );

    print('✅ Diet plan $localId marked as synced (server_id: $serverId)');
  }

  /// Load initial data from JSON (migration helper)
  Future<void> loadInitialData(List<Map<String, dynamic>> jsonDietPlans) async {
    final db = await AppDatabase.instance;

    // Check if data already exists
    final count =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM diet_plans'),
        ) ??
        0;

    if (count > 0) {
      print('🥗 Diet plans already exist in database, skipping initial load');
      return;
    }

    print('🥗 Loading ${jsonDietPlans.length} diet plans from JSON...');

    for (var dietPlan in jsonDietPlans) {
      // Set as synced since this is initial data
      dietPlan['sync_status'] = SyncStatus.synced;
      dietPlan['created_at'] = DateTime.now().toIso8601String();
      dietPlan['updated_at'] = DateTime.now().toIso8601String();

      await insertDietPlan(dietPlan);
    }

    print('✅ Initial diet plan data loaded successfully');
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

  /// Clear all diet plans (for testing)
  Future<void> clearAllDietPlans() async {
    final db = await AppDatabase.instance;
    await db.delete('diet_plans');
    print('🗑️ All diet plans cleared');
  }
}
