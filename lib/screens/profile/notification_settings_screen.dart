import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/settings_tile.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text('Notifications', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SettingsTile(
            icon: Icons.notifications_active_outlined,
            title: 'Push Notifications',
            subtitle: 'Get real-time updates',
            onTap: () {},
            trailing: Switch.adaptive(
              value: _pushNotifications,
              onChanged: (val) => setState(() => _pushNotifications = val),
              activeColor: AppTheme.primaryBlue,
            ),
          ),
          const Divider(),
          SettingsTile(
            icon: Icons.email_outlined,
            title: 'Email Notifications',
            subtitle: 'Weekly career insights',
            onTap: () {},
            trailing: Switch.adaptive(
              value: _emailNotifications,
              onChanged: (val) => setState(() => _emailNotifications = val),
              activeColor: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}
