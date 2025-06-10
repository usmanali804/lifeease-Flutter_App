import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/data/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../home_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.currentUser != null) {
          return const HomePage();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
