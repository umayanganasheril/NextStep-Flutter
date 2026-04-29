import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/settings_tile.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text('Privacy & Security', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SettingsTile(
            icon: Icons.lock_outline,
            title: 'Account Privacy',
            subtitle: 'Manage who can see your profile',
            onTap: () {},
          ),
          const Divider(),
          SettingsTile(
            icon: Icons.security_outlined,
            title: 'Two-Factor Authentication',
            subtitle: 'Add an extra layer of security',
            onTap: () {},
          ),
          const Divider(),
          SettingsTile(
            icon: Icons.remove_red_eye_outlined,
            title: 'Profile Visibility',
            subtitle: 'Control search engine visibility',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
