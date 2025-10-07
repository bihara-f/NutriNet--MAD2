import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'app_initializer.dart';
import 'sign_in_page.dart';
import 'home_page.dart';

void main() async {
  // Ensure widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 Starting NutriNet App with SQLite support...');
  print('🌐 API Service ready for Laravel connection');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final appState = AppState();
        // Initialize SQLite data and network monitoring in the background
        appState.initialize().then((_) {
          // Initialize network monitoring after app state is ready
          appState.initializeNetworkMonitoring();
        });
        return appState;
      },
      child: MaterialApp(
        title: 'NutriNet',

        // Light theme
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
        ),

        // Dark theme
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.black,
        ),

        // Switch to mobile settings theme colour
        themeMode: ThemeMode.system,

        home: const AppInitializer(),
        routes: {
          '/signin': (context) => const SignInPage(),
          '/home': (context) => const HomePage(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
