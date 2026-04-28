import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../navigation/main_navigation.dart';
import '../profile/profile_setup_screen.dart';
import 'splash_screen.dart'; // Using the new Splash Screen

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Return SplashScreen instead of a custom checking logic here.
    // The SplashScreen handles the 5s delay and navigation based on auth state.
    return const SplashScreen();
  }
}
