import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:innotegy/constants.dart';
import 'package:innotegy/screens/auth_screen.dart';
import 'package:innotegy/screens/consultant/main_dashboard.dart';
import 'package:innotegy/screens/consultant/manage_consultant_dashboard.dart';
import 'package:innotegy/screens/farm_list_screen.dart';
import 'package:innotegy/screens/farmer/manage_farmers_dashboard.dart';
import 'package:innotegy/services/auth_service.dart';

class ConsultantDashboard
    extends
        StatefulWidget {
  const ConsultantDashboard({
    super.key,
  });

  @override
  State<
    ConsultantDashboard
  >
  createState() => _ConsultantDashboardState();
}

class _ConsultantDashboardState
    extends
        State<
          ConsultantDashboard
        > {
  final _controller = SideMenuController();
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Mirror selections to a PageView (or any router)
    _controller.addListener(
      () {
        _pageController.jumpToPage(
          _controller.currentIndex,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(
            8.0,
          ),
          child: const TextField(
            decoration: InputDecoration(
              hintText: 'Search...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(
                    8.0,
                  ),
                ),
              ),
            ),
          ),
        ),
        leadingWidth: 300,
        titleSpacing: 0,
        centerTitle: true,
        title: Image.asset(
          'assets/logo.png',
          width: 150,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 16.0,
            ),
            child: CircleAvatar(),
          ),
        ],
      ),
      body: SafeArea(
        child: Row(
          children: [
            SideMenu(
              controller: _controller,
              theme: SideMenuThemeData(
                selectedItemDecoration: BoxDecoration(
                  color: backgroundGreenColor,
                  borderRadius: BorderRadius.circular(
                    8,
                  ),
                ),
                selectedTitleStyle: TextStyle(
                  color: Colors.white,
                ),
                selectedIconColor: Colors.white,
              ),
              footer: TextButton.icon(
                onPressed: () async {
                  EasyLoading.show(
                    status: 'Signing Out...',
                  );
                  try {
                    await authService.value.signOut().then(
                      (
                        value,
                      ) {
                        Navigator.of(
                          context,
                        ).pushReplacement(
                          MaterialPageRoute(
                            builder:
                                (
                                  context,
                                ) => AuthScreen(),
                          ),
                        );
                        print(
                          'User signed out successfully',
                        );
                      },
                    );

                    EasyLoading.dismiss();
                  } catch (
                    e
                  ) {
                    print(
                      'Error signing out: $e',
                    );
                    EasyLoading.showError(
                      'Error signing out. Please try again.',
                    );
                  }
                },
                label: Text(
                  'Logout',
                ),
                icon: Icon(
                  Icons.logout_rounded,
                ),
              ),
              items: [
                SideMenuItem(
                  title: 'Dashboard',
                  icon: const Icon(
                    Icons.dashboard_rounded,
                  ),
                  onTap:
                      (
                        index,
                        controller,
                      ) => controller.goTo(
                        index,
                      ),
                ),
                SideMenuItem(
                  title: 'Farmers',
                  icon: const Icon(
                    Icons.person_sharp,
                  ),
                  onTap:
                      (
                        index,
                        controller,
                      ) => controller.goTo(
                        index,
                      ),
                ),
                SideMenuItem(
                  title: 'Managers',
                  icon: const Icon(
                    Icons.person_sharp,
                  ),
                  onTap:
                      (
                        index,
                        controller,
                      ) => controller.goTo(
                        index,
                      ),
                ),
                SideMenuItem(
                  title: 'Farms',
                  icon: const Icon(
                    Icons.person_sharp,
                  ),
                  onTap:
                      (
                        index,
                        controller,
                      ) => controller.goTo(
                        index,
                      ),
                ),
                SideMenuItem(
                  title: 'Settings',
                  icon: const Icon(
                    Icons.settings_rounded,
                  ),
                  onTap:
                      (
                        index,
                        controller,
                      ) => controller.goTo(
                        index,
                      ),
                ),
              ],
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  MainConsultantDashboard(),
                  ManageFarmersDashboard(),
                  ManageConsultantDashboard(),
                  FarmListScreen(),
                  // FarmDashboard(),
                  const Center(
                    child: Text(
                      'Settings',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
