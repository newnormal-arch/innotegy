import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:innotegy/screens/consultant/manager_dashboard_screen.dart';
import 'package:innotegy/screens/farm/farm_screen.dart';
import 'package:innotegy/widgets/app_sidebar.dart';

class UsersScreen
    extends
        StatefulWidget {
  const UsersScreen({
    super.key,
  });

  @override
  State<
    UsersScreen
  >
  createState() => _UsersScreenState();
}

class _UsersScreenState
    extends
        State<
          UsersScreen
        > {
  static const Color primaryColor = Color(
    0xFF1CB026,
  );
  String _searchQuery = '';

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
              activeRoute: 'Users',
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
                      activeRoute: 'Users',
                    ),
                  ),
                Expanded(
                  child:
                      StreamBuilder<
                        QuerySnapshot<
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
                            .snapshots(),
                        builder:
                            (
                              context,
                              snapshot,
                            ) {
                              if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                    'Error: ${snapshot.error}',
                                  ),
                                );
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: primaryColor,
                                  ),
                                );
                              }

                              final docs =
                                  snapshot.data?.docs ??
                                  [];

                              // Calculate metrics from Firestore documents
                              final totalUsers = docs.length;
                              final activeUsers = docs
                                  .where(
                                    (
                                      doc,
                                    ) =>
                                        doc.data()['isActive'] ==
                                        true,
                                  )
                                  .length;
                              final fieldWorkers = docs
                                  .where(
                                    (
                                      doc,
                                    ) =>
                                        doc.data()['userRole'] ==
                                        'Field Worker',
                                  )
                                  .length;
                              final managers = docs
                                  .where(
                                    (
                                      doc,
                                    ) =>
                                        doc.data()['userRole'] ==
                                        'Manager',
                                  )
                                  .length;

                              // Filter user list based on search bar
                              final filteredDocs = docs.where(
                                (
                                  doc,
                                ) {
                                  final data = doc.data();
                                  final name =
                                      (data['fullName'] ??
                                              '')
                                          .toString()
                                          .toLowerCase();
                                  final email =
                                      (data['email'] ??
                                              '')
                                          .toString()
                                          .toLowerCase();
                                  final role =
                                      (data['userRole'] ??
                                              '')
                                          .toString()
                                          .toLowerCase();
                                  final query = _searchQuery.toLowerCase();

                                  return name.contains(
                                        query,
                                      ) ||
                                      email.contains(
                                        query,
                                      ) ||
                                      role.contains(
                                        query,
                                      );
                                },
                              ).toList();

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

                                    // Top Metrics Row
                                    _MetricsRow(
                                      totalUsers: totalUsers,
                                      activeUsers: activeUsers,
                                      fieldWorkers: fieldWorkers,
                                      managers: managers,
                                    ),
                                    const SizedBox(
                                      height: 28,
                                    ),

                                    // User Management Table Card
                                    _UsersTableCard(
                                      users: filteredDocs,
                                      onSearchChanged:
                                          (
                                            val,
                                          ) {
                                            setState(
                                              () => _searchQuery = val,
                                            );
                                          },
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

/// Header Section
class _HeaderSection
    extends
        StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(
    BuildContext context,
  ) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'User Management',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(
              0xFF1A1A1A,
            ),
          ),
        ),
        SizedBox(
          height: 4,
        ),
        Text(
          'Manage system access, toggle active statuses, and configure user permissions.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

/// Metrics Cards Row
class _MetricsRow
    extends
        StatelessWidget {
  final int totalUsers;
  final int activeUsers;
  final int fieldWorkers;
  final int managers;

  const _MetricsRow({
    required this.totalUsers,
    required this.activeUsers,
    required this.fieldWorkers,
    required this.managers,
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
                  title: 'TOTAL USERS',
                  value: '$totalUsers',
                  icon: Icons.people_outline,
                  iconColor: Colors.blue,
                ),
                _MetricCard(
                  title: 'TOTAL ACTIVE USERS',
                  value: '$activeUsers',
                  icon: Icons.check_circle_outline,
                  iconColor: const Color(
                    0xFF1CB026,
                  ),
                ),
                _MetricCard(
                  title: 'TOTAL FIELD WORKERS',
                  value: '$fieldWorkers',
                  icon: Icons.agriculture_outlined,
                  iconColor: Colors.amber[700]!,
                ),
                _MetricCard(
                  title: 'TOTAL MANAGERS',
                  value: '$managers',
                  icon: Icons.admin_panel_settings_outlined,
                  iconColor: Colors.purple,
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
  final IconData icon;
  final Color iconColor;

  const _MetricCard({
    required this.title,
    required this.value,
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
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(
                0xFF1A1A1A,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Users List Data Table Container
class _UsersTableCard
    extends
        StatelessWidget {
  final List<
    QueryDocumentSnapshot<
      Map<
        String,
        dynamic
      >
    >
  >
  users;
  final ValueChanged<
    String
  >
  onSearchChanged;

  const _UsersTableCard({
    required this.users,
    required this.onSearchChanged,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
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
          // Table Filter Header
          Padding(
            padding: const EdgeInsets.all(
              16.0,
            ),
            child: Row(
              children: [
                const Text(
                  'All Accounts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 260,
                  height: 38,
                  child: TextField(
                    onChanged: onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search by name or email...',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 16,
                        color: Colors.grey,
                      ),
                      filled: true,
                      fillColor: const Color(
                        0xFFFAFAFA,
                      ),
                      contentPadding: EdgeInsets.zero,
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
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
          ),

          // Users Table
          if (users.isEmpty)
            const Padding(
              padding: EdgeInsets.all(
                32.0,
              ),
              child: Center(
                child: Text(
                  'No users found matching your search.',
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth:
                      MediaQuery.of(
                        context,
                      ).size.width -
                      320,
                ),
                child: DataTable(
                  horizontalMargin: 20,
                  columnSpacing: 24,
                  headingRowColor: WidgetStateProperty.all(
                    const Color(
                      0xFFFAFAFA,
                    ),
                  ),
                  columns: const [
                    DataColumn(
                      label: Text(
                        'USER DETAILS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'EMAIL ADDRESS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'PHONE NUMBER',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'ROLE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'STATUS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'ACTIONS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                  rows: users.map(
                    (
                      doc,
                    ) {
                      final data = doc.data();
                      final uid = doc.id;
                      final fullName =
                          data['fullName'] ??
                          'Unnamed User';
                      final email =
                          data['email'] ??
                          'No email';
                      final phone =
                          data['phoneNumber'] ??
                          'N/A';
                      final role =
                          (data['userRole'] ??
                                  '')
                              .isEmpty
                          ? 'Unassigned'
                          : data['userRole'];
                      final bool isActive =
                          data['isActive'] ??
                          false;

                      return DataRow(
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor:
                                      const Color(
                                        0xFF1CB026,
                                      ).withOpacity(
                                        0.1,
                                      ),
                                  child: Text(
                                    fullName.isNotEmpty
                                        ? fullName[0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(
                                        0xFF1CB026,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  fullName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(
                              email,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              phone,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    role ==
                                        'Manager'
                                    ? Colors.purple.withOpacity(
                                        0.1,
                                      )
                                    : (role ==
                                              'Field Worker'
                                          ? Colors.amber.withOpacity(
                                              0.1,
                                            )
                                          : Colors.grey[200]),
                                borderRadius: BorderRadius.circular(
                                  4,
                                ),
                              ),
                              child: Text(
                                role,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      role ==
                                          'Manager'
                                      ? Colors.purple
                                      : (role ==
                                                'Field Worker'
                                            ? Colors.amber[800]
                                            : Colors.grey[700]),
                                ),
                              ),
                            ),
                          ),
                          // Interactive Status Toggle
                          DataCell(
                            Row(
                              children: [
                                Switch(
                                  value: isActive,
                                  activeColor: const Color(
                                    0xFF1CB026,
                                  ),
                                  onChanged:
                                      (
                                        bool newValue,
                                      ) async {
                                        await FirebaseFirestore.instance
                                            .collection(
                                              'users',
                                            )
                                            .doc(
                                              uid,
                                            )
                                            .update(
                                              {
                                                'isActive': newValue,
                                              },
                                            );
                                      },
                                ),
                                Text(
                                  isActive
                                      ? 'Active'
                                      : 'Inactive',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isActive
                                        ? const Color(
                                            0xFF1CB026,
                                          )
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Actions (Delete)
                          DataCell(
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: Colors.red,
                              ),
                              onPressed: () => _confirmDeleteUser(
                                context,
                                uid,
                                fullName,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _confirmDeleteUser(
    BuildContext context,
    String uid,
    String name,
  ) {
    showDialog(
      context: context,
      builder:
          (
            context,
          ) => AlertDialog(
            title: const Text(
              'Delete User Document',
            ),
            content: Text(
              'Are you sure you want to remove $name from Firestore? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(
                  context,
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection(
                        'users',
                      )
                      .doc(
                        uid,
                      )
                      .delete();
                  if (context.mounted)
                    Navigator.pop(
                      context,
                    );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}

/// Dynamic Top Navigation Bar
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
                    String fullName = 'Manager';
                    String userRole = 'Manager';

                    if (snapshot.hasData &&
                        snapshot.data!.exists) {
                      final data = snapshot.data!.data();
                      fullName =
                          data?['fullName'] ??
                          'Manager';
                      userRole =
                          data?['userRole'] ??
                          'Manager';
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
        child: _SidebarContent(
          activeRoute: 'Users',
        ),
      ),
    );
  }
}

class _SidebarContent
    extends
        StatelessWidget {
  final String activeRoute;

  const _SidebarContent({
    this.activeRoute = 'Users',
  });

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
            isActive:
                activeRoute ==
                'Consultancy',
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (
                        context,
                      ) => const ManagerDashboardScreen(),
                ),
              );
            },
          ),
          _SidebarItem(
            icon: Icons.people_alt_outlined,
            label: 'Users',
            isActive:
                activeRoute ==
                'Users',
            onTap: () {},
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
