import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// SQLite Database Helper for NutriNet App
/// Mandatory for MAD II offline capabilities
class AppDatabase {
  static Database? _database;
  static const String _databaseName = 'nutrinet_app.db';
  static const int _databaseVersion = 1;

  // Singleton pattern - only one database instance
  static Future<Database> get instance async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database with tables
  static Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    print('📁 Database path: $path');

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create all required tables
  static Future<void> _onCreate(Database db, int version) async {
    print('🏗️ Creating database tables...');

    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        email TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        phone TEXT,
        address TEXT,
        profile_picture TEXT,
        birth_date TEXT,
        join_date TEXT,
        sync_status INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Packages table
    await db.execute('''
      CREATE TABLE packages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        title TEXT NOT NULL,
        price REAL NOT NULL,
        original_price REAL,
        image TEXT,
        description TEXT,
        duration TEXT,
        category TEXT,
        rating REAL,
        reviews INTEGER,
        features TEXT, -- JSON string
        includes TEXT, -- JSON string
        suitable_for TEXT, -- JSON string
        sync_status INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Diet Plans table
    await db.execute('''
      CREATE TABLE diet_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        title TEXT NOT NULL,
        description TEXT,
        duration TEXT,
        price TEXT,
        image TEXT,
        category TEXT,
        difficulty TEXT,
        meals TEXT, -- JSON string
        sync_status INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Cart Items table
    await db.execute('''
      CREATE TABLE cart_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        package_id INTEGER,
        package_title TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER DEFAULT 1,
        image TEXT,
        description TEXT,
        sync_status INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Sync Queue table - tracks changes to sync with server
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        record_id INTEGER NOT NULL,
        action TEXT NOT NULL, -- INSERT, UPDATE, DELETE
        data TEXT, -- JSON data to sync
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    print('✅ Database tables created successfully');
  }

  /// Handle database upgrades
  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    print('🔄 Upgrading database from v$oldVersion to v$newVersion');
    // Add migration logic here when needed
  }

  /// Close database connection
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      print('🔒 Database connection closed');
    }
  }

  /// Clear all data (for testing/reset)
  static Future<void> clearAllData() async {
    final db = await instance;
    await db.execute('DELETE FROM sync_queue');
    await db.execute('DELETE FROM cart_items');
    await db.execute('DELETE FROM diet_plans');
    await db.execute('DELETE FROM packages');
    await db.execute('DELETE FROM users');
    print('🗑️ All data cleared from database');
  }

  /// Get database info for debugging
  static Future<Map<String, dynamic>> getDatabaseInfo() async {
    final db = await instance;
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );

    Map<String, int> tableCounts = {};
    for (var table in tables) {
      final tableName = table['name'] as String;
      if (!tableName.startsWith('sqlite_')) {
        final count =
            Sqflite.firstIntValue(
              await db.rawQuery('SELECT COUNT(*) FROM $tableName'),
            ) ??
            0;
        tableCounts[tableName] = count;
      }
    }

    return {
      'database_path': db.path,
      'version': await db.getVersion(),
      'tables': tableCounts,
    };
  }
}

/// Sync status constants
class SyncStatus {
  static const int synced = 0; // Data is synced with server
  static const int pendingInsert = 1; // New data to be sent to server
  static const int pendingUpdate = 2; // Updated data to be sent to server
  static const int pendingDelete = 3; // Data to be deleted on server
}
