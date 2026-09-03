import 'package:flutter/material.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:innotegy/constants.dart';
import 'package:innotegy/screens/auth_screen.dart';
import 'package:innotegy/services/auth_service.dart';

class FarmerDashboard
    extends
        StatefulWidget {
  const FarmerDashboard({
    super.key,
  });

  @override
  State<
    FarmerDashboard
  >
  createState() => _FarmerDashboardState();
}

class _FarmerDashboardState
    extends
        State<
          FarmerDashboard
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
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(
                        16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 80,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Farmer Dashboard',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Good morning, Arthur. Here's what's happening on your farms today.",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryGreenColor,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 40,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          8,
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      'Log Activity',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryGreenColor,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 40,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          8,
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      'Add Task',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 300,
                                height: 150,
                                child: Card(
                                  child: Padding(
                                    padding: EdgeInsets.all(
                                      16.0,
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Total Area',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          '90 ha',
                                          style: TextStyle(
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 300,
                                height: 150,
                                child: Card(
                                  child: Padding(
                                    padding: EdgeInsets.all(
                                      16.0,
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Active Alerts',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          '03',
                                          style: TextStyle(
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 300,
                                height: 150,
                                child: Card(
                                  child: Padding(
                                    padding: EdgeInsets.all(
                                      16.0,
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Completed Tasks',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          '18/24',
                                          style: TextStyle(
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 300,
                                height: 150,
                                child: Card(
                                  child: Padding(
                                    padding: EdgeInsets.all(
                                      16.0,
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          'AVG. Soil Moisture',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          '42%',
                                          style: TextStyle(
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Card(
                            child: Padding(
                              padding: EdgeInsets.all(
                                16.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Quick Actions',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    'Manage your farm activities and tasks with ease using our quick action buttons below.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          child: const Text(
                                            'Manage Crops',
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 16,
                                      ),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          child: const Text(
                                            'View Reports',
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 16,
                                      ),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            _newTaskDialog(
                                              context,
                                            );
                                          },
                                          child: const Text(
                                            'Schedule Tasks',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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

  Future<
    dynamic
  >
  _newTaskDialog(
    BuildContext context,
  ) {
    return showDialog(
      context: context,
      builder:
          (
            context,
          ) => AlertDialog(
            title: Text(
              'Add New Task',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Task Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Due Date',
                    border: OutlineInputBorder(),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pop();
                      },
                      child: Text(
                        'Cancel',
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Handle task creation logic here
                        Navigator.of(
                          context,
                        ).pop();
                      },
                      child: Text(
                        'Add Task',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }
}
