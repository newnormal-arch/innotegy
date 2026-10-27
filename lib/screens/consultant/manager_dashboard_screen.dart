import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:innotegy/screens/consultant/users_screen.dart';
import 'package:innotegy/screens/farm/farm_screen.dart';
import 'package:innotegy/widgets/app_sidebar.dart';

class ManagerDashboardScreen
    extends
        StatelessWidget {
  const ManagerDashboardScreen({
    super.key,
  });

  static const Color primaryColor = Color(
    0xFF1CB026,
  );

  @override
  Widget build(
    BuildContext context,
  ) {
    final bool isDesktop =
        MediaQuery.of(
          context,
        ).size.width >=
        1024;

    return Scaffold(
      backgroundColor: const Color(
        0xFFF8F9FA,
      ),
      drawer: isDesktop
          ? null
          : const AppSidebarDrawer(
              activeRoute: 'Consultancy',
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
                      activeRoute: 'Consultancy',
                    ),
                  ),
                const Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(
                      24.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HeaderSection(),
                        SizedBox(
                          height: 24,
                        ),
                        _MainContentArea(),
                      ],
                    ),
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

/// Top Header Navigation Bar
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
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 360,
                height: 40,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search farms, tasks, or reports...',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 18,
                      color: Colors.grey,
                    ),
                    filled: true,
                    fillColor: const Color(
                      0xFFF5F5F5,
                    ),
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        8,
                      ),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isDesktop)
            const Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Color(
                    0xFF1CB026,
                  ),
                  child: Icon(
                    Icons.eco,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  'MyInnotegy',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(
                      0xFF1CB026,
                    ),
                  ),
                ),
              ],
            ),
          const Spacer(),
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.grey,
            ),
            onPressed: () {},
          ),
          const SizedBox(
            width: 12,
          ),

          // Real-time Firestore User Data
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
                    String fullName = 'Dr. Eleanor Vance';
                    String userRole = 'Manager';

                    if (snapshot.hasData &&
                        snapshot.data!.exists) {
                      final data = snapshot.data!.data();
                      fullName =
                          data?['fullName'] ??
                          'User';
                      userRole =
                          data?['userRole'] ??
                          '';
                      if (userRole.isEmpty) userRole = 'Manager';
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
                            'https://i.pravatar.cc/100?img=47',
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

/// Sidebar Content
class _SidebarContent
    extends
        StatelessWidget {
  const _SidebarContent();

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
      child: ListView(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 12,
        ),
        children: [
          _SidebarItem(
            icon: Icons.business_center_outlined,
            label: 'Consultancy',
            isActive: true, // Active tab on Manager Dashboard
            onTap: () {},
          ),
          _SidebarItem(
            icon: Icons.people_alt_outlined,
            label: 'Users',
            isActive: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (
                        context,
                      ) => const UsersScreen(),
                ),
              );
            },
          ),
          _SidebarItem(
            icon: Icons.bar_chart_rounded,
            label: 'Reports',
            onTap: () {},
          ),
          _SidebarItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: () {},
          ),
          _SidebarItem(
            icon: Icons.map_outlined,
            label: 'Farm Details',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (
                        context,
                      ) => const FarmScreen(),
                ),
              );
            },
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
        onTap: onTap, // Handled here
      ),
    );
  }
}

/// Header Title with Quick Action Buttons
class _HeaderSection
    extends
        StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manager Dashboard',
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
              'Manage your portfolio, schedule visits, and provide expert advice.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.filter_list,
                size: 16,
                color: Colors.black,
              ),
              label: const Text(
                'Filter Views',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: Colors.grey[300]!,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    8,
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.calendar_month,
                size: 16,
                color: Colors.white,
              ),
              label: const Text(
                'Schedule New Visit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFF1CB026,
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Responsive Grid Layout
class _MainContentArea
    extends
        StatelessWidget {
  const _MainContentArea();

  @override
  Widget build(
    BuildContext context,
  ) {
    final bool isWide =
        MediaQuery.of(
          context,
        ).size.width >=
        1200;

    if (isWide) {
      return const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: _LeftRequestsSection(),
          ),
          SizedBox(
            width: 20,
          ),
          Expanded(
            flex: 5,
            child: _MiddleFarmsSection(),
          ),
          SizedBox(
            width: 20,
          ),
          Expanded(
            flex: 3,
            child: _RightAdviceTerminalSection(),
          ),
        ],
      );
    }

    return const Column(
      children: [
        _MiddleFarmsSection(),
        SizedBox(
          height: 24,
        ),
        _LeftRequestsSection(),
        SizedBox(
          height: 24,
        ),
        _RightAdviceTerminalSection(),
      ],
    );
  }
}

