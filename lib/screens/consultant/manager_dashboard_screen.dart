import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:innotegy/models/farm_model.dart';
import 'package:innotegy/screens/farm/farm_details_screen.dart';
import 'package:innotegy/services/kml_service.dart';
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
          // SizedBox(
          //   width: 20,
          // ),
          // Expanded(
          //   flex: 3,
          //   child: _RightAdviceTerminalSection(),
          // ),
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
        //   SizedBox(
        //     height: 24,
        //   ),
        //   _RightAdviceTerminalSection(),
      ],
    );
  }
}

/// Left Column: New Requests & Today's Schedule
class _LeftRequestsSection
    extends
        StatelessWidget {
  const _LeftRequestsSection();

  static const Color primaryColor = Color(
    0xFF1CB026,
  );

  /// Opens the Review Dialog containing checklists and Approve/Deny actions
  void _showReviewDialog(
    BuildContext context,
    DocumentSnapshot<
      Map<
        String,
        dynamic
      >
    >
    taskDoc,
  ) {
    final data =
        taskDoc.data() ??
        {};
    final title =
        data['taskTitle'] ??
        'Task Review';
    final farmName =
        data['farmName'] ??
        'Farm';
    final workerName =
        data['assignedToName'] ??
        'Field Worker';
    final description =
        data['description'] ??
        'No description provided.';

    showDialog(
      context: context,
      builder:
          (
            context,
          ) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  12,
                ),
              ),
              title: Text(
                'Review: $title',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        'Farm:',
                        farmName,
                      ),
                      _buildInfoRow(
                        'Assigned Worker:',
                        workerName,
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      const Text(
                        'Instructions / Notes:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                      ),
                      const Divider(
                        height: 24,
                      ),
                      const Text(
                        'Worker Safety & Wrap-up Verification',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      CheckboxListTile(
                        value: true,
                        enabled: false,
                        activeColor: primaryColor,
                        dense: true,
                        onChanged:
                            (
                              val,
                            ) {},
                        title: const Text(
                          'Pre-commencement safety checklist completed',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                      CheckboxListTile(
                        value: true,
                        enabled: false,
                        activeColor: primaryColor,
                        dense: true,
                        onChanged:
                            (
                              val,
                            ) {},
                        title: const Text(
                          'Post-completion wrap-up checklist verified',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                OutlinedButton(
                  onPressed: () async {
                    await taskDoc.reference.update(
                      {
                        'taskProgress': 'In progress',
                      },
                    );
                    if (!context.mounted) return;
                    Navigator.pop(
                      context,
                    );
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.orange,
                        content: Text(
                          'Task review denied. Returned to worker.',
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Colors.red,
                    ),
                  ),
                  child: const Text(
                    'Deny',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final currentUser = FirebaseAuth.instance.currentUser;
                    await taskDoc.reference.update(
                      {
                        'taskProgress': 'Done - (Approved)',
                        'reviewedBy': currentUser!.uid,
                        'reviewedByName':
                            currentUser.displayName ??
                            'Manager',
                        'reviewedAt': FieldValue.serverTimestamp(),
                      },
                    );
                    if (!context.mounted) return;
                    Navigator.pop(
                      context,
                    );
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        backgroundColor: primaryColor,
                        content: Text(
                          'Task successfully approved!',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    elevation: 0,
                  ),
                  child: const Text(
                    'Approve',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
    );
  }

  Widget _buildInfoRow(
    String label,
    String val,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 4,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Text(
            val,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser ==
        null) {
      return const SizedBox.shrink();
    }

    // Stream user profile to determine if they are an Owner
    return StreamBuilder<
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
            userSnapshot,
          ) {
            if (!userSnapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                ),
              );
            }

            final userData =
                userSnapshot.data?.data() ??
                {};
            final String userRole =
                userData['userRole'] ??
                '';
            final bool isOwner =
                userRole ==
                'Owner';

            // Build dynamic query: Owners see all reviews, others see only tasks they created
            Query<
              Map<
                String,
                dynamic
              >
            >
            taskQuery = FirebaseFirestore.instance
                .collection(
                  'farmTasks',
                )
                .where(
                  'taskProgress',
                  isEqualTo: 'Done - (Review)',
                );

            if (!isOwner) {
              taskQuery = taskQuery.where(
                'createdByUid',
                isEqualTo: currentUser.uid,
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.outlined_flag,
                          size: 18,
                          color: primaryColor,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          isOwner
                              ? 'Pending Reviews (All)'
                              : 'My Created Task Reviews',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(
                              0xFF1A1A1A,
                            ),
                          ),
                        ),
                      ],
                    ),
                    StreamBuilder<
                      QuerySnapshot<
                        Map<
                          String,
                          dynamic
                        >
                      >
                    >(
                      stream: taskQuery.snapshots(),
                      builder:
                          (
                            context,
                            snapshot,
                          ) {
                            final count =
                                snapshot.data?.docs.length ??
                                0;
                            return Container(
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
                              child: Text(
                                '$count',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                StreamBuilder<
                  QuerySnapshot<
                    Map<
                      String,
                      dynamic
                    >
                  >
                >(
                  stream: taskQuery.snapshots(),
                  builder:
                      (
                        context,
                        snapshot,
                      ) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(
                                16.0,
                              ),
                              child: CircularProgressIndicator(
                                color: primaryColor,
                              ),
                            ),
                          );
                        }

                        final docs =
                            snapshot.data?.docs ??
                            [];

                        if (docs.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(
                              20,
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
                            child: Center(
                              child: Text(
                                isOwner
                                    ? 'No task reviews pending at the moment.'
                                    : 'No pending reviews for tasks created by you.',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: docs.length,
                          separatorBuilder:
                              (
                                context,
                                index,
                              ) => const SizedBox(
                                height: 12,
                              ),
                          itemBuilder:
                              (
                                context,
                                index,
                              ) {
                                final doc = docs[index];
                                final data = doc.data();

                                final name =
                                    data['assignedToName'] ??
                                    'Worker';
                                final farm =
                                    data['farmName'] ??
                                    'Farm';
                                final topic =
                                    data['taskTitle'] ??
                                    'Task';
                                final createdBy =
                                    data['createdByEmail'] ??
                                    'Manager';

                                final Timestamp? startTs = data['startDate'];
                                final Timestamp? endTs = data['endDate'];
                                final timeStr =
                                    startTs !=
                                            null &&
                                        endTs !=
                                            null
                                    ? '${startTs.toDate().day}/${startTs.toDate().month} - ${endTs.toDate().day}/${endTs.toDate().month}'
                                    : 'Pending review';

                                return _RequestCard(
                                  name: name,
                                  farm: farm,
                                  topic: topic,
                                  time: 'By: $createdBy • $timeStr',
                                  priority: 'In Review',
                                  priorityColor: Colors.amber.shade800,
                                  avatarUrl: 'https://i.pravatar.cc/100?img=${10 + index}',
                                  onReviewPressed: () => _showReviewDialog(
                                    context,
                                    doc,
                                  ),
                                );
                              },
                        );
                      },
                ),
                const SizedBox(
                  height: 28,
                ),
              ],
            );
          },
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
  final VoidCallback onReviewPressed;

  const _RequestCard({
    required this.name,
    required this.farm,
    required this.topic,
    required this.time,
    required this.priority,
    required this.priorityColor,
    required this.avatarUrl,
    required this.onReviewPressed,
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
            time,
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
                child: ElevatedButton(
                  onPressed: onReviewPressed,
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

/// Middle Column: All Managed Farms or Allocated Farms
class _MiddleFarmsSection
    extends
        StatefulWidget {
  const _MiddleFarmsSection();

  @override
  State<
    _MiddleFarmsSection
  >
  createState() => _MiddleFarmsSectionState();
}

class _MiddleFarmsSectionState
    extends
        State<
          _MiddleFarmsSection
        > {
  List<
    FarmModel
  >
  _allMyMapsFarms = [];
  bool _isLoadingFarms = true;

  @override
  void initState() {
    super.initState();
    _loadFarms();
  }

  Future<
    void
  >
  _loadFarms() async {
    try {
      final farms = await KmlService.fetchMyMapsFarms(
        '16V-t8nIWuYbt5LpNzJYxa_TDshAZCiA',
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
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser ==
        null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<
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
                child: Padding(
                  padding: EdgeInsets.all(
                    24.0,
                  ),
                  child: CircularProgressIndicator(
                    color: Color(
                      0xFF1CB026,
                    ),
                  ),
                ),
              );
            }

            final userData =
                snapshot.data?.data() ??
                {};
            final String userRole =
                userData['userRole'] ??
                '';
            final bool isOwner =
                userRole ==
                'Owner';

            // Extract assigned farms list for non-owners
            List<
              String
            >
            assignedFarmNames = [];
            if (!isOwner) {
              final rawFarms = userData['farms'];
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

            // Filter farms based on role
            final displayedFarms = isOwner
                ? _allMyMapsFarms
                : _allMyMapsFarms
                      .where(
                        (
                          farm,
                        ) => assignedFarmNames.contains(
                          farm.name,
                        ),
                      )
                      .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.people_alt_outlined,
                          size: 18,
                          color: Color(
                            0xFF1CB026,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          isOwner
                              ? 'All Managed Farms'
                              : 'My Allocated Farms',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Showing ${displayedFarms.length} active client(s)',
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
                if (displayedFarms.isEmpty)
                  Container(
                    width: double.infinity,
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
                        'No farms currently allocated to your account.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  )
                else
                  GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.4,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: displayedFarms.length,
                    itemBuilder:
                        (
                          context,
                          index,
                        ) {
                          final farm = displayedFarms[index];
                          return _AssignedFarmCard(
                            title: farm.name,
                            location: '${farm.areaInHectares.toStringAsFixed(1)} Hectares',
                            crop: 'Mixed Crops',
                            status: 'Optimal',
                            statusColor: const Color(
                              0xFF1CB026,
                            ),
                            lastVisited: 'Active',
                            onViewData: () {
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
                const SizedBox(
                  height: 28,
                ),

                // Recommended Actions Section
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
                  description: 'System reporting minor variance in active sensor nodes across assigned blocks.',
                ),
                const SizedBox(
                  height: 12,
                ),
                const _ActionCard(
                  icon: Icons.check_circle_outline,
                  iconColor: Colors.black,
                  title: 'Review Maintenance Schedule',
                  description: 'Pending checkups on seasonal protection and pipeline pressure thresholds.',
                ),
              ],
            );
          },
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
  final VoidCallback onViewData;

  const _AssignedFarmCard({
    required this.title,
    required this.location,
    required this.crop,
    required this.status,
    required this.statusColor,
    required this.lastVisited,
    required this.onViewData,
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
                'Status: $lastVisited',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
              TextButton(
                onPressed: onViewData,
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

// /// Right Column: Advice Terminal Panel
// class _RightAdviceTerminalSection
//     extends
//         StatefulWidget {
//   const _RightAdviceTerminalSection();

//   @override
//   State<
//     _RightAdviceTerminalSection
//   >
//   createState() => _RightAdviceTerminalSectionState();
// }

// class _RightAdviceTerminalSectionState
//     extends
//         State<
//           _RightAdviceTerminalSection
//         > {
//   String _selectedFarm = 'Green Valley Estates';
//   final TextEditingController _recommendationController = TextEditingController();

//   final List<
//     String
//   >
//   _farms = [
//     'Green Valley Estates',
//     'Sun-Kissed Orchards',
//     'Highland Wheat Farm',
//     'Riverbend Berries',
//   ];

//   @override
//   Widget build(
//     BuildContext context,
//   ) {
//     return Container(
//       padding: const EdgeInsets.all(
//         16,
//       ),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(
//           12,
//         ),
//         border: Border.all(
//           color: const Color(
//             0xFFEFEFEF,
//           ),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Row(
//             children: [
//               Icon(
//                 Icons.send_outlined,
//                 size: 18,
//                 color: Color(
//                   0xFF1CB026,
//                 ),
//               ),
//               SizedBox(
//                 width: 8,
//               ),
//               Text(
//                 'Advice Terminal',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(
//             height: 4,
//           ),
//           Text(
//             'Send professional recommendations directly to a farmer\'s dashboard.',
//             style: TextStyle(
//               fontSize: 11,
//               color: Colors.grey[600],
//             ),
//           ),
//           const SizedBox(
//             height: 20,
//           ),

//           // Target Farm Selector
//           Text(
//             'TARGET FARM',
//             style: TextStyle(
//               fontSize: 10,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[500],
//             ),
//           ),
//           const SizedBox(
//             height: 8,
//           ),
//           Column(
//             children: _farms.map(
//               (
//                 farm,
//               ) {
//                 final bool isSelected =
//                     farm ==
//                     _selectedFarm;
//                 return GestureDetector(
//                   onTap: () => setState(
//                     () => _selectedFarm = farm,
//                   ),
//                   child: Container(
//                     width: double.infinity,
//                     margin: const EdgeInsets.only(
//                       bottom: 8,
//                     ),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 14,
//                       vertical: 12,
//                     ),
//                     decoration: BoxDecoration(
//                       color: isSelected
//                           ? const Color(
//                               0xFF1CB026,
//                             )
//                           : const Color(
//                               0xFFFAFAFA,
//                             ),
//                       borderRadius: BorderRadius.circular(
//                         8,
//                       ),
//                       border: Border.all(
//                         color: isSelected
//                             ? const Color(
//                                 0xFF1CB026,
//                               )
//                             : Colors.grey[300]!,
//                       ),
//                     ),
//                     child: Text(
//                       farm,
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: isSelected
//                             ? FontWeight.bold
//                             : FontWeight.normal,
//                         color: isSelected
//                             ? Colors.white
//                             : Colors.black,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ).toList(),
//           ),
//           const SizedBox(
//             height: 16,
//           ),

//           // Recommendation Input
//           Text(
//             'RECOMMENDATION',
//             style: TextStyle(
//               fontSize: 10,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[500],
//             ),
//           ),
//           const SizedBox(
//             height: 8,
//           ),
//           TextField(
//             controller: _recommendationController,
//             maxLines: 4,
//             decoration: InputDecoration(
//               hintText: 'e.g., Based on the latest moisture readings, I recommend increasing irrigation by 15% in the north block...',
//               hintStyle: TextStyle(
//                 color: Colors.grey[400],
//                 fontSize: 12,
//               ),
//               filled: true,
//               fillColor: const Color(
//                 0xFFFAFAFA,
//               ),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(
//                   8,
//                 ),
//                 borderSide: BorderSide(
//                   color: Colors.grey[300]!,
//                 ),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(
//                   8,
//                 ),
//                 borderSide: BorderSide(
//                   color: Colors.grey[300]!,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(
//             height: 20,
//           ),

//           // Send Advice Button
//           SizedBox(
//             width: double.infinity,
//             height: 44,
//             child: ElevatedButton.icon(
//               onPressed: () {},
//               icon: const Icon(
//                 Icons.send,
//                 size: 14,
//                 color: Colors.white,
//               ),
//               label: const Text(
//                 'Send Advice',
//                 style: TextStyle(
//                   fontSize: 13,
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor:
//                     const Color(
//                       0xFF1CB026,
//                     ).withOpacity(
//                       0.8,
//                     ),
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(
//                     8,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
