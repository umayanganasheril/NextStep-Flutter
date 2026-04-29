import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth_background.dart';
import '../../widgets/logo_widget.dart';
import '../navigation/main_navigation.dart';
import '../profile/profile_setup_screen.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // 5 second splash delay as requested
    await Future.delayed(const Duration(seconds: 5));
    
    if (!mounted) return;
    
    final auth = context.read<AuthProvider>();
    
    // Auth checking might still be loading, wait for it if necessary
    if (auth.isLoading) {
      // Small loop to wait for auth initialization if it takes longer than 5s
      while (auth.isLoading && mounted) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
    
    if (!mounted) return;

    if (auth.isAuthenticated) {
      if (auth.user?.profileComplete == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ProfileSetupScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const AuthBackground(
      child: Center(
        child: LogoWidget(size: 150),
      ),
    );
  }
}
