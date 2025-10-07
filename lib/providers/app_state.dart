import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/package_repository.dart';
import '../database/diet_plan_repository.dart';
import '../database/cart_repository.dart';
import '../database/app_database.dart';
import '../services/sync_service.dart';
import '../services/network_service.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class AppState extends ChangeNotifier {
  // Database repositories for offline-first architecture
  final PackageRepository _packageRepo = PackageRepository();
  final DietPlanRepository _dietPlanRepo = DietPlanRepository();
  final CartRepository _cartRepo = CartRepository();

  // Sync and network services for API integration
  final SyncService _syncService = SyncService();
  final NetworkService _networkService = NetworkService();

  // User data
  bool _isLoggedIn = false;
  int _currentUserId = 1; // Default user ID for demo
  String _userEmail = '';
  String _userName = '';
  String _userUsername = '';
  String _userPhone = '';
  String _userAddress = '';
  String _userGender = '';
  DateTime? _userJoinDate;
  String _userProfilePicture = '';
  DateTime? _userBirthDate;

  // Data lists (loaded from SQLite)
  List<Map<String, dynamic>> _dietPlans = [];
  List<Map<String, dynamic>> _packages = [];
  List<Map<String, dynamic>> _cartItems = [];

  // Device capabilities
  bool _isConnected = true;
  String _batteryLevel = 'Unknown';
  String _location = 'Unknown';

  // Network and sync status for API integration
  bool _isOnline = false;
  bool _isSyncing = false;
  String _networkStatus = 'Checking connection...';
  DateTime? _lastSyncTime;
  int _pendingSyncItems = 0;

  // Initialization flag
  bool _isInitialized = false;

  // Getters - User data
  bool get isLoggedIn => _isLoggedIn;
  int get currentUserId => _currentUserId;
  bool get isInitialized => _isInitialized;
  String get userEmail => _userEmail;
  String get userName => _userName;
  String get userUsername => _userUsername;
  String get userPhone => _userPhone;
  String get userAddress => _userAddress;
  String get userGender => _userGender;
  DateTime? get userJoinDate => _userJoinDate;
  String get userProfilePicture => _userProfilePicture;
  DateTime? get userBirthDate => _userBirthDate;
  List<Map<String, dynamic>> get dietPlans => _dietPlans;
  List<Map<String, dynamic>> get packages => _packages;
  bool get isConnected => _isConnected;
  String get batteryLevel => _batteryLevel;
  String get location => _location;
  List<Map<String, dynamic>> get cartItems => _cartItems;
  int get cartItemCount => _cartItems.length;
  double get cartTotal => _cartItems.fold(0.0, (sum, item) {
    final quantity = item['quantity'] ?? 1;
    final price = item['price'] ?? 0.0; // Now using numeric price
    return sum + (price * quantity);
  });

  // Network and sync status getters
  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  String get networkStatus => _networkStatus;
  DateTime? get lastSyncTime => _lastSyncTime;
  int get pendingSyncItems => _pendingSyncItems;

  // Helper method to extract numeric price from string like "700 LKR"
  double _extractPriceFromString(dynamic price) {
    if (price == null) return 0.0;
    if (price is num) return price.toDouble();
    if (price is String) {
      // Extract numbers from string like "700 LKR" -> 700.0
      final match = RegExp(r'\d+(\.\d+)?').firstMatch(price);
      if (match != null) {
        return double.tryParse(match.group(0) ?? '0') ?? 0.0;
      }
    }
    return 0.0;
  }

  // Authentication methods
  Future<void> login(
    String email,
    String password, {
    String? phone,
    String? address,
  }) async {
    try {
      // Basic validation
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password are required');
      }

      // Check if user exists in database
      final db = await AppDatabase.instance;
      final userResult = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      int userId;
      String userName;
      String userPhone;
      String userAddress;
      DateTime userJoinDate;

      if (userResult.isNotEmpty) {
        // Existing user - load their data
        final userData = userResult.first;
        // TODO: In a real app, verify password hash here
        // For now, we accept any password for existing users
        userId = userData['id'] as int;
        userName = userData['name'] as String;
        userPhone = userData['phone'] as String? ?? '';
        userAddress = userData['address'] as String? ?? '';
        userJoinDate = DateTime.parse(userData['join_date'] as String);
      } else {
        // User doesn't exist - throw error for login
        throw Exception('User not found. Please sign up first.');
      }

      // Always clear cart items from memory when switching users
      if (_currentUserId != userId) {
        print('👥 Switching from user $_currentUserId to user $userId');
      }

      // Clear cart items from memory regardless of user switch
      _cartItems.clear();

      // Update current user
      _currentUserId = userId;
      _isLoggedIn = true;
      _userEmail = email;
      _userName = userName;
      _userPhone = userPhone;
      _userAddress = userAddress;
      _userJoinDate = userJoinDate;

      // Save to local storage (with error handling for read-only issues)
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setInt('currentUserId', userId);
        await prefs.setString('userEmail', email);
        await prefs.setString('userName', userName);
        await prefs.setString('userPhone', userPhone);
        await prefs.setString('userAddress', userAddress);
        await prefs.setString('userJoinDate', userJoinDate.toIso8601String());
        print('💾 Login session saved to SharedPreferences');
      } catch (e) {
        print('⚠️ Warning: Could not save to SharedPreferences: $e');
        print(
          '📱 Login will work but session won\'t persist across app restarts',
        );
      }

      // Load fresh user-specific cart items from database (with error handling)
      try {
        await loadCartItems();
        print('🛒 Loaded ${_cartItems.length} cart items for user $userId');
      } catch (e) {
        print('⚠️ Warning: Could not load cart items: $e');
        print('🛒 Cart will be empty but login will continue');
        _cartItems.clear(); // Ensure cart is clear if loading fails
      }

      print('✅ Login successful for user: $userName (ID: $userId)');
      notifyListeners();
    } catch (e) {
      print('❌ Login error: $e');
      throw Exception('Login failed: $e');
    }
  }

  Future<void> logout() async {
    print('👋 Logging out user: $_userName (ID: $_currentUserId)');

    // Clear login session state
    _isLoggedIn = false;

    // Clear cart items from memory
    _cartItems.clear();

    // Clear SharedPreferences to ensure clean logout (handle read-only gracefully)
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('currentUserId');
      await prefs.remove('userEmail');
      await prefs.remove('userName');
      await prefs.remove('userPhone');
      await prefs.remove('userAddress');
      await prefs.remove('userJoinDate');
      print('🗑️ Cleared login data from SharedPreferences');
    } catch (e) {
      print('⚠️ Warning: Could not clear SharedPreferences (read-only): $e');
      print(
        '📱 Logout will work but stored session may persist until app restart',
      );
    }

    // Reset user data to ensure clean state
    _currentUserId = 1;
    _userEmail = '';
    _userName = '';
    _userPhone = '';
    _userAddress = '';
    _userProfilePicture = '';
    _userJoinDate = null;
    _userBirthDate = null;

    print('✅ Logout successful - all user data cleared');
    notifyListeners();
  }

  Future<void> register(
    String email,
    String password,
    String name, {
    String? phone,
    String? address,
  }) async {
    try {
      // Basic validation
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        throw Exception('Email, password, and name are required');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters long');
      }

      // Check if user already exists
      final db = await AppDatabase.instance;
      final existingUser = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (existingUser.isNotEmpty) {
        throw Exception(
          'User with this email already exists. Please sign in instead.',
        );
      }

      // Create new user in database
      final userJoinDate = DateTime.now();

      final userId = await db.insert('users', {
        'email': email,
        'name': name,
        'phone': phone ?? '',
        'address': address ?? '',
        'join_date': userJoinDate.toIso8601String(),
        'sync_status': 1,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Always clear cart items from memory for new user registration
      if (_currentUserId != userId) {
        print(
          '👥 Switching from user $_currentUserId to user $userId (new registration)',
        );
      }

      // Clear cart items from memory (should be empty for new user anyway)
      _cartItems.clear();

      // Update current user
      _currentUserId = userId;
      _isLoggedIn = true;
      _userEmail = email;
      _userName = name;
      _userPhone = phone ?? '';
      _userAddress = address ?? '';
      _userJoinDate = userJoinDate;

      // Save to local storage (with error handling for read-only issues)
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setInt('currentUserId', userId);
        await prefs.setString('userEmail', email);
        await prefs.setString('userName', name);
        await prefs.setString('userPhone', _userPhone);
        await prefs.setString('userAddress', _userAddress);
        await prefs.setString('userJoinDate', userJoinDate.toIso8601String());
        print('💾 Registration session saved to SharedPreferences');
      } catch (e) {
        print('⚠️ Warning: Could not save to SharedPreferences: $e');
        print(
          '📱 Registration will work but session won\'t persist across app restarts',
        );
      }

      // Load user-specific cart items (should be empty for new user)
      try {
        await loadCartItems();
        print(
          '🛒 Loaded ${_cartItems.length} cart items for new user $userId (should be 0)',
        );
      } catch (e) {
        print('⚠️ Warning: Could not load cart items: $e');
        print('🛒 Cart will be empty but registration will continue');
        _cartItems.clear(); // Ensure cart is clear if loading fails
      }

      print('✅ Registration successful for user: $name (ID: $userId)');
      notifyListeners();
    } catch (e) {
      print('❌ Registration error: $e');
      throw Exception('Registration failed: $e');
    }
  }

  /// Initialize the app state with SQLite data
  /// This is mandatory for MAD II offline capabilities
  Future<void> initialize() async {
    if (_isInitialized) return;

    print('🚀 Initializing AppState with SQLite...');

    // Clear corrupted data and reload fresh data
    await _resetDatabaseData();

    // Load initial data from JSON files into SQLite (first time only)
    await _loadInitialDataIfNeeded();

    // Load data from SQLite
    await loadPackages();
    await loadDietPlans();
    await loadCartItems();

    _isInitialized = true;
    print('✅ AppState initialized successfully');
    notifyListeners();
  }

  /// Reset database data to fix any corruption issues
  Future<void> _resetDatabaseData() async {
    try {
      await _packageRepo.clearAllPackages();
      await _dietPlanRepo.clearAllDietPlans();
      print('🔄 Database data reset completed');
    } catch (e) {
      print('⚠️ Error resetting database data: $e');
    }
  }

  /// Load initial data from JSON files into SQLite (migration helper)
  Future<void> _loadInitialDataIfNeeded() async {
    try {
      // Load packages from JSON
      final packageJsonString = await rootBundle.loadString(
        'assets/data/packages.json',
      );
      final packageJsonData = jsonDecode(packageJsonString) as List;
      final packages = packageJsonData.cast<Map<String, dynamic>>();
      await _packageRepo.loadInitialData(packages);

      // Load diet plans from JSON
      final dietPlanJsonString = await rootBundle.loadString(
        'assets/data/diet_plans.json',
      );
      final dietPlanJsonData = jsonDecode(dietPlanJsonString) as List;
      final dietPlans = dietPlanJsonData.cast<Map<String, dynamic>>();
      await _dietPlanRepo.loadInitialData(dietPlans);

      print('📦 Initial data loaded into SQLite from JSON files');
    } catch (e) {
      print('⚠️ Error loading initial data: $e');
    }
  }

  // Check if user is already logged in
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _currentUserId = prefs.getInt('currentUserId') ?? 1;
    _userEmail = prefs.getString('userEmail') ?? '';
    _userName = prefs.getString('userName') ?? '';
    _userPhone = prefs.getString('userPhone') ?? '';
    _userAddress = prefs.getString('userAddress') ?? '';
    _userProfilePicture = prefs.getString('userProfilePicture') ?? '';
    final joinDateString = prefs.getString('userJoinDate');
    if (joinDateString != null) {
      _userJoinDate = DateTime.tryParse(joinDateString);
    }
    final birthDateString = prefs.getString('userBirthDate');
    if (birthDateString != null) {
      _userBirthDate = DateTime.tryParse(birthDateString);
    }

    if (_isLoggedIn) {
      print(
        '📱 Restored login session for user: $_userName (ID: $_currentUserId)',
      );
    }
    notifyListeners();
  }

  /// Update user profile information
  Future<void> updateUserProfile({
    String? name,
    String? phone,
    String? address,
    String? profilePicture,
    DateTime? birthDate,
  }) async {
    if (!_isLoggedIn) {
      throw Exception('User must be logged in to update profile');
    }

    try {
      final db = await AppDatabase.instance;
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) {
        updateData['name'] = name;
        _userName = name;
      }
      if (phone != null) {
        updateData['phone'] = phone;
        _userPhone = phone;
      }
      if (address != null) {
        updateData['address'] = address;
        _userAddress = address;
      }
      if (profilePicture != null) {
        updateData['profile_picture'] = profilePicture;
        _userProfilePicture = profilePicture;
      }
      if (birthDate != null) {
        updateData['birth_date'] = birthDate.toIso8601String();
        _userBirthDate = birthDate;
      }

      await db.update(
        'users',
        updateData,
        where: 'id = ?',
        whereArgs: [_currentUserId],
      );

      // Update SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      if (name != null) await prefs.setString('userName', name);
      if (phone != null) await prefs.setString('userPhone', phone);
      if (address != null) await prefs.setString('userAddress', address);
      if (profilePicture != null) {
        await prefs.setString('userProfilePicture', profilePicture);
      }
      if (birthDate != null) {
        await prefs.setString('userBirthDate', birthDate.toIso8601String());
      }

      print('✅ Profile updated for user: $_userName (ID: $_currentUserId)');
      notifyListeners();
    } catch (e) {
      print('❌ Profile update error: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  // SQLite Data Loading Methods (Mandatory for offline capabilities)

  /// Load packages from SQLite database
  Future<void> loadPackages() async {
    try {
      _packages = await _packageRepo.getAllPackages();
      print('📦 Loaded ${_packages.length} packages from SQLite');
      notifyListeners();
    } catch (e) {
      print('❌ Error loading packages: $e');
    }
  }

  /// Load diet plans from SQLite database
  Future<void> loadDietPlans() async {
    try {
      _dietPlans = await _dietPlanRepo.getAllDietPlans();
      print('🥗 Loaded ${_dietPlans.length} diet plans from SQLite');
      notifyListeners();
    } catch (e) {
      print('❌ Error loading diet plans: $e');
    }
  }

  /// Load cart items from SQLite database
  Future<void> loadCartItems() async {
    try {
      _cartItems = await _cartRepo.getCartItems(_currentUserId);
      print('🛒 Loaded ${_cartItems.length} cart items from SQLite');
      notifyListeners();
    } catch (e) {
      print('❌ Error loading cart items: $e');
    }
  }

  // Legacy setters for backward compatibility
  void setDietPlans(List<Map<String, dynamic>> plans) {
    _dietPlans = plans;
    notifyListeners();
  }

  void setPackages(List<Map<String, dynamic>> packageList) {
    _packages = packageList;
    notifyListeners();
  }

  // Network connectivity
  void setConnectivity(bool connected) {
    _isConnected = connected;
    notifyListeners();
  }

  // Device capabilities
  void setBatteryLevel(String level) {
    _batteryLevel = level;
    notifyListeners();
  }

  void setLocation(String loc) {
    _location = loc;
    notifyListeners();
  }

  // Profile management methods
  Future<void> updateProfilePicture(String imagePath) async {
    _userProfilePicture = imagePath;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userProfilePicture', imagePath);
    notifyListeners();
  }

  Future<void> updateBirthDate(DateTime birthDate) async {
    _userBirthDate = birthDate;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userBirthDate', birthDate.toIso8601String());
    notifyListeners();
  }

  Future<void> updateUserAddress(String address) async {
    _userAddress = address;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userAddress', address);
    notifyListeners();
  }

  // Cart management methods - SQLite-based (MANDATORY for MAD II offline capabilities)

  /// Add package to cart using SQLite
  Future<Map<String, dynamic>> addToCart(Map<String, dynamic> package) async {
    print('🛒 DEBUG: Adding to cart - Package: ${package.toString()}');
    print('🔐 DEBUG: User logged in: $_isLoggedIn');

    // Check if user is logged in
    if (!_isLoggedIn) {
      print('⚠️ DEBUG: User not logged in, but allowing cart for testing');
      // return {'error': 'Please sign in to add items to cart', 'success': false};
    }

    try {
      final packageId = package['id'];
      final packageName =
          package['title'] ?? package['name'] ?? 'Unknown Package';
      final packagePrice = _extractPriceFromString(package['price']);

      print(
        '📦 DEBUG: Package ID: $packageId, Name: $packageName, Price: $packagePrice',
      );

      // Add to SQLite database
      await _cartRepo.addToCart(_currentUserId, package);

      // Reload cart items from SQLite
      await loadCartItems();

      print('📋 DEBUG: Cart items after adding: ${_cartItems.toString()}');
      print('🔢 DEBUG: Cart total items: ${_cartItems.length}');

      return {
        'success': 'Package added to cart successfully!',
        'cart_count': _cartItems.length,
      };
    } catch (e) {
      print('❌ Error adding to cart: $e');
      return {'error': 'Failed to add item to cart', 'success': false};
    }
  }

  /// Remove item from cart using SQLite
  Future<Map<String, dynamic>> removeFromCart(int cartItemId) async {
    try {
      await _cartRepo.removeFromCart(cartItemId);
      await loadCartItems(); // Reload from SQLite

      return {
        'success': 'Package removed from cart successfully!',
        'cart_count': _cartItems.length,
      };
    } catch (e) {
      print('❌ Error removing from cart: $e');
      return {'error': 'Failed to remove item from cart'};
    }
  }

  /// Update cart item quantity using SQLite
  Future<Map<String, dynamic>> updateCartItemQuantity(
    int cartItemId,
    int quantity,
  ) async {
    try {
      await _cartRepo.updateQuantity(cartItemId, quantity);
      await loadCartItems(); // Reload from SQLite

      return {
        'success': 'Cart updated successfully!',
        'cart_count': _cartItems.length,
      };
    } catch (e) {
      print('❌ Error updating cart: $e');
      return {'error': 'Failed to update cart item'};
    }
  }

  /// Clear entire cart using SQLite
  Future<Map<String, dynamic>> clearCart() async {
    try {
      await _cartRepo.clearCart(_currentUserId);
      await loadCartItems(); // Reload from SQLite

      return {'success': 'Cart cleared successfully!'};
    } catch (e) {
      print('❌ Error clearing cart: $e');
      return {'error': 'Failed to clear cart'};
    }
  }

  /// Debug method to completely remove all cart items from database (for testing)
  Future<void> debugClearAllCartItems() async {
    try {
      final db = await AppDatabase.instance;
      await db.delete('cart_items'); // Remove all cart items
      _cartItems.clear(); // Clear from memory
      print('🚮 DEBUG: All cart items removed from database');
      notifyListeners();
    } catch (e) {
      print('❌ DEBUG: Error clearing all cart items: $e');
    }
  }

  /// Debug method to check what cart items exist in database
  Future<void> debugCheckCartItems() async {
    try {
      final db = await AppDatabase.instance;
      final allItems = await db.query('cart_items');
      print('🔍 DEBUG: Total cart items in database: ${allItems.length}');
      for (var item in allItems) {
        print(
          '   - User ${item['user_id']}: ${item['package_title']} (Status: ${item['sync_status']})',
        );
      }
    } catch (e) {
      print('❌ DEBUG: Error checking cart items: $e');
    }
  }

  /// Get cart count from SQLite
  Future<int> getCartCount() async {
    try {
      return await _cartRepo.getCartItemCount(_currentUserId);
    } catch (e) {
      print('❌ Error getting cart count: $e');
      return 0;
    }
  }

  // Synchronous cart count for backward compatibility
  int getCartCountSync() {
    return _cartItems.length;
  }

  /// Get cart data from SQLite
  Future<Map<String, dynamic>> getCartData() async {
    if (!_isLoggedIn) {
      return {'error': 'Please sign in to view your cart', 'redirect': true};
    }

    try {
      final total = await _cartRepo.getCartTotal(_currentUserId);

      return {'cart': _cartItems, 'total': total, 'count': _cartItems.length};
    } catch (e) {
      print('❌ Error getting cart data: $e');
      return {'error': 'Failed to load cart data'};
    }
  }

  /// Check if item is in cart
  bool isInCart(String itemId) {
    return _cartItems.any((item) => item['package_id'].toString() == itemId);
  }

  /// Get database info for debugging
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    return await AppDatabase.getDatabaseInfo();
  }

  // Network and sync methods for API integration

  /// Check network status and update connectivity state
  Future<void> checkNetworkStatus() async {
    try {
      _isOnline = await _networkService.hasInternetConnection();
      _networkStatus = await _networkService.getConnectivityStatus();
      notifyListeners();
    } catch (e) {
      print('Error checking network status: $e');
      _isOnline = false;
      _networkStatus = 'Connection check failed';
      notifyListeners();
    }
  }

  /// Perform full sync with server (upload changes and download updates)
  Future<Map<String, dynamic>> performFullSync() async {
    if (_isSyncing) {
      return {'success': false, 'message': 'Sync already in progress'};
    }

    _isSyncing = true;
    notifyListeners();

    try {
      // Check network connection first
      await checkNetworkStatus();

      if (!_isOnline) {
        throw Exception('No internet connection available');
      }

      // Perform sync
      final result = await _syncService.performFullSync();

      if (result['success'] == true) {
        _lastSyncTime = DateTime.now();

        // Reload data from SQLite after sync
        await loadPackages();
        await loadDietPlans();
        await loadCartItems();

        // Update sync stats
        final stats = await _syncService.getSyncStats();
        _pendingSyncItems = stats['pending'] ?? 0;

        print('✅ Full sync completed successfully');
      }

      return result;
    } catch (e) {
      print('❌ Sync failed: $e');
      return {'success': false, 'message': 'Sync failed: $e'};
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Upload local changes to server
  Future<Map<String, dynamic>> uploadChanges() async {
    if (_isSyncing || !_isOnline) {
      return {
        'success': false,
        'message': _isSyncing ? 'Sync in progress' : 'No internet connection',
      };
    }

    _isSyncing = true;
    notifyListeners();

    try {
      final result = await _syncService.uploadChanges();

      if (result['success'] == true) {
        // Update sync stats after upload
        final stats = await _syncService.getSyncStats();
        _pendingSyncItems = stats['pending'] ?? 0;
      }

      return result;
    } catch (e) {
      return {'success': false, 'message': 'Upload failed: $e'};
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Download server updates
  Future<Map<String, dynamic>> downloadUpdates() async {
    if (_isSyncing || !_isOnline) {
      return {
        'success': false,
        'message': _isSyncing ? 'Sync in progress' : 'No internet connection',
      };
    }

    _isSyncing = true;
    notifyListeners();

    try {
      final result = await _syncService.downloadUpdates();

      if (result['success'] == true) {
        // Reload data from SQLite after download
        await loadPackages();
        await loadDietPlans();
        await loadCartItems();

        _lastSyncTime = DateTime.now();
      }

      return result;
    } catch (e) {
      return {'success': false, 'message': 'Download failed: $e'};
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Get current sync statistics
  Future<Map<String, dynamic>> getSyncStats() async {
    try {
      final stats = await _syncService.getSyncStats();
      _pendingSyncItems = stats['pending'] ?? 0;
      return stats;
    } catch (e) {
      print('Error getting sync stats: $e');
      return {
        'pending': 0,
        'failed': 0,
        'last_sync': null,
        'is_syncing': false,
      };
    }
  }

  /// Retry failed sync items
  Future<int> retryFailedSync() async {
    try {
      final retriedCount = await _syncService.retryFailedSync();

      // Update sync stats
      final stats = await _syncService.getSyncStats();
      _pendingSyncItems = stats['pending'] ?? 0;
      notifyListeners();

      return retriedCount;
    } catch (e) {
      print('Error retrying failed sync: $e');
      return 0;
    }
  }

  /// Initialize network monitoring (call during app startup)
  Future<void> initializeNetworkMonitoring() async {
    // Initial network check
    await checkNetworkStatus();

    // Listen to connectivity changes
    _networkService.connectivityStream.listen((result) async {
      await checkNetworkStatus();

      // Auto-sync when connection is restored
      if (_isOnline && _pendingSyncItems > 0) {
        print('🔄 Connection restored, auto-syncing pending items...');
        await performFullSync();
      }
    });

    // Get initial sync stats
    await getSyncStats();
  }
}
