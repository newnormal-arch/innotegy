import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:innotegy/models/farm_model.dart';
import 'package:innotegy/screens/authentication_screen/sign_in_screen.dart';
import 'package:innotegy/screens/farm/farm_details_screen.dart';
import 'package:innotegy/services/authentication_service.dart';
import 'package:innotegy/services/kml_service.dart';
import 'package:innotegy/widgets/app_sidebar.dart';

class FarmerDashboardScreen
    extends
        StatefulWidget {
  const FarmerDashboardScreen({
    super.key,
  });

  @override
  State<
    FarmerDashboardScreen
  >
  createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState
    extends
        State<
          FarmerDashboardScreen
        > {
  static const Color primaryColor = Color(
    0xFF1CB026,
  );
  final String _myMapsId = '16V-t8nIWuYbt5LpNzJYxa_TDshAZCiA';

  List<
    FarmModel
  >
  _allMyMapsFarms = [];
  bool _isLoadingFarms = true;

  @override
  void initState() {
    super.initState();
    _fetchMyMapsFarms();
  }

  Future<
    void
  >
  _fetchMyMapsFarms() async {
    try {
      final farms = await KmlService.fetchMyMapsFarms(
        _myMapsId,
      );
      if (mounted) {
        setState(
          () {
            _allMyMapsFarms = farms;
            _isLoadingFarms = false;
          },
        );
      }
    } catch (
      e
    ) {
      if (mounted) {
        setState(
          () => _isLoadingFarms = false,
        );
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final bool isDesktop =
        MediaQuery.of(
          context,
        ).size.width >=
        1024;
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser ==
        null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'User not authenticated.',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(
        0xFFF8F9FA,
      ),
      drawer: isDesktop
          ? null
          : const AppSidebarDrawer(
              activeRoute: 'Dashboard',
            ),
      body: Column(
        children: [
          const _TopNavBar(),
          Expanded(
            child: Row(
              children: [
                if (isDesktop)
                  const SizedBox(
                    width: 220,
                    child: AppSidebarContent(
                      activeRoute: 'Dashboard',
                    ),
                  ),
                Expanded(
                  child:
                      StreamBuilder<
                        DocumentSnapshot<
                          Map<
                            String,
                            dynamic
                          >
                        >
                      >(
                        stream: FirebaseFirestore.instance
                            .collection(
                              'users',
                            )
                            .doc(
                              currentUser.uid,
                            )
                            .snapshots(),
                        builder:
                            (
                              context,
                              snapshot,
                            ) {
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  _isLoadingFarms) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: primaryColor,
                                  ),
                                );
                              }

                              List<
                                String
                              >
                              assignedFarmNames = [];
                              if (snapshot.hasData &&
                                  snapshot.data!.exists) {
                                final data = snapshot.data!.data();
                                final rawFarms = data?['farms'];
                                if (rawFarms
                                    is List) {
                                  assignedFarmNames =
                                      List<
                                        String
                                      >.from(
                                        rawFarms,
                                      );
                                }
                              }

                              // Filter My Maps farms matching the assigned farm names
                              final userAssignedFarms = _allMyMapsFarms
                                  .where(
                                    (
                                      farm,
                                    ) => assignedFarmNames.contains(
                                      farm.name,
                                    ),
                                  )
                                  .toList();

                              // Sum dynamic total area in Hectares
                              final double totalAreaHectares = userAssignedFarms.fold(
                                0.0,
                                (
                                  sum,
                                  farm,
                                ) =>
                                    sum +
                                    farm.areaInHectares,
                              );

                              return SingleChildScrollView(
                                padding: const EdgeInsets.all(
                                  24.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _HeaderSection(),
                                    const SizedBox(
                                      height: 24,
                                    ),
                                    _MetricsGrid(
                                      assignedFarmsCount: userAssignedFarms.length,
                                      totalAreaHectares: totalAreaHectares,
                                    ),
                                    const SizedBox(
                                      height: 28,
                                    ),
                                    _MainContentArea(
                                      assignedFarms: userAssignedFarms,
                                    ),
                                  ],
                                ),
                              );
                            },
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dynamic Metric Cards Row
class _MetricsGrid
    extends
        StatelessWidget {
  final int assignedFarmsCount;
  final double totalAreaHectares;

  const _MetricsGrid({
    required this.assignedFarmsCount,
    required this.totalAreaHectares,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return LayoutBuilder(
      builder:
          (
            context,
            constraints,
          ) {
            final double width = constraints.maxWidth;
            final int crossAxisCount =
                width >
                    1100
                ? 4
                : (width >
                          600
                      ? 2
                      : 1);

            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.2,
              children: [
                _MetricCard(
                  title: 'TOTAL ALLOCATED AREA',
                  value: '${totalAreaHectares.toStringAsFixed(1)} Ha',
                  subtext: 'Across $assignedFarmsCount assigned farm(s)',
                  subtextColor: const Color(
                    0xFF1CB026,
                  ),
                  icon: Icons.square_foot_outlined,
                  iconColor: const Color(
                    0xFF1CB026,
                  ),
                ),
                const _MetricCard(
                  title: 'CROP HEALTH INDEX',
                  value: '94.2%',
                  subtext: '↑ +1.2% from last week',
                  subtextColor: Color(
                    0xFF1CB026,
                  ),
                  icon: Icons.eco_outlined,
                  iconColor: Color(
                    0xFF1CB026,
                  ),
                ),
                const _MetricCard(
                  title: 'ACTIVE ALERTS',
                  value: '03',
                  subtext: '↓ -2 resolved today',
                  subtextColor: Colors.red,
                  icon: Icons.warning_amber_rounded,
                  iconColor: Colors.black,
                ),
                const _MetricCard(
                  title: 'COMPLETED TASKS',
                  value: '18/24',
                  subtext: '• 75% completion rate',
                  subtextColor: Colors.grey,
                  icon: Icons.access_time_rounded,
                  iconColor: Colors.grey,
                ),
              ],
            );
          },
    );
  }
}

class _MetricCard
    extends
        StatelessWidget {
  final String title;
  final String value;
  final String subtext;
  final Color subtextColor;
  final IconData icon;
  final Color iconColor;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtext,
    required this.subtextColor,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          12,
        ),
        border: Border.all(
          color: const Color(
            0xFFEFEFEF,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                  letterSpacing: 0.5,
                ),
              ),
              Icon(
                icon,
                size: 18,
                color: iconColor,
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(
                0xFF1A1A1A,
              ),
            ),
          ),
          Text(
            subtext,
            style: TextStyle(
              fontSize: 11,
              color: subtextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Responsive Main Content Layout
class _MainContentArea
    extends
        StatelessWidget {
  final List<
    FarmModel
  >
  assignedFarms;

  const _MainContentArea({
    required this.assignedFarms,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final bool isWide =
        MediaQuery.of(
          context,
        ).size.width >=
        1100;

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 7,
            child: _ActiveFarmsSection(
              assignedFarms: assignedFarms,
            ),
          ),
          const SizedBox(
            width: 24,
          ),
          const Expanded(
            flex: 4,
            child: _OperationalTasksSection(),
          ),
        ],
      );
    }

    return Column(
      children: [
        _ActiveFarmsSection(
          assignedFarms: assignedFarms,
        ),
        const SizedBox(
          height: 28,
        ),
        const _OperationalTasksSection(),
      ],
    );
  }
}

/// Assigned Active Farms Grid
class _ActiveFarmsSection
    extends
        StatelessWidget {
  final List<
    FarmModel
  >
  assignedFarms;

  const _ActiveFarmsSection({
    required this.assignedFarms,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Active Assigned Farms',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(
                  0xFF1A1A1A,
                ),
              ),
            ),
            Text(
              '${assignedFarms.length} Assigned',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 12,
        ),
        if (assignedFarms.isEmpty)
          Container(
            padding: const EdgeInsets.all(
              24,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                12,
              ),
              border: Border.all(
                color: const Color(
                  0xFFEFEFEF,
                ),
              ),
            ),
            child: const Center(
              child: Text(
                'No farms allocated to your account yet. Contact an admin to assign farms.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 250,
            ),
            itemCount: assignedFarms.length,
            itemBuilder:
                (
                  context,
                  index,
                ) {
                  final farm = assignedFarms[index];
                  return _FarmCard(
                    farm: farm,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (
                                context,
                              ) => FarmDetailsScreen(
                                farm: farm,
                              ),
                        ),
                      );
                    },
                  );
                },
          ),
      ],
    );
  }
}