/// Left Column: New Requests & Today's Schedule
class _LeftRequestsSection
    extends
        StatelessWidget {
  const _LeftRequestsSection();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.outlined_flag,
                  size: 18,
                  color: Color(
                    0xFF1CB026,
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                const Text(
                  'New Requests',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(
                      0xFF1A1A1A,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(
                  10,
                ),
              ),
              child: const Text(
                '3',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        const _RequestCard(
          name: 'Marcus Thorne',
          farm: 'Green Valley',
          topic: 'Soil Acidity Levels',
          time: 'Received 10m ago',
          priority: 'High',
          priorityColor: Colors.red,
          avatarUrl: 'https://i.pravatar.cc/100?img=12',
        ),
        const SizedBox(
          height: 12,
        ),
        const _RequestCard(
          name: 'Sarah Jenkins',
          farm: 'Sun-Kissed',
          topic: 'Pest Management Plan',
          time: 'Received 2h ago',
          priority: 'Medium',
          priorityColor: Color(
            0xFF1CB026,
          ),
          avatarUrl: 'https://i.pravatar.cc/100?img=25',
        ),
        const SizedBox(
          height: 12,
        ),
        const _RequestCard(
          name: 'David Wu',
          farm: 'Riverbend',
          topic: 'Irrigation Scheduling',
          time: 'Received 5h ago',
          priority: 'Low',
          priorityColor: Colors.grey,
          avatarUrl: 'https://i.pravatar.cc/100?img=33',
        ),
        const SizedBox(
          height: 28,
        ),

        // Today's Schedule Section
        Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: Color(
                0xFF1CB026,
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            const Text(
              "Today's Schedule",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 12,
        ),
        Container(
          height: 100,
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
            child: Icon(
              Icons.access_time,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}

class _RequestCard
    extends
        StatelessWidget {
  final String name;
  final String farm;
  final String topic;
  final String time;
  final String priority;
  final Color priorityColor;
  final String avatarUrl;

  const _RequestCard({
    required this.name,
    required this.farm,
    required this.topic,
    required this.time,
    required this.priority,
    required this.priorityColor,
    required this.avatarUrl,
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
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(
                  avatarUrl,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      farm,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: BorderRadius.circular(
                    12,
                  ),
                ),
                child: Text(
                  priority,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            topic,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            '🕒 $time',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Colors.grey[300]!,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        6,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Ignore',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF1CB026,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        6,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Review',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
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

/// Middle Column: Assigned Farms Grid & Recommended Actions
class _MiddleFarmsSection
    extends
        StatelessWidget {
  const _MiddleFarmsSection();

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
            const Row(
              children: [
                Icon(
                  Icons.people_alt_outlined,
                  size: 18,
                  color: Color(
                    0xFF1CB026,
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  'Assigned Farms',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              'Showing 4 active clients',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.4,
          children: const [
            _AssignedFarmCard(
              title: 'Green Valley Estates',
              location: 'Napa, CA',
              crop: 'Grapes',
              status: 'Optimal',
              statusColor: Color(
                0xFF1CB026,
              ),
              lastVisited: '2 days ago',
            ),
            _AssignedFarmCard(
              title: 'Sun-Kissed Orchards',
              location: 'Fresno, CA',
              crop: 'Almonds',
              status: 'Caution',
              statusColor: Colors.amber,
              lastVisited: '1 week ago',
            ),
            _AssignedFarmCard(
              title: 'Highland Wheat Farm',
              location: 'Bozeman, MT',
              crop: 'Wheat',
              status: 'Action Required',
              statusColor: Colors.red,
              lastVisited: '3 weeks ago',
            ),
            _AssignedFarmCard(
              title: 'Riverbend Berries',
              location: 'Salem, OR',
              crop: 'Blueberries',
              status: 'Optimal',
              statusColor: Color(
                0xFF1CB026,
              ),
              lastVisited: '4 days ago',
            ),
          ],
        ),
        const SizedBox(
          height: 28,
        ),

        // Recommended Actions
        const Text(
          'Recommended Actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        const _ActionCard(
          icon: Icons.warning_amber_rounded,
          iconColor: Colors.red,
          title: 'Immediate Irrigation Audit Required',
          description: 'Highland Wheat Farm reporting 15% drop in soil moisture sensors across Field A3.',
        ),
        const SizedBox(
          height: 12,
        ),
        const _ActionCard(
          icon: Icons.check_circle_outline,
          iconColor: Colors.black,
          title: 'Review Winterization Plan',
          description: 'Sun-Kissed Orchards needs approval on frost protection strategy for almond block 1-4.',
        ),
      ],
    );
  }
}

class _AssignedFarmCard
    extends
        StatelessWidget {
  final String title;
  final String location;
  final String crop;
  final String status;
  final Color statusColor;
  final String lastVisited;

  const _AssignedFarmCard({
    required this.title,
    required this.location,
    required this.crop,
    required this.status,
    required this.statusColor,
    required this.lastVisited,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(
        14,
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
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.eco_outlined,
                      size: 16,
                      color: Color(
                        0xFF1CB026,
                      ),
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.more_vert,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
          Text(
            location,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
          const Divider(
            height: 12,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ACTIVE CROP',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    crop,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HEALTH STATUS',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 4,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Last visited: $lastVisited',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(
                    50,
                    20,
                  ),
                ),
                child: const Row(
                  children: [
                    Text(
                      'View Data',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(
                          0xFF1CB026,
                        ),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Icon(
                      Icons.arrow_forward,
                      size: 10,
                      color: Color(
                        0xFF1CB026,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionCard
    extends
        StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const _ActionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(
        14,
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
          const SizedBox(
            width: 12,
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
                const SizedBox(
                  height: 4,
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              'Action',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Right Column: Advice Terminal Panel
class _RightAdviceTerminalSection
    extends
        StatefulWidget {
  const _RightAdviceTerminalSection();

  @override
  State<
    _RightAdviceTerminalSection
  >
  createState() => _RightAdviceTerminalSectionState();
}

class _RightAdviceTerminalSectionState
    extends
        State<
          _RightAdviceTerminalSection
        > {
  String _selectedFarm = 'Green Valley Estates';
  final TextEditingController _recommendationController = TextEditingController();

  final List<
    String
  >
  _farms = [
    'Green Valley Estates',
    'Sun-Kissed Orchards',
    'Highland Wheat Farm',
    'Riverbend Berries',
  ];

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
          const Row(
            children: [
              Icon(
                Icons.send_outlined,
                size: 18,
                color: Color(
                  0xFF1CB026,
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                'Advice Terminal',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            'Send professional recommendations directly to a farmer\'s dashboard.',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(
            height: 20,
          ),

          // Target Farm Selector
          Text(
            'TARGET FARM',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Column(
            children: _farms.map(
              (
                farm,
              ) {
                final bool isSelected =
                    farm ==
                    _selectedFarm;
                return GestureDetector(
                  onTap: () => setState(
                    () => _selectedFarm = farm,
                  ),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(
                      bottom: 8,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(
                              0xFF1CB026,
                            )
                          : const Color(
                              0xFFFAFAFA,
                            ),
                      borderRadius: BorderRadius.circular(
                        8,
                      ),
                      border: Border.all(
                        color: isSelected
                            ? const Color(
                                0xFF1CB026,
                              )
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: Text(
                      farm,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
          const SizedBox(
            height: 16,
          ),

          // Recommendation Input
          Text(
            'RECOMMENDATION',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          TextField(
            controller: _recommendationController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'e.g., Based on the latest moisture readings, I recommend increasing irrigation by 15% in the north block...',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
              filled: true,
              fillColor: const Color(
                0xFFFAFAFA,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  8,
                ),
                borderSide: BorderSide(
                  color: Colors.grey[300]!,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  8,
                ),
                borderSide: BorderSide(
                  color: Colors.grey[300]!,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),

          // Send Advice Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.send,
                size: 14,
                color: Colors.white,
              ),
              label: const Text(
                'Send Advice',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                      0xFF1CB026,
                    ).withOpacity(
                      0.8,
                    ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    8,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
