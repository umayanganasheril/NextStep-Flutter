import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../careers/career_paths_screen.dart';
import '../internships/internship_listing_screen.dart';
import '../profile/profile_view_screen.dart';
import 'widgets/nav_item.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;

  const MainNavigation({super.key, this.initialIndex = 0});

  /// Static method to switch tabs from child widgets
  static void switchTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<MainNavigationState>();
    state?.switchToTab(index);
  }

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    HomeScreen(),
    CareerPathsScreen(),
    InternshipListingScreen(),
    ProfileViewScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void switchToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                NavItem(
                  index: 0,
                  activeIcon: Icons.home_rounded,
                  icon: Icons.home_outlined,
                  label: 'Home',
                  isActive: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                NavItem(
                  index: 1,
                  activeIcon: Icons.work_rounded,
                  icon: Icons.work_outline_rounded,
                  label: 'Careers',
                  isActive: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                NavItem(
                  index: 2,
                  activeIcon: Icons.business_center_rounded,
                  icon: Icons.business_center_outlined,
                  label: 'Internship',
                  isActive: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                NavItem(
                  index: 3,
                  activeIcon: Icons.person_rounded,
                  icon: Icons.person_outline_rounded,
                  label: 'Profile',
                  isActive: _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
