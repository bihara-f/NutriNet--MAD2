import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';

class DatabaseRestoration {
  static final DatabaseRestoration _instance = DatabaseRestoration._internal();
  factory DatabaseRestoration() => _instance;
  DatabaseRestoration._internal();

  Future<bool> restoreAllData() async {
    try {
      print('🔄 Starting database restoration...');

      // Clear existing data
      await _clearAllData();

      // Restore packages from JSON
      await _restorePackagesData();

      // Restore diet plans
      await _restoreDietPlansData();

      // Add sample users
      await _restoreUsersData();

      print('✅ Database restoration completed successfully');
      return true;
    } catch (e) {
      print('❌ Database restoration failed: $e');
      return false;
    }
  }

  Future<void> _clearAllData() async {
    final db = await AppDatabase.instance;

    // Clear all tables
    await db.delete('packages');
    await db.delete('diet_plans');
    await db.delete('users');

    print('🗑️ Cleared all existing data');
  }

  Future<void> _restorePackagesData() async {
    try {
      // Load packages from JSON file
      final jsonString = await rootBundle.loadString(
        'assets/data/packages.json',
      );
      final List<dynamic> packagesJson = json.decode(jsonString);

      final db = await AppDatabase.instance;

      for (var packageData in packagesJson) {
        // Extract numeric price value
        String priceStr = packageData['price'].toString().replaceAll(
          RegExp(r'[^\d.]'),
          '',
        );
        String originalPriceStr = packageData['originalPrice']
            .toString()
            .replaceAll(RegExp(r'[^\d.]'), '');

        final package = {
          'server_id': packageData['id'],
          'title': packageData['title'],
          'description': packageData['description'],
          'price': double.tryParse(priceStr) ?? 0.0,
          'original_price': double.tryParse(originalPriceStr) ?? 0.0,
          'image': packageData['image'],
          'duration': packageData['duration'],
          'category': packageData['category'],
          'rating': packageData['rating'].toDouble(),
          'reviews': packageData['reviews'],
          'features': json.encode(packageData['features']),
          'includes': json.encode(packageData['includes']),
          'suitable_for': json.encode(packageData['suitableFor']),
          'sync_status': 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        await db.insert('packages', package);
      }

      print('📦 Restored ${packagesJson.length} packages');
    } catch (e) {
      print('❌ Failed to restore packages: $e');
    }
  }

  Future<void> _restoreDietPlansData() async {
    try {
      final db = await AppDatabase.instance;

      final dietPlans = [
        {
          'server_id': 1,
          'title': 'Mediterranean Diet',
          'description':
              'Heart-healthy eating plan based on Mediterranean cuisine',
          'duration': '28 days',
          'price': '1800 LKR',
          'image': 'asset/diet-planner.jpg',
          'category': 'Nutrition',
          'difficulty': 'Beginner',
          'meals': json.encode({
            'breakfast': ['Greek yogurt with berries', 'Whole grain toast'],
            'lunch': ['Grilled fish salad', 'Olive oil dressing'],
            'dinner': ['Grilled chicken', 'Roasted vegetables'],
            'snacks': ['Nuts and fruits', 'Hummus with vegetables'],
          }),
          'sync_status': 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        {
          'server_id': 2,
          'title': 'Keto Weight Loss',
          'description': 'Low-carb, high-fat diet for rapid weight loss',
          'duration': '56 days',
          'price': '1500 LKR',
          'image': 'asset/diet-planner.jpg',
          'category': 'Weight Loss',
          'difficulty': 'Intermediate',
          'meals': json.encode({
            'breakfast': ['Scrambled eggs with avocado', 'Butter coffee'],
            'lunch': ['Grilled salmon', 'Leafy green salad'],
            'dinner': ['Beef steak', 'Steamed broccoli'],
            'snacks': ['Cheese and nuts', 'Keto smoothie'],
          }),
          'sync_status': 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        {
          'server_id': 3,
          'title': 'Muscle Building Plan',
          'description': 'High-protein diet to support muscle growth',
          'duration': '84 days',
          'price': '2200 LKR',
          'image': 'asset/fittrain.jpeg',
          'category': 'Fitness',
          'difficulty': 'Advanced',
          'meals': json.encode({
            'breakfast': ['Protein pancakes', 'Banana smoothie'],
            'lunch': ['Grilled chicken breast', 'Brown rice'],
            'dinner': ['Lean beef', 'Sweet potato'],
            'snacks': ['Protein shake', 'Greek yogurt'],
          }),
          'sync_status': 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        {
          'server_id': 4,
          'title': 'Vegan Lifestyle',
          'description': 'Plant-based nutrition for optimal health',
          'duration': '42 days',
          'price': '1900 LKR',
          'image': 'asset/nutri.jpeg',
          'category': 'Nutrition',
          'difficulty': 'Beginner',
          'meals': json.encode({
            'breakfast': ['Oatmeal with berries', 'Almond milk'],
            'lunch': ['Quinoa salad', 'Chickpea curry'],
            'dinner': ['Lentil stew', 'Brown bread'],
            'snacks': ['Fresh fruits', 'Nuts and seeds'],
          }),
          'sync_status': 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      ];

      for (var dietPlan in dietPlans) {
        await db.insert('diet_plans', dietPlan);
      }

      print('🍽️ Restored ${dietPlans.length} diet plans');
    } catch (e) {
      print('❌ Failed to restore diet plans: $e');
    }
  }

  Future<void> _restoreUsersData() async {
    try {
      final db = await AppDatabase.instance;

      final users = [
        {
          'server_id': 1,
          'name': 'John Smith',
          'email': 'john.smith@email.com',
          'phone': '+1234567890',
          'address': '123 Main Street, City',
          'birth_date': '1990-05-15',
          'join_date':
              DateTime.now()
                  .subtract(const Duration(days: 30))
                  .toIso8601String(),
          'profile_picture': '',
          'sync_status': 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        {
          'server_id': 2,
          'name': 'Sarah Johnson',
          'email': 'sarah.johnson@email.com',
          'phone': '+1987654321',
          'address': '456 Oak Avenue, Town',
          'birth_date': '1988-08-22',
          'join_date':
              DateTime.now()
                  .subtract(const Duration(days: 60))
                  .toIso8601String(),
          'profile_picture': '',
          'sync_status': 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        {
          'server_id': 3,
          'name': 'Mike Wilson',
          'email': 'mike.wilson@email.com',
          'phone': '+1122334455',
          'address': '789 Pine Road, Village',
          'birth_date': '1992-02-10',
          'join_date':
              DateTime.now()
                  .subtract(const Duration(days: 90))
                  .toIso8601String(),
          'profile_picture': '',
          'sync_status': 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      ];

      for (var user in users) {
        await db.insert('users', user);
      }

      print('👥 Restored ${users.length} sample users');
    } catch (e) {
      print('❌ Failed to restore users: $e');
    }
  }

  Future<Map<String, int>> getDatabaseStats() async {
    try {
      final db = await AppDatabase.instance;

      final packageResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM packages',
      );
      final dietPlanResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM diet_plans',
      );
      final userResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM users',
      );

      final packageCount = packageResult.first['count'] as int;
      final dietPlanCount = dietPlanResult.first['count'] as int;
      final userCount = userResult.first['count'] as int;

      return {
        'packages': packageCount,
        'dietPlans': dietPlanCount,
        'users': userCount,
      };
    } catch (e) {
      print('❌ Failed to get database stats: $e');
      return {'packages': 0, 'dietPlans': 0, 'users': 0};
    }
  }

  Future<bool> clearAllData() async {
    try {
      await _clearAllData();
      print('✅ Successfully cleared all data');
      return true;
    } catch (e) {
      print('❌ Failed to clear data: $e');
      return false;
    }
  }
}
