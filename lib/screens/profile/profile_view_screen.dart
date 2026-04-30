import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'profile_edit_screen.dart';
import 'profile_dashboard_screen.dart';
import 'notification_settings_screen.dart';
import 'privacy_settings_screen.dart';
import '../../widgets/settings_tile.dart';

class ProfileViewScreen extends StatelessWidget {
  const ProfileViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryBlue, Color(0xFF64B5F6)],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                      child: user?.photoURL == null ? const Icon(Icons.person, size: 40) : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.displayName ?? 'User',
                      style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 20),
              SettingsTile(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                subtitle: 'Change your personal info',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileEditScreen())),
              ),
              SettingsTile(
                icon: Icons.dashboard_outlined,
                title: 'Statistics Dashboard',
                subtitle: 'View your career progress',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileDashboardScreen())),
              ),
              SettingsTile(
                icon: Icons.notifications_none,
                title: 'Notifications',
                subtitle: 'Manage your alerts',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationSettingsScreen())),
              ),
              SettingsTile(
                icon: Icons.security_outlined,
                title: 'Privacy',
                subtitle: 'Security and data settings',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacySettingsScreen())),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
