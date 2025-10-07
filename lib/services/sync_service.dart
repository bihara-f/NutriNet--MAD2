import 'dart:convert';
import '../database/app_database.dart';
import '../services/api_service.dart';

enum SyncStatus { pending, syncing, completed, failed }

class SyncService {
  static SyncService? _instance;

  factory SyncService() {
    _instance ??= SyncService._internal();
    return _instance!;
  }

  SyncService._internal();

  // Repository instances (available for future use)
  // final PackageRepository _packageRepo = PackageRepository();
  // final DietPlanRepository _dietPlanRepo = DietPlanRepository();
  // final CartRepository _cartRepo = CartRepository();

  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  // Getters
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;

  // Full sync - uploads local changes and downloads server updates
  Future<Map<String, dynamic>> performFullSync() async {
    if (_isSyncing) {
      return {'success': false, 'message': 'Sync already in progress'};
    }

    _isSyncing = true;
    final results = <String, dynamic>{};

    try {
      print('Starting full sync...');

      // 1. Check server availability
      final serverAvailable = await _checkServerConnection();
      if (!serverAvailable) {
        throw Exception('Server not available');
      }

      // 2. Upload pending changes
      final uploadResult = await _uploadPendingChanges();
      results['upload'] = uploadResult;

      // 3. Download server updates
      final downloadResult = await _downloadServerUpdates();
      results['download'] = downloadResult;

      // 4. Update last sync time
      _lastSyncTime = DateTime.now();
      await _updateLastSyncTime();

      // 5. Clean up sync queue
      await _cleanupSyncQueue();

      print('Full sync completed successfully');
      results['success'] = true;
      results['message'] = 'Sync completed successfully';
      results['timestamp'] = _lastSyncTime!.toIso8601String();
    } catch (e) {
      print('Sync failed: $e');
      results['success'] = false;
      results['message'] = 'Sync failed: $e';
    } finally {
      _isSyncing = false;
    }

    return results;
  }

  // Upload only local changes to server
  Future<Map<String, dynamic>> uploadChanges() async {
    if (_isSyncing) {
      return {'success': false, 'message': 'Sync already in progress'};
    }

    _isSyncing = true;

    try {
      final result = await _uploadPendingChanges();
      return {'success': true, 'data': result, 'message': 'Upload completed'};
    } catch (e) {
      return {'success': false, 'message': 'Upload failed: $e'};
    } finally {
      _isSyncing = false;
    }
  }

  // Download only server updates
  Future<Map<String, dynamic>> downloadUpdates() async {
    if (_isSyncing) {
      return {'success': false, 'message': 'Sync already in progress'};
    }

    _isSyncing = true;

    try {
      final result = await _downloadServerUpdates();
      return {'success': true, 'data': result, 'message': 'Download completed'};
    } catch (e) {
      return {'success': false, 'message': 'Download failed: $e'};
    } finally {
      _isSyncing = false;
    }
  }

