import '../database/app_database.dart';
import 'dart:convert';

/// Repository for managing cart items in SQLite
/// Implements offline-first architecture with sync capabilities
class CartRepository {
  /// Add item to cart
  Future<int> addToCart(int userId, Map<String, dynamic> item) async {
    final db = await AppDatabase.instance;

    // Check if item already exists in cart
    final existing = await db.query(
      'cart_items',
      where: 'user_id = ? AND package_id = ?',
      whereArgs: [userId, item['id']],
    );

    if (existing.isNotEmpty) {
      // Update quantity
      final existingItem = existing.first;
      final newQuantity = (existingItem['quantity'] as int) + 1;

      await db.update(
        'cart_items',
        {
          'quantity': newQuantity,
          'sync_status': SyncStatus.pendingUpdate,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [existingItem['id']],
      );

      await _addToSyncQueue('cart_items', existingItem['id'] as int, 'UPDATE', {
        'id': existingItem['id'],
        'quantity': newQuantity,
      });

      print('🛒 Cart item quantity updated: ${existingItem['id']}');
      return existingItem['id'] as int;
    } else {
      // Add new item
      final cartItem = {
        'user_id': userId,
        'package_id': item['id'],
        'package_title': item['title'] ?? item['name'] ?? 'Unknown',
        'price': _extractPriceFromString(item['price']),
        'quantity': 1,
        'image': item['image'],
        'description': item['description'],
        'sync_status': SyncStatus.pendingInsert,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final id = await db.insert('cart_items', cartItem);

      await _addToSyncQueue('cart_items', id, 'INSERT', cartItem);

      print('🛒 Item added to cart: $id');
      return id;
    }
  }

  /// Get all cart items for a user
  Future<List<Map<String, dynamic>>> getCartItems(int userId) async {
    final db = await AppDatabase.instance;
    return await db.query(
      'cart_items',
      where: 'user_id = ? AND sync_status != ?',
      whereArgs: [userId, SyncStatus.pendingDelete],
      orderBy: 'updated_at DESC',
    );
  }

  /// Update cart item quantity
  Future<void> updateQuantity(int cartItemId, int quantity) async {
    final db = await AppDatabase.instance;

    if (quantity <= 0) {
      await removeFromCart(cartItemId);
      return;
    }

    await db.update(
      'cart_items',
      {
        'quantity': quantity,
        'sync_status': SyncStatus.pendingUpdate,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [cartItemId],
    );

    await _addToSyncQueue('cart_items', cartItemId, 'UPDATE', {
      'id': cartItemId,
      'quantity': quantity,
    });

    print('🛒 Cart item quantity updated: $cartItemId -> $quantity');
  }

  /// Remove item from cart
  Future<void> removeFromCart(int cartItemId) async {
    final db = await AppDatabase.instance;

    await db.update(
      'cart_items',
      {
        'sync_status': SyncStatus.pendingDelete,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [cartItemId],
    );

    await _addToSyncQueue('cart_items', cartItemId, 'DELETE', {
      'id': cartItemId,
    });

    print('🛒 Item marked for removal from cart: $cartItemId');
  }

  /// Clear all cart items for a user
  Future<void> clearCart(int userId) async {
    final db = await AppDatabase.instance;

    // Mark all items as deleted
    await db.update(
      'cart_items',
      {
        'sync_status': SyncStatus.pendingDelete,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    print('🛒 Cart cleared for user: $userId');
  }

  /// Get cart item count for a user
  Future<int> getCartItemCount(int userId) async {
    final db = await AppDatabase.instance;
    final result = await db.rawQuery(
      'SELECT SUM(quantity) as total FROM cart_items WHERE user_id = ? AND sync_status != ?',
      [userId, SyncStatus.pendingDelete],
    );

    return result.first['total'] as int? ?? 0;
  }

  /// Get cart total for a user
  Future<double> getCartTotal(int userId) async {
    final db = await AppDatabase.instance;
    final result = await db.rawQuery(
      'SELECT SUM(price * quantity) as total FROM cart_items WHERE user_id = ? AND sync_status != ?',
      [userId, SyncStatus.pendingDelete],
    );

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get unsynced cart items
  Future<List<Map<String, dynamic>>> getUnsyncedCartItems() async {
    final db = await AppDatabase.instance;
    return await db.query(
      'cart_items',
      where: 'sync_status != ?',
      whereArgs: [SyncStatus.synced],
    );
  }

  /// Mark cart item as synced
  Future<void> markAsSynced(int localId, int? serverId) async {
    final db = await AppDatabase.instance;
    await db.update(
      'cart_items',
      {
        'sync_status': SyncStatus.synced,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [localId],
    );

    print('✅ Cart item $localId marked as synced');
  }

  /// Extract numeric price from string like "700 LKR"
  double _extractPriceFromString(dynamic price) {
    if (price == null) return 0.0;
    if (price is num) return price.toDouble();
    if (price is String) {
      final match = RegExp(r'\d+(\.\d+)?').firstMatch(price);
      if (match != null) {
        return double.tryParse(match.group(0) ?? '0') ?? 0.0;
      }
    }
    return 0.0;
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

  /// Clear all cart items (for testing)
  Future<void> clearAllCartItems() async {
    final db = await AppDatabase.instance;
    await db.delete('cart_items');
    print('🗑️ All cart items cleared');
  }
}
