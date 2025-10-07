import 'package:flutter/material.dart';
import '../pages/cart_page.dart';

class NavigationHelper {
  /// Safely navigate to cart page with error handling
  static Future<void> navigateToCart(
    BuildContext context, {
    bool replace = false,
  }) async {
    if (!context.mounted) return;

    try {
      if (replace) {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CartPage()),
        );
      } else {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CartPage()),
        );
      }
    } catch (e) {
      print('Cart navigation error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open cart. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Show success message with cart navigation option
  static void showCartSuccessMessage(
    BuildContext context,
    String message,
    int cartCount,
  ) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'VIEW CART ($cartCount)',
          textColor: Colors.white,
          onPressed: () => navigateToCart(context, replace: true),
        ),
      ),
    );
  }

  /// Show error message with sign in option
  static void showSignInMessage(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'SIGN IN',
          textColor: Colors.white,
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/signin');
          },
        ),
      ),
    );
  }
}