  // Private methods
  Future<bool> _checkServerConnection() async {
    try {
      // Simple server health check
      final response = await ApiService.login('test@test.com', 'test');
      return response['success'] !=
          null; // Server responded, even if login failed
    } catch (e) {
      print('Server connection check failed: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> _uploadPendingChanges() async {
    final db = await AppDatabase.instance;
    final results = <String, dynamic>{};

    // Get pending sync items
    final syncItems = await db.query(
      'sync_queue',
      where: 'sync_status = ?',
      whereArgs: [SyncStatus.pending.name],
    );

    print('Found ${syncItems.length} items to sync');

    if (syncItems.isEmpty) {
      return {'message': 'No pending changes to upload'};
    }

    int uploaded = 0;
    int failed = 0;

    for (final item in syncItems) {
      try {
        // Mark as syncing
        await db.update(
          'sync_queue',
          {'sync_status': SyncStatus.syncing.name},
          where: 'id = ?',
          whereArgs: [item['id']],
        );

        // Process based on table and operation
        final success = await _processSyncItem(item);

        if (success) {
          // Mark as completed
          await db.update(
            'sync_queue',
            {'sync_status': SyncStatus.completed.name},
            where: 'id = ?',
            whereArgs: [item['id']],
          );
          uploaded++;
        } else {
          // Mark as failed
          await db.update(
            'sync_queue',
            {'sync_status': SyncStatus.failed.name},
            where: 'id = ?',
            whereArgs: [item['id']],
          );
          failed++;
        }
      } catch (e) {
        print('Failed to sync item ${item['id']}: $e');
        failed++;
      }
    }

    results['uploaded'] = uploaded;
    results['failed'] = failed;
    results['total'] = syncItems.length;

    return results;
  }

  Future<bool> _processSyncItem(Map<String, dynamic> item) async {
    final tableName = item['table_name'] as String;
    final operation = item['operation'] as String;
    final recordId = item['record_id'] as String;
    final data = item['data'] != null ? jsonDecode(item['data']) : null;

    try {
      switch (tableName) {
        case 'packages':
          return await _syncPackageItem(operation, recordId, data);

        case 'diet_plans':
          return await _syncDietPlanItem(operation, recordId, data);

        case 'cart_items':
          return await _syncCartItem(operation, recordId, data);

        default:
          print('Unknown table for sync: $tableName');
          return false;
      }
    } catch (e) {
      print('Error processing sync item: $e');
      return false;
    }
  }

  Future<bool> _syncPackageItem(
    String operation,
    String recordId,
    Map<String, dynamic>? data,
  ) async {
    // This would typically make API calls to your Laravel backend
    // For now, we'll simulate the sync
    print('Syncing package $operation: $recordId');

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    // In a real implementation, you would:
    // - POST for 'insert' operations
    // - PUT for 'update' operations
    // - DELETE for 'delete' operations

    return true; // Simulate success
  }

  Future<bool> _syncDietPlanItem(
    String operation,
    String recordId,
    Map<String, dynamic>? data,
  ) async {
    print('Syncing diet plan $operation: $recordId');
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  Future<bool> _syncCartItem(
    String operation,
    String recordId,
    Map<String, dynamic>? data,
  ) async {
    print('Syncing cart item $operation: $recordId');
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  Future<Map<String, dynamic>> _downloadServerUpdates() async {
    final results = <String, dynamic>{};

    try {
      // In a real implementation, you would call your Laravel API
      // to get updates since the last sync time

      print('Downloading server updates...');

      // Simulate downloading packages
      final packageResult = await _downloadPackageUpdates();
      results['packages'] = packageResult;

      // Simulate downloading diet plans
      final dietPlanResult = await _downloadDietPlanUpdates();
      results['diet_plans'] = dietPlanResult;

      // Download user-specific cart items
      final cartResult = await _downloadCartUpdates();
      results['cart'] = cartResult;
    } catch (e) {
      print('Error downloading updates: $e');
      rethrow;
    }

    return results;
  }

  Future<Map<String, dynamic>> _downloadPackageUpdates() async {
    // Simulate API call to get updated packages
    await Future.delayed(const Duration(seconds: 1));

    // In real implementation:
    // final packages = await ApiService.getPackages();
    // Then update local database with any changes

    return {
      'downloaded': 0,
      'updated': 0,
      'message': 'Package updates completed',
    };
  }

  Future<Map<String, dynamic>> _downloadDietPlanUpdates() async {
    await Future.delayed(const Duration(seconds: 1));

    return {
      'downloaded': 0,
      'updated': 0,
      'message': 'Diet plan updates completed',
    };
  }

  Future<Map<String, dynamic>> _downloadCartUpdates() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return {'downloaded': 0, 'updated': 0, 'message': 'Cart updates completed'};
  }

  Future<void> _updateLastSyncTime() async {
    // Store last sync time in a settings table or shared preferences
    // For now, we'll just keep it in memory
    print('Last sync time updated: ${_lastSyncTime!.toIso8601String()}');
  }

  Future<void> _cleanupSyncQueue() async {
    final db = await AppDatabase.instance;

    // Remove completed sync items older than 7 days
    final cutoffDate = DateTime.now().subtract(const Duration(days: 7));

    await db.delete(
      'sync_queue',
      where: 'sync_status = ? AND created_at < ?',
      whereArgs: [SyncStatus.completed.name, cutoffDate.toIso8601String()],
    );

    print('Sync queue cleanup completed');
  }

  // Manual sync trigger methods
  Future<void> addToSyncQueue({
    required String tableName,
    required String operation,
    required String recordId,
    Map<String, dynamic>? data,
  }) async {
    final db = await AppDatabase.instance;

    await db.insert('sync_queue', {
      'table_name': tableName,
      'operation': operation,
      'record_id': recordId,
      'data': data != null ? jsonEncode(data) : null,
      'sync_status': SyncStatus.pending.name,
      'created_at': DateTime.now().toIso8601String(),
    });

    print('Added to sync queue: $tableName $operation $recordId');
  }

  // Get sync statistics
  Future<Map<String, dynamic>> getSyncStats() async {
    final db = await AppDatabase.instance;

    final pending = await db.query(
      'sync_queue',
      where: 'sync_status = ?',
      whereArgs: [SyncStatus.pending.name],
    );

    final failed = await db.query(
      'sync_queue',
      where: 'sync_status = ?',
      whereArgs: [SyncStatus.failed.name],
    );

    return {
      'pending': pending.length,
      'failed': failed.length,
      'last_sync': _lastSyncTime?.toIso8601String(),
      'is_syncing': _isSyncing,
    };
  }

  // Reset failed sync items to retry
  Future<int> retryFailedSync() async {
    final db = await AppDatabase.instance;

    final result = await db.update(
      'sync_queue',
      {'sync_status': SyncStatus.pending.name},
      where: 'sync_status = ?',
      whereArgs: [SyncStatus.failed.name],
    );

    print('Reset $result failed sync items for retry');
    return result;
  }
}
