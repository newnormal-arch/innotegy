import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:innotegy/models/farm_model.dart';
import 'package:innotegy/screens/farm/farm_details_screen.dart';
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
                              userSnapshot,
                            ) {
                              if (userSnapshot.connectionState ==
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
                              if (userSnapshot.hasData &&
                                  userSnapshot.data!.exists) {
                                final data = userSnapshot.data!.data();
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

                              // Nested StreamBuilder to listen to the user's assigned farmTasks simultaneously
                              return StreamBuilder<
                                QuerySnapshot<
                                  Map<
                                    String,
                                    dynamic
                                  >
                                >
                              >(
                                stream: FirebaseFirestore.instance
                                    .collection(
                                      'farmTasks',
                                    )
                                    .where(
                                      'assignedToUid',
                                      isEqualTo: currentUser.uid,
                                    )
                                    .snapshots(),
                                builder:
                                    (
                                      context,
                                      taskSnapshot,
                                    ) {
                                      // Fallback empty list if tasks are still loading or empty
                                      final userTasks =
                                          taskSnapshot.data?.docs ??
                                          [];

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
                                              userTasks: userTasks, // Passed successfully here
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
  final List<
    QueryDocumentSnapshot<
      Map<
        String,
        dynamic
      >
    >
  >
  userTasks;

  const _MetricsGrid({
    required this.assignedFarmsCount,
    required this.totalAreaHectares,
    required this.userTasks,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    // 1. Calculate Active Alerts: Tasks not done and ending in < 24 hours or already overdue
    final now = DateTime.now();
    final overdueOrNearingCount = userTasks.where(
      (
        doc,
      ) {
        final data = doc.data();
        final progress =
            data['taskProgress'] ??
            'Not started';
        if (progress ==
            'Done - (Review)')
          return false;

        final Timestamp? endTimestamp = data['endDate'];
        if (endTimestamp ==
            null)
          return false;

        final endDate = endTimestamp.toDate();
        final difference = endDate.difference(
          now,
        );

        // Overdue or less than 24 hours remaining
        return difference.inHours <
            24;
      },
    ).length;

    // 2. Calculate Completed Tasks
    final totalTasksCount = userTasks.length;
    final completedTasksCount = userTasks.where(
      (
        doc,
      ) {
        final progress =
            doc.data()['taskProgress'] ??
            'Not started';
        return progress ==
            'Done - (Review)';
      },
    ).length;

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
                // Card 1: Total Allocated Area
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
                // Card 2: Open-Meteo Weather Widget
                const _WeatherMetricCard(),
                // Card 3: Active Alerts (Overdue / Nearing Deadline)
                _MetricCard(
                  title: 'ACTIVE ALERTS',
                  value: overdueOrNearingCount.toString().padLeft(
                    2,
                    '0',
                  ),
                  subtext:
                      overdueOrNearingCount >
                          0
                      ? '⚠️ Task(s) due < 24h or overdue'
                      : 'All tasks on schedule',
                  subtextColor:
                      overdueOrNearingCount >
                          0
                      ? Colors.red
                      : const Color(
                          0xFF1CB026,
                        ),
                  icon: Icons.warning_amber_rounded,
                  iconColor:
                      overdueOrNearingCount >
                          0
                      ? Colors.red
                      : Colors.black,
                ),
                // Card 4: Completed Tasks Ratio
                _MetricCard(
                  title: 'COMPLETED TASKS',
                  value: '$completedTasksCount/$totalTasksCount',
                  subtext:
                      totalTasksCount ==
                          0
                      ? '0% completion rate'
                      : '• ${((completedTasksCount / totalTasksCount) * 100).toStringAsFixed(0)}% completion rate',
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

/// Weather Card fetching live Open-Meteo Data (Default coordinates set to South Africa / Central region)
class _WeatherMetricCard
    extends
        StatefulWidget {
  const _WeatherMetricCard();

  @override
  State<
    _WeatherMetricCard
  >
  createState() => _WeatherMetricCardState();
}

class _WeatherMetricCardState
    extends
        State<
          _WeatherMetricCard
        > {
  bool _isLoading = true;
  double _temperature = 0.0;
  double _precipitationProbability = 0.0;
  double _precipitationAccumulation = 0.0;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<
    void
  >
  _fetchWeatherData() async {
    try {
      // Open-Meteo API endpoint for current weather and hourly rain probability/accumulation
      // Coordinates set to a standard regional farm zone (-26.2041, 28.0473 as default reference)
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=-26.2041&longitude=28.0473&current=temperature_2m&hourly=precipitation_probability,precipitation',
      );

      final response = await http.get(
        url,
      );
      if (response.statusCode ==
          200) {
        final data = json.decode(
          response.body,
        );
        final currentTemp =
            data['current']['temperature_2m'] ??
            0.0;

        // Grab current hour index precipitation metrics
        final hourly = data['hourly'];
        final List<
          dynamic
        >
        probs =
            hourly['precipitation_probability'] ??
            [
              0.0,
            ];
        final List<
          dynamic
        >
        precip =
            hourly['precipitation'] ??
            [
              0.0,
            ];

        if (mounted) {
          setState(
            () {
              _temperature = currentTemp.toDouble();
              _precipitationProbability =
                  (probs.isNotEmpty
                          ? probs[0]
                          : 0.0)
                      .toDouble();
              _precipitationAccumulation =
                  (precip.isNotEmpty
                          ? precip[0]
                          : 0.0)
                      .toDouble();
              _isLoading = false;
            },
          );
        }
      } else {
        if (mounted)
          setState(
            () => _isLoading = false,
          );
      }
    } catch (
      e
    ) {
      if (mounted) {
        setState(
          () {
            _isLoading = false;
            _errorMessage = 'Weather unavailable';
          },
        );
      }
    }
  }

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
      child: _isLoading
          ? const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(
                    0xFF1CB026,
                  ),
                ),
              ),
            )
          : _errorMessage.isNotEmpty
          ? Center(
              child: Text(
                _errorMessage,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'LOCAL WEATHER (OPEN-METEO)',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[500],
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Icon(
                      Icons.wb_sunny_outlined,
                      size: 18,
                      color: Color(
                        0xFF1CB026,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${_temperature.toStringAsFixed(1)}°C',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(
                      0xFF1A1A1A,
                    ),
                  ),
                ),
                Text(
                  '🌧️ Rain Prob: ${_precipitationProbability.toStringAsFixed(0)}% | Rain: ${_precipitationAccumulation.toStringAsFixed(1)}mm',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(
                      0xFF1CB026,
                    ),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
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

/// Operational Tasks Right Panel (Dynamic Stream from 'farmTasks')
class _OperationalTasksSection
    extends
        StatelessWidget {
  const _OperationalTasksSection();

  static const Color primaryColor = Color(
    0xFF1CB026,
  );

  /// Pre-Commencement Checklist Dialog
  void _showPreCommencementChecklist(
    BuildContext context,
    String taskId,
  ) {
    bool checkWeather = false;
    bool checkEquipment = false;
    bool checkSafetyGear = false;

    showDialog(
      context: context,
      builder:
          (
            context,
          ) {
            return StatefulBuilder(
              builder:
                  (
                    context,
                    setDialogState,
                  ) {
                    bool canStart =
                        checkWeather &&
                        checkEquipment &&
                        checkSafetyGear;

                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                      ),
                      title: const Text(
                        'Pre-Commencement Checklist',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: SizedBox(
                        width: 400,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Complete safety and readiness checks before starting:',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            CheckboxListTile(
                              title: const Text(
                                'Weather and field conditions verified safe',
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                              value: checkWeather,
                              activeColor: primaryColor,
                              onChanged:
                                  (
                                    val,
                                  ) => setDialogState(
                                    () => checkWeather =
                                        val ??
                                        false,
                                  ),
                            ),
                            CheckboxListTile(
                              title: const Text(
                                'Required equipment/tools inspected & ready',
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                              value: checkEquipment,
                              activeColor: primaryColor,
                              onChanged:
                                  (
                                    val,
                                  ) => setDialogState(
                                    () => checkEquipment =
                                        val ??
                                        false,
                                  ),
                            ),
                            CheckboxListTile(
                              title: const Text(
                                'Proper safety gear / PPE worn',
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                              value: checkSafetyGear,
                              activeColor: primaryColor,
                              onChanged:
                                  (
                                    val,
                                  ) => setDialogState(
                                    () => checkSafetyGear =
                                        val ??
                                        false,
                                  ),
                            ),
                          ],
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
                        ElevatedButton(
                          onPressed: !canStart
                              ? null
                              : () async {
                                  // Update Firestore task status to In progress
                                  await FirebaseFirestore.instance
                                      .collection(
                                        'farmTasks',
                                      )
                                      .doc(
                                        taskId,
                                      )
                                      .update(
                                        {
                                          'taskProgress': 'In progress',
                                          'startedAtByWorker': FieldValue.serverTimestamp(),
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
                                        'Task started successfully!',
                                      ),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            elevation: 0,
                          ),
                          child: const Text(
                            'Confirm & Start',
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
          },
    );
  }

  /// Post-Completion Checklist Dialog
  void _showPostCompletionChecklist(
    BuildContext context,
    String taskId,
  ) {
    bool cleanArea = false;
    bool storeTools = false;
    bool reportLogged = false;

    showDialog(
      context: context,
      builder:
          (
            context,
          ) {
            return StatefulBuilder(
              builder:
                  (
                    context,
                    setDialogState,
                  ) {
                    bool canComplete =
                        cleanArea &&
                        storeTools &&
                        reportLogged;

                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                      ),
                      title: const Text(
                        'Post-Completion Checklist',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: SizedBox(
                        width: 400,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Complete wrap-up verifications before marking task done:',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            CheckboxListTile(
                              title: const Text(
                                'Work area cleaned and secured',
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                              value: cleanArea,
                              activeColor: primaryColor,
                              onChanged:
                                  (
                                    val,
                                  ) => setDialogState(
                                    () => cleanArea =
                                        val ??
                                        false,
                                  ),
                            ),
                            CheckboxListTile(
                              title: const Text(
                                'Tools and equipment returned safely',
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                              value: storeTools,
                              activeColor: primaryColor,
                              onChanged:
                                  (
                                    val,
                                  ) => setDialogState(
                                    () => storeTools =
                                        val ??
                                        false,
                                  ),
                            ),
                            CheckboxListTile(
                              title: const Text(
                                'Activity results logged / reported',
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                              value: reportLogged,
                              activeColor: primaryColor,
                              onChanged:
                                  (
                                    val,
                                  ) => setDialogState(
                                    () => reportLogged =
                                        val ??
                                        false,
                                  ),
                            ),
                          ],
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
                        ElevatedButton(
                          onPressed: !canComplete
                              ? null
                              : () async {
                                  // Update Firestore task status to Done - (Review)
                                  await FirebaseFirestore.instance
                                      .collection(
                                        'farmTasks',
                                      )
                                      .doc(
                                        taskId,
                                      )
                                      .update(
                                        {
                                          'taskProgress': 'Done - (Review)',
                                          'completedAtByWorker': FieldValue.serverTimestamp(),
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
                                        'Task submitted for review!',
                                      ),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            elevation: 0,
                          ),
                          child: const Text(
                            'Complete & Submit',
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
          },
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
                  'farmTasks',
                )
                .where(
                  'assignedToUid',
                  isEqualTo: currentUser.uid,
                )
                .snapshots(),
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

                  final taskDocs =
                      snapshot.data?.docs ??
                      [];
                  final pendingTasks = taskDocs.where(
                    (
                      doc,
                    ) {
                      final progress =
                          doc.data()['taskProgress'] ??
                          'Not started';
                      return progress !=
                          'Done - (Review)';
                    },
                  ).toList();

                  return Column(
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
                              '${pendingTasks.length} Pending',
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
                      if (taskDocs.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(
                            16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFFAFAFA,
                            ),
                            borderRadius: BorderRadius.circular(
                              8,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'No assigned tasks found.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: taskDocs.length,
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
                                final doc = taskDocs[index];
                                final data = doc.data();
                                final title =
                                    data['taskTitle'] ??
                                    'Task';
                                final farmName =
                                    data['farmName'] ??
                                    'Farm';
                                final description =
                                    data['description'] ??
                                    '';
                                final progress =
                                    data['taskProgress'] ??
                                    'Not started';

                                Widget actionButton;
                                if (progress ==
                                    'Not started') {
                                  actionButton = ElevatedButton(
                                    onPressed: () => _showPreCommencementChecklist(
                                      context,
                                      doc.id,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
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
                                      'Start Task',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                } else if (progress ==
                                    'In progress') {
                                  actionButton = ElevatedButton(
                                    onPressed: () => _showPostCompletionChecklist(
                                      context,
                                      doc.id,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.amber[800],
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
                                  );
                                } else {
                                  actionButton = Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        6,
                                      ),
                                    ),
                                    child: const Text(
                                      'Under Review',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                  );
                                }

                                return _TaskCard(
                                  icon: Icons.task_alt,
                                  iconColor:
                                      progress ==
                                          'In progress'
                                      ? Colors.amber[800]!
                                      : primaryColor,
                                  title: title,
                                  subtitle: '$farmName • Status: $progress',
                                  description: description,
                                  actions: [
                                    actionButton,
                                  ],
                                );
                              },
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
