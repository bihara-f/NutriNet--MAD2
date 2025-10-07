/// Laravel API Configuration
///
/// Update this file with your actual Laravel backend details
class ApiConfig {
  // 🔧 UPDATE THIS WITH YOUR ACTUAL LARAVEL SERVER URL
  // Example URLs:
  // - Local development: 'http://192.168.8.101:8000/api' (your WiFi IP)
  // - Local development: 'http://10.0.2.2:8000/api' (Android emulator)
  // - Production server: 'https://yourdomain.com/api'
  static const String baseUrl = 'http://192.168.8.101:8000/api';

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String logoutEndpoint = '/auth/logout';
  static const String userProfileEndpoint = '/user/profile';
  static const String packagesEndpoint = '/packages';
  static const String dietPlansEndpoint = '/diet-plans';
  static const String subscriptionsEndpoint = '/subscriptions';

  // Request Configuration
  static const int connectTimeout = 15000; // 15 seconds
  static const int receiveTimeout = 15000; // 15 seconds
  static const int sendTimeout = 15000; // 15 seconds

  // Security
  static const String tokenStorageKey = 'auth_token';
  static const String userStorageKey = 'user_data';

  // Full URLs (computed properties)
  static String get fullLoginUrl => baseUrl + loginEndpoint;
  static String get fullRegisterUrl => baseUrl + registerEndpoint;
  static String get fullLogoutUrl => baseUrl + logoutEndpoint;
  static String get fullUserProfileUrl => baseUrl + userProfileEndpoint;
  static String get fullPackagesUrl => baseUrl + packagesEndpoint;
  static String get fullDietPlansUrl => baseUrl + dietPlansEndpoint;
  static String get fullSubscriptionsUrl => baseUrl + subscriptionsEndpoint;

  // Debug mode
  static const bool enableLogging = true;
  static const bool enableOfflineMode = true;

  /// Check if we're using a localhost URL
  static bool get isLocalhost {
    return baseUrl.contains('localhost') ||
        baseUrl.contains('127.0.0.1') ||
        baseUrl.contains('10.0.2.2') ||
        baseUrl.contains('192.168.');
  }

  /// Get display name for current environment
  static String get environmentName {
    if (baseUrl.contains('localhost') || baseUrl.contains('127.0.0.1')) {
      return 'Local Development';
    } else if (baseUrl.contains('192.168.') || baseUrl.contains('10.0.2.2')) {
      return 'Network Development';
    } else if (baseUrl.startsWith('https://')) {
      return 'Production';
    } else {
      return 'Development';
    }
  }
}

/// Laravel API Routes Reference
/// 
/// Make sure your Laravel routes match these endpoints:
/// 
/// ```php
/// // routes/api.php
/// Route::prefix('auth')->group(function () {
///     Route::post('/login', [AuthController::class, 'login']);
///     Route::post('/register', [AuthController::class, 'register']);
///     Route::post('/logout', [AuthController::class, 'logout'])->middleware('auth:sanctum');
/// });
/// 
/// Route::middleware('auth:sanctum')->group(function () {
///     Route::get('/user/profile', [UserController::class, 'profile']);
///     Route::get('/packages', [PackageController::class, 'index']);
///     Route::get('/diet-plans', [DietPlanController::class, 'index']);
///     Route::get('/subscriptions', [SubscriptionController::class, 'index']);
/// });
/// ```
/// 
/// Expected Response Formats:
/// 
/// Login/Register Success:
/// ```json
/// {
///   "success": true,
///   "message": "Login successful",
///   "token": "1|abcd1234...",
///   "user": {
///     "id": 1,
///     "name": "John Doe",
///     "email": "john@example.com"
///   }
/// }
/// ```
/// 
/// Error Response:
/// ```json
/// {
///   "success": false,
///   "message": "Invalid credentials"
/// }
/// ```
/// 
/// Packages Response:
/// ```json
/// {
///   "success": true,
///   "data": [
///     {
///       "id": 1,
///       "title": "Basic Plan",
///       "price": "$29.99",
///       "description": "Perfect for beginners",
///       "duration": "1 month",
///       "category": "fitness"
///     }
///   ]
/// }
/// ```