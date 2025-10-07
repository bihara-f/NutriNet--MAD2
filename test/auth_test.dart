import 'package:flutter_test/flutter_test.dart';
import 'package:signup_app/providers/app_state.dart';

void main() {
  group('Authentication Tests', () {
    late AppState appState;

    setUp(() async {
      appState = AppState();
      await appState.initialize();
    });

    test('User registration should work correctly', () async {
      await appState.register(
        'test@example.com',
        'password123',
        'Test User',
        phone: '1234567890',
        address: '123 Test Street',
      );

      expect(appState.isLoggedIn, equals(true));
      expect(appState.userEmail, equals('test@example.com'));
      expect(appState.userName, equals('Test User'));
    });

    test('User login should work correctly', () async {
      // First register a user
      await appState.register(
        'test@example.com',
        'password123',
        'Test User',
        phone: '1234567890',
        address: '123 Test Street',
      );

      // Logout
      await appState.logout();
      expect(appState.isLoggedIn, equals(false));

      // Login again
      await appState.login('test@example.com', 'password123');

      expect(appState.isLoggedIn, equals(true));
      expect(appState.userEmail, equals('test@example.com'));
    });

    test('Invalid login should fail', () async {
      try {
        await appState.login('nonexistent@example.com', 'wrongpassword');
        fail('Expected an exception');
      } catch (e) {
        expect(appState.isLoggedIn, equals(false));
      }
    });
  });
}
