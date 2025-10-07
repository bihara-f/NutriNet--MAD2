import 'package:flutter/material.dart';
import 'sign_in_page.dart';

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    // Always start with SignIn page - simple and reliable
    return const SignInPage();
  }
}
