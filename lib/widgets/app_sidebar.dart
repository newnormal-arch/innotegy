import 'package:flutter/material.dart';
import 'package:innotegy/screens/authentication_screen/sign_in_screen.dart';
import 'package:innotegy/screens/consultant/manager_dashboard_screen.dart';
import 'package:innotegy/screens/consultant/users_screen.dart';
import 'package:innotegy/screens/farm/farm_screen.dart';
import 'package:innotegy/screens/farmer/farmer_dashboard_screen.dart';
import 'package:innotegy/screens/tasks/task_management_screen.dart';
import '../services/authentication_service.dart';

/// Reusable Sidebar Content Component
class AppSidebarContent
    extends
        StatelessWidget {
  /// The identifier of the currently active screen/route.
  /// Options: 'Dashboard', 'Consultancy', 'Users', 'Tasks', 'Reports', 'Settings', 'Farm Details'
  final String activeRoute;

  const AppSidebarContent({
    super.key,
    this.activeRoute = 'Dashboard',
  });

  Future<
    void
  >
  _handleLogout(
    BuildContext context,
  ) async {
    try {
      final authService = AuthenticationService();
      await authService.signOut();

      if (!context.mounted) return;

      // Navigate back to Sign In and clear route history
      Navigator.of(
        context,
      ).pushAndRemoveUntil(
        MaterialPageRoute(
          builder:
              (
                context,
              ) => const SignInScreen(),
        ),
        (
          route,
        ) => false,
      );
    } catch (
      e
    ) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Error signing out: ${e.toString()}',
          ),
        ),
      );
    }
  }

  void _navigateTo(
    BuildContext context,
    Widget screen,
  ) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (
              context,
            ) => screen,
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: Color(
              0xFFEFEFEF,
            ),
          ),
        ),
      ),
      child: Column(
        children: [
          // Main Scrollable Sidebar Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 12,
              ),
              children: [
                _SidebarItem(
                  icon: Icons.grid_view_rounded,
                  label: 'Dashboard',
                  isActive:
                      activeRoute ==
                      'Dashboard',
                  onTap: () => _navigateTo(
                    context,
                    const FarmerDashboardScreen(),
                  ),
                ),
                _SidebarItem(
                  icon: Icons.business_center_outlined,
                  label: 'Consultancy',
                  isActive:
                      activeRoute ==
                      'Consultancy',
                  onTap: () => _navigateTo(
                    context,
                    const ManagerDashboardScreen(),
                  ),
                ),
                _SidebarItem(
                  icon: Icons.people_alt_outlined,
                  label: 'Users',
                  isActive:
                      activeRoute ==
                      'Users',
                  onTap: () => _navigateTo(
                    context,
                    const UsersScreen(),
                  ),
                ),
                _SidebarItem(
                  icon: Icons.task_alt_outlined,
                  label: 'Tasks',
                  isActive:
                      activeRoute ==
                      'Tasks',
                  onTap: () => _navigateTo(
                    context,
                    const TaskManagementScreen(),
                  ),
                ),
                _SidebarItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Reports',
                  isActive:
                      activeRoute ==
                      'Reports',
                  onTap: () {},
                ),
                _SidebarItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  isActive:
                      activeRoute ==
                      'Settings',
                  onTap: () {},
                ),
                _SidebarItem(
                  icon: Icons.map_outlined,
                  label: 'Farm Details',
                  isActive:
                      activeRoute ==
                      'Farm Details',
                  onTap: () => _navigateTo(
                    context,
                    const FarmScreen(),
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            height: 1,
            color: Color(
              0xFFEFEFEF,
            ),
          ),

          // Pinned Logout Option at the Bottom
          Padding(
            padding: const EdgeInsets.all(
              12.0,
            ),
            child: ListTile(
              dense: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  8,
                ),
              ),
              leading: const Icon(
                Icons.logout_rounded,
                size: 20,
                color: Colors.red,
              ),
              title: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              onTap: () => _handleLogout(
                context,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable Mobile Drawer Wrapper
class AppSidebarDrawer
    extends
        StatelessWidget {
  final String activeRoute;

  const AppSidebarDrawer({
    super.key,
    required this.activeRoute,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Drawer(
      child: SafeArea(
        child: AppSidebarContent(
          activeRoute: activeRoute,
        ),
      ),
    );
  }
}

/// Individual Navigation Tile Widget
class _SidebarItem
    extends
        StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 4,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(
                0xFFF2F2F2,
              )
            : Colors.transparent,
        borderRadius: BorderRadius.circular(
          8,
        ),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          icon,
          size: 20,
          color: isActive
              ? Colors.black
              : Colors.grey[600],
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive
                ? FontWeight.bold
                : FontWeight.w500,
            color: isActive
                ? Colors.black
                : Colors.grey[700],
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