class _FarmCard
    extends
        StatelessWidget {
  final FarmModel farm;
  final VoidCallback onTap;

  const _FarmCard({
    required this.farm,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            12,
          ),
          border: Border.all(
            color: const Color(
              0xFFEFEFEF,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=600&q=80',
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFF1CB026,
                        ),
                        borderRadius: BorderRadius.circular(
                          4,
                        ),
                      ),
                      child: const Text(
                        'Active',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(
                12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          farm.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(
                              0xFF1A1A1A,
                            ),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.north_east,
                        size: 14,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    '📐 ${farm.areaInHectares.toStringAsFixed(2)} Hectares',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
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

/// Operational Tasks Right Panel
class _OperationalTasksSection
    extends
        StatelessWidget {
  const _OperationalTasksSection();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          12,
        ),
        border: Border.all(
          color: const Color(
            0xFFEFEFEF,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Operational Tasks',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(
                    0xFF1A1A1A,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(
                    12,
                  ),
                ),
                child: Text(
                  '2 Pending',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          _TaskCard(
            icon: Icons.warning_amber_rounded,
            iconColor: Colors.black,
            title: 'Irrigation Check',
            subtitle: 'North Sensor Check',
            description: 'Manual inspection required before tomorrow\'s irrigation cycle.',
            actions: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF1CB026,
                  ),
                  elevation: 0,
                  minimumSize: const Size(
                    80,
                    32,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      6,
                    ),
                  ),
                ),
                child: const Text(
                  'Mark Done',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskCard
    extends
        StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String description;
  final List<
    Widget
  >
  actions;

  const _TaskCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.actions,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(
        12,
      ),
      decoration: BoxDecoration(
        color: const Color(
          0xFFFAFAFA,
        ),
        borderRadius: BorderRadius.circular(
          8,
        ),
        border: Border.all(
          color: const Color(
            0xFFEFEFEF,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 18,
                color: iconColor,
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(
              height: 8,
            ),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ],
          if (actions.isNotEmpty) ...[
            const SizedBox(
              height: 12,
            ),
            Row(
              children: actions,
            ),
          ],
        ],
      ),
    );
  }
}

class _HeaderSection
    extends
        StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Farmer Dashboard',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(
              0xFF1A1A1A,
            ),
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          "Here's what's happening on your assigned farms today.",
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _TopNavBar
    extends
        StatelessWidget {
  const _TopNavBar();

  @override
  Widget build(
    BuildContext context,
  ) {
    final bool isDesktop =
        MediaQuery.of(
          context,
        ).size.width >=
        1024;
    final currentUser = FirebaseAuth.instance.currentUser;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(
              0xFFEFEFEF,
            ),
          ),
        ),
      ),
      child: Row(
        children: [
          if (!isDesktop)
            IconButton(
              icon: const Icon(
                Icons.menu,
              ),
              onPressed: () => Scaffold.of(
                context,
              ).openDrawer(),
            ),
          const Spacer(),
          if (currentUser !=
              null)
            StreamBuilder<
              DocumentSnapshot<
                Map<
                  String,
                  dynamic
                >
              >
            >(
              stream: FirebaseFirestore.instance
                  .collection(
                    'users',
                  )
                  .doc(
                    currentUser.uid,
                  )
                  .snapshots(),
              builder:
                  (
                    context,
                    snapshot,
                  ) {
                    String fullName = 'Farmer';
                    String userRole = 'Field Worker';

                    if (snapshot.hasData &&
                        snapshot.data!.exists) {
                      final data = snapshot.data!.data();
                      fullName =
                          data?['fullName'] ??
                          'Farmer';
                      userRole =
                          data?['userRole'] ??
                          'Field Worker';
                    }

                    return Row(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              fullName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              userRole,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(
                            'https://i.pravatar.cc/100?img=68',
                          ),
                        ),
                      ],
                    );
                  },
            ),
        ],
      ),
    );
  }
}

class _SidebarContent
    extends
        StatelessWidget {
  final String activeRoute;

  const _SidebarContent({
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

      // Navigate back to Sign In and clear route stack
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
            'Error signing out: $e',
          ),
        ),
      );
    }
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
          // Navigation List Items
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
                ),
                _SidebarItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Reports',
                  isActive:
                      activeRoute ==
                      'Reports',
                ),
                _SidebarItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  isActive:
                      activeRoute ==
                      'Settings',
                ),
                _SidebarItem(
                  icon: Icons.map_outlined,
                  label: 'Farm Details',
                  isActive:
                      activeRoute ==
                      'Farm Details',
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

          // Bottom Logout Button
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

class _SidebarDrawer
    extends
        StatelessWidget {
  const _SidebarDrawer();

  @override
  Widget build(
    BuildContext context,
  ) {
    return const Drawer(
      child: SafeArea(
        child: _SidebarContent(),
      ),
    );
  }
}

class _SidebarItem
    extends
        StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _SidebarItem({
    required this.icon,
    required this.label,
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
      ),
    );
  }
}
