# Shopping Cart System - NutriNet App

## Overview
The NutriNet app now includes a comprehensive shopping cart system that allows users to:
- Add fitness packages to cart
- View and manage cart items
- Adjust quantities
- Proceed to payment
- Complete purchases

## Features Implemented

### 1. Shopping Cart State Management
- **AppState Provider**: Extended with cart functionality
- **Cart Methods**:
  - `addToCart(package)` - Add a package to cart
  - `removeFromCart(packageId)` - Remove package from cart
  - `updateCartItemQuantity(packageId, quantity)` - Update item quantity
  - `clearCart()` - Clear all cart items
  - `getCartTotal()` - Calculate total cart value
  - `getCartItemCount()` - Get total items in cart

### 2. Cart Page UI
- **Location**: `lib/pages/cart_page.dart`
- **Features**:
  - Modern gradient design matching app theme
  - Empty cart state with motivational message
  - Cart item list with images and details
  - Quantity controls (+ / - buttons)
  - Real-time total calculation
  - Remove item functionality
  - Checkout button leading to payment

### 3. Cart Integration
- **Home Page**: Cart icon with badge showing item count
- **Package Detail**: Add to Cart and View Cart buttons
- **Payment Page**: Support for both individual and cart purchases

### 4. User Experience
- **Visual Feedback**: Cart badge updates in real-time
- **Navigation**: Seamless flow from browsing → cart → payment
- **Modern UI**: Consistent design with gradient backgrounds
- **Responsive**: Works on all screen sizes

## How to Use

### Adding Items to Cart
1. Browse packages on the home page
2. Tap on a package to view details
3. Click "Add to Cart" button
4. Cart badge updates automatically

### Managing Cart
1. Tap the cart icon in the app bar
2. View all cart items
3. Adjust quantities using + / - buttons
4. Remove items by tapping the remove button
5. View real-time total at the bottom

### Checkout Process
1. From cart page, tap "Proceed to Checkout"
2. Fill in payment details
3. Complete payment
4. Cart is automatically cleared on success

## Technical Implementation

### State Management
```dart
// Add to cart
Provider.of<AppState>(context, listen: false).addToCart(package);

// Get cart items
Consumer<AppState>(
  builder: (context, appState, child) {
    return Text('Cart: ${appState.getCartItemCount()}');
  },
)
```

### Navigation
```dart
// Navigate to cart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => CartPage()),
);

// Navigate to payment with cart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PaymentPage(cartItems: cartItems),
  ),
);
```

## Files Modified/Created

### New Files
- `lib/pages/cart_page.dart` - Complete cart interface

### Modified Files
- `lib/providers/app_state.dart` - Added cart state management
- `lib/home_page.dart` - Added cart icon with badge
- `lib/pages/package_detail_page.dart` - Added cart buttons
- `lib/payment_page.dart` - Added cart support

## Future Enhancements
- Cart persistence across app sessions
- Wishlist functionality
- Discount codes/coupons
- Multiple payment methods
- Order history
- Push notifications for cart abandonment

## MAD 2 Assignment Compliance
This shopping cart system demonstrates:
- ✅ State Management (Provider pattern)
- ✅ Navigation between screens
- ✅ UI/UX best practices
- ✅ Data persistence concepts
- ✅ Modern Flutter development patterns
- ✅ Real-world e-commerce functionality