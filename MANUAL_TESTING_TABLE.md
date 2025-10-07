# NutriNet Flutter App - Manual Testing Table

## Project Overview
**App Name:** NutriNet - Fitness & Nutrition Platform  
**Platform:** Flutter (Android/iOS/Web)  
**Testing Date:** October 7, 2025  
**Tester:** Manual Testing Team  

---

## Manual Testing Table

| Test ID | Test Description | Action | Expected Output | Actual Output | Pass/Fail |
|---------|------------------|--------|-----------------|---------------|-----------|
| **AUTHENTICATION MODULE** |
| T001 | Sign Up - Valid Data | Navigate to Sign Up → Fill all fields (Name: "John Doe", Email: "john@test.com", Password: "Pass123!", Contact: "1234567890", Username: "johndoe", Gender: "Male") → Check Terms → Tap Sign Up | Registration successful, navigate to Home page, show success message | To be tested | Pending |
| T002 | Sign Up - Invalid Email | Navigate to Sign Up → Enter invalid email "invalidemail" → Fill other fields → Tap Sign Up | Show email validation error, stay on Sign Up page | To be tested | Pending |
| T003 | Sign Up - Password Mismatch | Navigate to Sign Up → Enter different passwords in Password and Confirm Password → Tap Sign Up | Show password mismatch error message | To be tested | Pending |
| T004 | Sign Up - Empty Required Fields | Navigate to Sign Up → Leave Name field empty → Tap Sign Up | Show validation error for required fields | To be tested | Pending |
| T005 | Sign Up - Unchecked Terms | Navigate to Sign Up → Fill all fields but don't check Terms → Tap Sign Up | Show error "Please accept terms and conditions" | To be tested | Pending |
| T006 | Sign Up - Invalid Phone | Navigate to Sign Up → Enter phone "123" → Fill other fields → Tap Sign Up | Show phone validation error | To be tested | Pending |
| T007 | Sign In - Valid Credentials | Navigate to Sign In → Enter registered email/password → Tap Sign In | Login successful, navigate to Home page, show success message | To be tested | Pending |
| T008 | Sign In - Invalid Email Format | Navigate to Sign In → Enter "invalidemail" → Enter password → Tap Sign In | Show email format validation error | To be tested | Pending |
| T009 | Sign In - Empty Fields | Navigate to Sign In → Leave fields empty → Tap Sign In | Show validation errors for both fields | To be tested | Pending |
| T010 | Sign In - Wrong Credentials | Navigate to Sign In → Enter "wrong@email.com" and "wrongpass" → Tap Sign In | Show "Invalid credentials" error message | To be tested | Pending |
| T011 | Password Visibility Toggle | Navigate to Sign In → Tap eye icon on password field | Password text should toggle between hidden/visible | To be tested | Pending |
| T012 | Navigation Between Auth Pages | From Sign In → Tap "Sign Up" link → From Sign Up → Tap "Sign In" link | Should navigate between Sign In and Sign Up pages smoothly | To be tested | Pending |
| **HOME PAGE & NAVIGATION** |
| T013 | App Launch | Open NutriNet app | App loads with Sign In page, NutriNet logo visible, no crashes | To be tested | Pending |
| T014 | Bottom Navigation | After login → Tap each bottom tab (Home, Services, Packages, Profile) | Each tab loads respective page content | To be tested | Pending |
| T015 | Home Page Content | Navigate to Home tab | Shows welcome content, "Start Diet Plan" button, app branding | To be tested | Pending |
| T016 | Cart Icon Display | From Home page → Check app bar | Cart icon visible in top-right with item count badge (if items exist) | To be tested | Pending |
| T017 | Cart Icon Navigation | From Home page → Tap cart icon | Navigate to Cart page | To be tested | Pending |
| T018 | Start Diet Plan Button | From Home page → Tap "Start Diet Plan" button | Navigate to Diet Plan List page | To be tested | Pending |
| **PACKAGES MODULE** |
| T019 | Package List Loading | Navigate to Packages tab | Display list of fitness packages with images, titles, prices | To be tested | Pending |
| T020 | Package Grid/List View | In Packages page → Check layout | Packages displayed in grid format with proper spacing | To be tested | Pending |
| T021 | Package Detail Navigation | In Packages → Tap on any package | Navigate to Package Detail page with full information | To be tested | Pending |
| T022 | Package Detail Content | In Package Detail page | Shows package image, title, price, description, features, reviews | To be tested | Pending |
| T023 | Add to Cart - Logged In | In Package Detail → Tap "Add to Cart" (while logged in) | Show success message, cart count increases, navigate back option | To be tested | Pending |
| T024 | Add to Cart - Not Logged In | Logout → In Package Detail → Tap "Add to Cart" | Show "Please sign in to add items to cart" message | To be tested | Pending |
| T025 | Package Price Display | Check various packages | All prices shown in "XXX LKR" format consistently | To be tested | Pending |
| T026 | Package Images Loading | Navigate through packages | All package images load properly without broken links | To be tested | Pending |
| T027 | Package Rating Display | In Package Detail | Shows rating stars and review count properly | To be tested | Pending |
| **DIET PLANS MODULE** |
| T028 | Diet Plan List Loading | Navigate to Diet Plans or tap "Start Diet Plan" | Display list of available diet plans with details | To be tested | Pending |
| T029 | Diet Plan Categories | In Diet Plan List | Shows different categories (Weight Loss, Muscle Gain, etc.) | To be tested | Pending |
| T030 | Diet Plan Detail Navigation | In Diet Plan List → Tap any plan | Navigate to Diet Plan Detail page | To be tested | Pending |
| T031 | Diet Plan Detail Content | In Diet Plan Detail page | Shows plan details, duration, price, meal information | To be tested | Pending |
| T032 | Diet Plan Filtering | In Diet Plan List → Use filter options (if available) | Filter plans by category, duration, or price | To be tested | Pending |
| **SHOPPING CART MODULE** |
| T033 | Empty Cart Display | Navigate to Cart (when empty) | Shows "Your cart is empty" message and "Continue Shopping" button | To be tested | Pending |
| T034 | Cart Item Display | Add items to cart → Navigate to Cart | Shows item details: image, title, price, quantity controls | To be tested | Pending |
| T035 | Quantity Increase | In Cart → Tap "+" button on any item | Quantity increases by 1, total price updates | To be tested | Pending |
| T036 | Quantity Decrease | In Cart → Tap "-" button on any item | Quantity decreases by 1, total price updates | To be tested | Pending |
| T037 | Quantity Minimum Limit | In Cart → Decrease quantity to 1 → Tap "-" again | Quantity stays at 1 or shows confirmation to remove item | To be tested | Pending |
| T038 | Remove Item from Cart | In Cart → Tap remove/delete button | Item removed from cart, total updated, success message | To be tested | Pending |
| T039 | Cart Total Calculation | Add multiple items → Check cart total | Total correctly calculates (quantity × price) for all items | To be tested | Pending |
| T040 | Cart Persistence | Add items → Close app → Reopen app → Check cart | Cart items persist across app sessions | To be tested | Pending |
| T041 | Checkout Navigation | In Cart with items → Tap "Checkout" or "Proceed to Payment" | Navigate to Payment page with cart data | To be tested | Pending |
| **USER PROFILE MODULE** |
| T042 | Profile Page Access | Navigate to Profile tab | Shows user profile information and options | To be tested | Pending |
| T043 | Profile Information Display | In Profile page | Shows user name, email, join date, profile picture placeholder | To be tested | Pending |
| T044 | Profile Picture Options | In Profile → Tap profile picture or camera icon | Shows options: "Camera", "Gallery" | To be tested | Pending |
| T045 | Camera Access | In Profile → Choose "Camera" option | Opens camera app for taking photo (with permission) | To be tested | Pending |
| T046 | Location Update | In Profile → Tap "Update Address" | Shows location options: "Use Current Location", "Enter Manually" | To be tested | Pending |
| T047 | Current Location Access | In Profile → Choose "Use Current Location" | Requests location permission and gets current address | To be tested | Pending |
| T048 | Birth Date Selection | In Profile → Tap "Set Birth Date" | Opens date picker, allows selection of birth date | To be tested | Pending |
| T049 | Profile Data Persistence | Update profile info → Logout → Login again | Profile information persists correctly | To be tested | Pending |
| T050 | Logout Functionality | In Profile → Tap "Logout" | Shows confirmation dialog, then logout and return to Sign In | To be tested | Pending |
| **SQLITE DATABASE MODULE** |
| T051 | SQLite Test Page Access | In Profile → Tap "SQLite Database Test" | Navigate to SQLite Test page | To be tested | Pending |
| T052 | SQLite Insert User | In SQLite Test → Tap "Save User" | Inserts test user, shows success message, updates user list | To be tested | Pending |
| T053 | SQLite View Users | In SQLite Test → Tap "View Users" | Displays list of stored users with details | To be tested | Pending |
| T054 | SQLite Clear Users | In SQLite Test → Tap "Clear All Users" | Removes all users, shows empty state | To be tested | Pending |
| T055 | SQLite Offline Operation | Turn off internet → Use SQLite features | All SQLite operations work without internet | To be tested | Pending |
| T056 | SQLite Data Persistence | Add users → Close app → Reopen → Check SQLite test | Users persist in local database | To be tested | Pending |
| **API INTEGRATION MODULE** |
| T057 | API Demo Page Access | In Profile → Tap "Laravel API Demo" | Navigate to API Demo page | To be tested | Pending |
| T058 | API Connection Test | In API Demo → Tap "Test Connection" | Shows connection status to Laravel backend | To be tested | Pending |
| T059 | API Package Test | In API Demo → Tap "Test Packages" | Attempts to fetch packages from API, shows result | To be tested | Pending |
| T060 | API Diet Plans Test | In API Demo → Tap "Test Diet Plans" | Attempts to fetch diet plans from API, shows result | To be tested | Pending |
| T061 | API All Tests | In API Demo → Tap "Run All Tests" | Runs comprehensive API tests, shows results summary | To be tested | Pending |
| **DEVICE CAPABILITIES MODULE** |
| T062 | Camera Permission | Trigger camera access | App requests camera permission properly | To be tested | Pending |
| T063 | Location Permission | Trigger location access | App requests location permission properly | To be tested | Pending |
| T064 | Permission Denial Handling | Deny camera/location permission | App handles denial gracefully with appropriate messages | To be tested | Pending |
| T065 | Battery Monitoring | Check app state for battery info | App can access and display battery level information | To be tested | Pending |
| **UI/UX & RESPONSIVENESS** |
| T066 | App Theme Consistency | Navigate through all pages | Consistent color scheme (green/orange theme) throughout | To be tested | Pending |
| T067 | Loading States | Perform actions that require loading | Shows appropriate loading indicators/spinners | To be tested | Pending |
| T068 | Error Messages | Trigger various errors | Error messages are clear, helpful, and user-friendly | To be tested | Pending |
| T069 | Success Messages | Perform successful actions | Success messages are clear and appropriately timed | To be tested | Pending |
| T070 | Button Interactions | Tap various buttons throughout app | All buttons respond with visual feedback (ripple effects) | To be tested | Pending |
| T071 | Scroll Performance | Scroll through long lists (packages, diet plans) | Smooth scrolling without lag or stuttering | To be tested | Pending |
| T072 | Landscape Orientation | Rotate device to landscape mode | UI adapts properly to landscape orientation | To be tested | Pending |
| T073 | Back Navigation | Use device back button on various screens | Proper navigation hierarchy, no app crashes | To be tested | Pending |
| **DATA VALIDATION & EDGE CASES** |
| T074 | Very Long Text Input | Enter very long text in form fields | App handles long inputs gracefully, shows appropriate limits | To be tested | Pending |
| T075 | Special Characters | Enter special characters in text fields | App validates and handles special characters properly | To be tested | Pending |
| T076 | Network Loss During Operation | Turn off internet during API operations | App shows network error, falls back to offline mode | To be tested | Pending |
| T077 | App Background/Foreground | Put app in background → Return to foreground | App resumes correctly, maintains state | To be tested | Pending |
| T078 | Memory Management | Use app extensively → Check for memory leaks | App performs consistently without memory issues | To be tested | Pending |
| T079 | Multiple Cart Operations | Rapidly add/remove multiple cart items | App handles rapid operations without crashes or data corruption | To be tested | Pending |
| T080 | Concurrent User Operations | Perform multiple operations simultaneously | App handles concurrent operations properly | To be tested | Pending |
| **BUSINESS LOGIC TESTING** |
| T081 | Price Calculations | Add items with different quantities | All price calculations are accurate (no rounding errors) | To be tested | Pending |
| T082 | Cart Item Limits | Try to add many items to cart | App handles large cart gracefully | To be tested | Pending |
| T083 | User Session Management | Login → Use app → Wait (test session timeout) | Session management works correctly | To be tested | Pending |
| T084 | Data Synchronization | Make changes offline → Go online | Data syncs properly between local and remote | To be tested | Pending |
| T085 | Multi-user Support | Login with different users | Each user has separate cart and profile data | To be tested | Pending |

---

## Test Environment
- **Flutter Version:** 3.29.1
- **Target Platforms:** Android (API 36), iOS, Web
- **Test Devices:** Android Emulator, Physical devices, Web browsers
- **Database:** SQLite (local), Laravel API (remote)

## Test Execution Notes
1. Execute tests in order for logical flow
2. Reset app state between major test modules
3. Test both online and offline scenarios
4. Verify data persistence across app sessions
5. Check for memory leaks during extended testing
6. Test on different screen sizes and orientations

## Severity Levels
- **High:** App crashes, data loss, security issues
- **Medium:** Feature not working, poor UX
- **Low:** Minor UI issues, cosmetic problems

---

**Total Test Cases:** 85  
**Modules Covered:** 10  
**Priority:** All tests should pass for production deployment