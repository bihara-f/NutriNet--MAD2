import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'auth_manager.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const String registerUrl = '$baseUrl/auth/register';
  static const String loginUrl = '$baseUrl/auth/login';
  static const String profileUrl = '$baseUrl/user/profile';

  // Register
  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String contactNumber,
    String username,
    String gender,
  ) async {
    try {
      print('🌐 Attempting registration for: $email');
      print('🌐 Registering to URL: $registerUrl');

      final requestBody = {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'contact_number': contactNumber,
        'username': username,
        'gender': gender,
        'terms': true, // Accept terms and conditions
      };

      print('🌐 Request body: $requestBody');

      final response = await http
          .post(
            Uri.parse(registerUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(Duration(seconds: 10));

      print('🌐 Registration response status: ${response.statusCode}');
      print('🌐 Registration response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        return {'message': errorBody['message'] ?? 'Registration failed'};
      }
    } catch (e) {
      print('🌐 Registration error: $e');
      return {
        'message':
            'Network error: Unable to connect to server. Please check your internet connection.',
      };
    }
  }

  // Login
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      print('🌐 Attempting login for: $email');
      print('🌐 Login URL: $loginUrl');

      final response = await http
          .post(
            Uri.parse(loginUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(Duration(seconds: 10));

      print('🌐 Login response status: ${response.statusCode}');
      print('🌐 Login response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        return {'message': errorBody['message'] ?? 'Login failed'};
      }
    } catch (e) {
      print('🌐 Login error: $e');
      return {
        'message':
            'Network error: Unable to connect to server. Please check your internet connection.',
      };
    }
  }

  // Fetch Profile (protected)
  static Future<Map<String, dynamic>> getProfile(String token) async {
    final response = await http.get(
      Uri.parse(profileUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return jsonDecode(response.body);
  }

  // Legacy methods for backward compatibility
  static Future<List<Map<String, dynamic>>> getDietPlans() async {
    // Return offline data for now
    return [
      {
        'id': 1,
        'title': 'Weight Loss Plan',
        'description': 'A comprehensive 30-day weight loss diet plan',
        'duration': '30 days',
        'price': 'LKR 2500',
        'image': 'asset/diet-planner.jpg',
      },
      {
        'id': 2,
        'title': 'Muscle Gain Plan',
        'description': 'High protein diet plan for muscle building',
        'duration': '45 days',
        'price': 'LKR 3000',
        'image': 'asset/fittrain.jpeg',
      },
    ];
  }

  static Future<List<Map<String, dynamic>>> getPackages() async {
    // Return offline data for now
    return [
      {
        'id': 1,
        'title': 'Diet Plan',
        'price': '700 LKR',
        'image': 'asset/diet-planner.jpg',
        'description': 'Comprehensive diet planning',
      },
      {
        'id': 2,
        'title': 'Fitness Training',
        'price': '700 LKR',
        'image': 'asset/fittrain.jpeg',
        'description': 'Professional fitness training',
      },
    ];
  }

  static Future<List<dynamic>> fetchPackages() async {
    final packages = await getPackages();
    return packages;
  }

  static Future<List<dynamic>> fetchDietPlans() async {
    final plans = await getDietPlans();
    return plans;
  }

  static Future<bool> testConnection() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> hasValidToken() async {
    final token = await AuthManager.getToken();
    return token != null && token.isNotEmpty;
  }
}
