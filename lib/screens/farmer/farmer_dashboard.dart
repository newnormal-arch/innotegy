import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:innotegy/constants.dart';
import 'package:innotegy/models/farm_model.dart';
import 'package:innotegy/screens/auth_screen.dart';
import 'package:innotegy/services/auth_service.dart';
import 'package:innotegy/services/kml_service.dart';
import 'package:innotegy/widgets/allocated_farm_card.dart';

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

  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  final String _myMapsId = '16V-t8nIWuYbt5LpNzJYxa_TDshAZCiA';
  List<
    FarmModel
  >
  _farms = [];
  bool _isLoading = true;
  String? _errorMessage;

  Future<
    void
  >
  _loadAllFarmsFromMap() async {
    setState(
      () {
        _isLoading = true;
        _errorMessage = null;
      },
    );

    try {
      final fetchedFarms = await KmlService.fetchMyMapsFarms(
        _myMapsId,
      );
      setState(
        () {
          _farms = fetchedFarms;
          _isLoading = false;
        },
      );
    } catch (
      e
    ) {
      setState(
        () {
          _errorMessage = e.toString().replaceAll(
            'Exception: ',
            '',
          );
          _isLoading = false;
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAllFarmsFromMap();
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
        leading: const Padding(
          padding: EdgeInsets.all(
            8.0,
          ),
          child: TextField(
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
        actions: const [
          Padding(
            padding: EdgeInsets.only(
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
                                ) => const AuthScreen(),
                          ),
                        );
                      },
                    );

                    EasyLoading.dismiss();
                  } catch (
                    e
                  ) {
                    EasyLoading.showError(
                      'Error signing out. Please try again.',
                    );
                  }
                },
                label: const Text(
                  'Logout',
                ),
                icon: const Icon(
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
                  StreamBuilder<
                    DocumentSnapshot<
                      Map<
                        String,
                        dynamic
                      >
                    >
                  >(
                    stream:
                        _uid !=
                            null
                        ? FirebaseFirestore.instance
                              .collection(
                                'farmer',
                              )
                              .doc(
                                _uid,
                              )
                              .snapshots()
                        : null,
                    builder:
                        (
                          context,
                          snapshot,
                        ) {
                          final data = snapshot.data?.data();
                          final String allocatedFarm =
                              data?['allocatedFarm'] ??
                              'No farm allocated';
                          final String farmerName =
                              data?['fullName'] ??
                              'Farmer';

                          // Handles string status fields like 'Active', 'Inactive', 'status', or 'isActive'
                          final String status =
                              (data?['isActive'] ??
                                      data?['status'] ??
                                      'Inactive')
                                  .toString();

                          return SingleChildScrollView(
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
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Farmer Dashboard',
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "Good morning, $farmerName. Here's what's happening on your farms today.",
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          // Status Pill accepts String parameter directly
                                          _buildStatusPill(
                                            status,
                                          ),
                                          const SizedBox(
                                            width: 16,
                                          ),
                                          ElevatedButton(
                                            onPressed: () {},
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: primaryGreenColor,
                                              padding: const EdgeInsets.symmetric(
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
                                          const SizedBox(
                                            width: 16,
                                          ),
                                          // ElevatedButton(
                                          //   onPressed: () {},
                                          //   style: ElevatedButton.styleFrom(
                                          //     backgroundColor: primaryGreenColor,
                                          //     padding: const EdgeInsets.symmetric(
                                          //       horizontal: 40,
                                          //       vertical: 12,
                                          //     ),
                                          //     shape: RoundedRectangleBorder(
                                          //       borderRadius: BorderRadius.circular(
                                          //         8,
                                          //       ),
                                          //     ),
                                          //   ),
                                          //   child: const Text(
                                          //     'Add Task',
                                          //     style: TextStyle(
                                          //       fontWeight: FontWeight.w600,
                                          //       color: Colors.white,
                                          //     ),
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 24,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 300,
                                        height: 150,
                                        child: Card(
                                          child: Padding(
                                            padding: const EdgeInsets.all(
                                              16.0,
                                            ),
                                            child: Column(
                                              children: const [
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
                                            padding: const EdgeInsets.all(
                                              16.0,
                                            ),
                                            child: Column(
                                              children: const [
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
                                            padding: const EdgeInsets.all(
                                              16.0,
                                            ),
                                            child: Column(
                                              children: const [
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
                                            padding: const EdgeInsets.all(
                                              16.0,
                                            ),
                                            child: Column(
                                              children: const [
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
                                      padding: const EdgeInsets.all(
                                        16.0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Quick Actions',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          const Text(
                                            'Manage your farm activities and tasks with ease using our quick action buttons below.',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(
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
                                              const SizedBox(
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
                                              const SizedBox(
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

                                  ListView(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    children: _farms.map(
                                      (
                                        farm,
                                      ) {
                                        if (farm.name ==
                                            allocatedFarm) {
                                          return Align(
                                            alignment: Alignment.centerLeft,
                                            child: SizedBox(
                                              width: 450,
                                              child: AllocatedFarmCard(
                                                farm: farm,
                                              ),
                                            ),
                                          );
                                        } else {
                                          return const SizedBox.shrink();
                                        }
                                      },
                                    ).toList(),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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

  // Helper widget to render status pill from string
  Widget _buildStatusPill(
    String status,
  ) {
    final bool isActive =
        status.trim().toLowerCase() ==
        'active';
    final color = isActive
        ? Colors.green
        : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(
          0.12,
        ),
        borderRadius: BorderRadius.circular(
          20,
        ),
        border: Border.all(
          color: color.withOpacity(
            0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Text(
            status,
            style: TextStyle(
              color: color.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
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
            title: const Text(
              'Add New Task',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Task Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const TextField(
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
                      child: const Text(
                        'Cancel',
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pop();
                      },
                      child: const Text(
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
