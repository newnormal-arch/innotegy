import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:innotegy/constants.dart';
import 'package:latlong2/latlong.dart';
import '../models/farm_model.dart';

class FarmCard
    extends
        StatelessWidget {
  final FarmModel farm;
  final VoidCallback? onTap;

  const FarmCard({
    super.key,
    required this.farm,
    this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    // Calculate bounding box for the mini-map preview
    final LatLngBounds? bounds = farm.points.isNotEmpty
        ? LatLngBounds.fromPoints(
            farm.points,
          )
        : null;

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias, // Ensures map rounds cleanly with card corners
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          16,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Map Snapshot / Preview Container
            SizedBox(
              height: 120,
              width: double.infinity,
              child:
                  bounds !=
                      null
                  ? FlutterMap(
                      options: MapOptions(
                        initialCameraFit: CameraFit.bounds(
                          bounds: bounds,
                          padding: const EdgeInsets.all(
                            16.0,
                          ),
                        ),
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                          userAgentPackageName: 'com.example.farm_app',
                        ),
                        PolygonLayer(
                          polygons: [
                            Polygon(
                              points: farm.points,
                              color: Colors.green.withValues(
                                alpha: 0.45,
                              ),
                              borderColor: Colors.lightGreenAccent,
                              borderStrokeWidth: 2.5,
                            ),
                          ],
                        ),
                      ],
                    )
                  : Container(
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(
                          Icons.map,
                          color: Colors.grey,
                          size: 40,
                        ),
                      ),
                    ),
            ),

            // 2. Card Content Details
            Padding(
              padding: const EdgeInsets.all(
                16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.agriculture,
                        color: Colors.green,
                        size: 24,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Text(
                          farm.name,
                          style:
                              Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Area Size',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${farm.areaInHectares.toStringAsFixed(2)} ha',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Boundary Points',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${farm.points.length} vertices',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),

                  // Row for Allocate Farmer & Allocate Manager Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => showAllocateFarmerDialog(
                            context,
                            farm,
                          ),
                          icon: const Icon(
                            Icons.person_add_alt_1,
                            color: primaryGreenColor,
                            size: 18,
                          ),
                          label: const Text(
                            'Farmer',
                            style: TextStyle(
                              color: primaryGreenColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: primaryGreenColor,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                8,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => showAllocateManagerDialog(
                            context,
                            farm,
                          ),
                          icon: const Icon(
                            Icons.supervisor_account,
                            color: primaryGreenColor,
                            size: 18,
                          ),
                          label: const Text(
                            'Manager',
                            style: TextStyle(
                              color: primaryGreenColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: primaryGreenColor,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
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
                  const SizedBox(
                    height: 8,
                  ),

                  // Add Task Button spanning the full width underneath
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => showAddTaskDialog(
                        context,
                        farm,
                      ),
                      icon: const Icon(
                        Icons.add_task,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: const Text(
                        'Add Task',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreenColor,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
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
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// DIALOG: Add Task
// ---------------------------------------------------------------------------
void
showAddTaskDialog(
  BuildContext context,
  FarmModel farm,
) {
  final TextEditingController taskNameController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  String? selectedFarmerId;

  showDialog(
    context: context,
    builder:
        (
          dialogContext,
        ) {
          return StatefulBuilder(
            builder:
                (
                  context,
                  setState,
                ) {
                  String formatDate(
                    DateTime? date,
                  ) {
                    if (date ==
                        null)
                      return 'Select Date';
                    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                  }

                  Future<
                    void
                  >
                  pickDate(
                    bool isStart,
                  ) async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(
                        const Duration(
                          days: 30,
                        ),
                      ),
                      lastDate: DateTime(
                        2100,
                      ),
                    );
                    if (picked !=
                        null) {
                      setState(
                        () {
                          if (isStart) {
                            startDate = picked;
                          } else {
                            endDate = picked;
                          }
                        },
                      );
                    }
                  }

                  return Dialog(
                    insetPadding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 24,
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(
                          24.0,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add Task for ${farm.name}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),

                            // Task Name Field
                            TextField(
                              controller: taskNameController,
                              decoration: InputDecoration(
                                labelText: 'Task Name',
                                hintText: 'e.g., Irrigation, Fertilization',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    8,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),

                            // Start & End Date Pickers
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => pickDate(
                                      true,
                                    ),
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: 'Start Date',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        suffixIcon: const Icon(
                                          Icons.calendar_today,
                                          size: 18,
                                        ),
                                      ),
                                      child: Text(
                                        formatDate(
                                          startDate,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => pickDate(
                                      false,
                                    ),
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: 'End Date',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        suffixIcon: const Icon(
                                          Icons.calendar_today,
                                          size: 18,
                                        ),
                                      ),
                                      child: Text(
                                        formatDate(
                                          endDate,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 16,
                            ),

                            // Farmers Dropdown
                            FutureBuilder<
                              QuerySnapshot
                            >(
                              future: FirebaseFirestore.instance
                                  .collection(
                                    'farmer',
                                  )
                                  .get(),
                              builder:
                                  (
                                    context,
                                    snapshot,
                                  ) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }

                                    if (snapshot.hasError) {
                                      return Text(
                                        'Error loading farmers: ${snapshot.error}',
                                      );
                                    }

                                    final farmerDocs =
                                        snapshot.data?.docs ??
                                        [];

                                    if (farmerDocs.isEmpty) {
                                      return const Text(
                                        'No registered farmers found.',
                                      );
                                    }

                                    return DropdownButtonFormField<
                                      String
                                    >(
                                      initialValue: selectedFarmerId,
                                      isExpanded: true,
                                      decoration: InputDecoration(
                                        labelText: 'Assign to Farmer',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      hint: const Text(
                                        'Select Farmer',
                                      ),
                                      items: farmerDocs.map(
                                        (
                                          doc,
                                        ) {
                                          final data =
                                              doc.data()
                                                  as Map<
                                                    String,
                                                    dynamic
                                                  >;
                                          final String fullName =
                                              data['fullName'] ??
                                              'Unknown Farmer';
                                          return DropdownMenuItem<
                                            String
                                          >(
                                            value: doc.id,
                                            child: Text(
                                              fullName,
                                            ),
                                          );
                                        },
                                      ).toList(),
                                      onChanged:
                                          (
                                            val,
                                          ) {
                                            setState(
                                              () => selectedFarmerId = val,
                                            );
                                          },
                                    );
                                  },
                            ),
                            const SizedBox(
                              height: 24,
                            ),

                            // Actions
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.of(
                                    dialogContext,
                                  ).pop(),
                                  child: const Text(
                                    'Cancel',
                                  ),
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                ElevatedButton(
                                  onPressed:
                                      (taskNameController.text.trim().isEmpty ||
                                          startDate ==
                                              null ||
                                          endDate ==
                                              null ||
                                          selectedFarmerId ==
                                              null)
                                      ? null
                                      : () async {
                                          EasyLoading.show(
                                            status: 'Creating Task...',
                                          );
                                          try {
                                            await FirebaseFirestore.instance
                                                .collection(
                                                  'tasks',
                                                )
                                                .add(
                                                  {
                                                    'taskName': taskNameController.text.trim(),
                                                    'startDate': Timestamp.fromDate(
                                                      startDate!,
                                                    ),
                                                    'endDate': Timestamp.fromDate(
                                                      endDate!,
                                                    ),
                                                    'farmerId': selectedFarmerId,
                                                    'farmName': farm.name,
                                                    'createdAt': FieldValue.serverTimestamp(),
                                                  },
                                                );

                                            if (context.mounted) {
                                              Navigator.of(
                                                dialogContext,
                                              ).pop();
                                            }
                                            EasyLoading.showSuccess(
                                              'Task added successfully!',
                                            );
                                          } catch (
                                            e
                                          ) {
                                            EasyLoading.showError(
                                              'Failed to add task',
                                            );
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryGreenColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        8,
                                      ),
                                    ),
                                  ),
                                  child: const Text(
                                    'Save Task',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
          );
        },
  );
}

// ---------------------------------------------------------------------------
// DIALOG: Allocate Manager
// ---------------------------------------------------------------------------
void
showAllocateManagerDialog(
  BuildContext context,
  FarmModel farm,
) {
  String? selectedManagerId;

  showDialog(
    context: context,
    builder:
        (
          dialogContext,
        ) {
          return StatefulBuilder(
            builder:
                (
                  context,
                  setState,
                ) {
                  return Dialog(
                    insetPadding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 24,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(
                        24.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Allocate Manager to ${farm.name}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            'Select a manager to oversee this farm.',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          FutureBuilder<
                            QuerySnapshot
                          >(
                            future: FirebaseFirestore.instance
                                .collection(
                                  'consultant',
                                )
                                .get(),
                            builder:
                                (
                                  context,
                                  snapshot,
                                ) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  if (snapshot.hasError) {
                                    return Text(
                                      'Error loading managers: ${snapshot.error}',
                                    );
                                  }

                                  final managerDocs =
                                      snapshot.data?.docs ??
                                      [];

                                  if (managerDocs.isEmpty) {
                                    return const Text(
                                      'No registered managers found.',
                                    );
                                  }

                                  return DropdownButtonFormField<
                                    String
                                  >(
                                    initialValue: selectedManagerId,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      labelText: 'Manager Name',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          8,
                                        ),
                                      ),
                                    ),
                                    hint: const Text(
                                      'Select a Manager',
                                    ),
                                    items: managerDocs.map(
                                      (
                                        doc,
                                      ) {
                                        final data =
                                            doc.data()
                                                as Map<
                                                  String,
                                                  dynamic
                                                >;
                                        final String fullName =
                                            data['fullName'] ??
                                            'Unknown Manager';
                                        return DropdownMenuItem<
                                          String
                                        >(
                                          value: doc.id,
                                          child: Text(
                                            fullName,
                                          ),
                                        );
                                      },
                                    ).toList(),
                                    onChanged:
                                        (
                                          value,
                                        ) {
                                          setState(
                                            () => selectedManagerId = value,
                                          );
                                        },
                                  );
                                },
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.of(
                                  dialogContext,
                                ).pop(),
                                child: const Text(
                                  'Cancel',
                                ),
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              ElevatedButton(
                                onPressed:
                                    selectedManagerId ==
                                        null
                                    ? null
                                    : () async {
                                        EasyLoading.show(
                                          status: 'Assigning Manager...',
                                        );
                                        try {
                                          await FirebaseFirestore.instance
                                              .collection(
                                                'consultant',
                                              )
                                              .doc(
                                                selectedManagerId,
                                              )
                                              .update(
                                                {
                                                  'allocatedFarm': farm.name,
                                                },
                                              );

                                          if (context.mounted) {
                                            Navigator.of(
                                              dialogContext,
                                            ).pop();
                                          }
                                          EasyLoading.showSuccess(
                                            'Manager allocated successfully!',
                                          );
                                        } catch (
                                          e
                                        ) {
                                          EasyLoading.showError(
                                            'Failed to allocate manager',
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryGreenColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      8,
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Allocate',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
          );
        },
  );
}

// ---------------------------------------------------------------------------
// DIALOG: Allocate Farmer
// ---------------------------------------------------------------------------
void
showAllocateFarmerDialog(
  BuildContext context,
  FarmModel farm,
) {
  String? selectedFarmerId;

  showDialog(
    context: context,
    builder:
        (
          dialogContext,
        ) {
          return StatefulBuilder(
            builder:
                (
                  context,
                  setState,
                ) {
                  return Dialog(
                    insetPadding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 24,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(
                        24.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Allocate Farmer to ${farm.name}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            'Select a farmer from your database to assign to this farm.',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          FutureBuilder<
                            QuerySnapshot
                          >(
                            future: FirebaseFirestore.instance
                                .collection(
                                  'farmer',
                                )
                                .get(),
                            builder:
                                (
                                  context,
                                  snapshot,
                                ) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  if (snapshot.hasError) {
                                    return Text(
                                      'Error loading farmers: ${snapshot.error}',
                                    );
                                  }

                                  final farmerDocs =
                                      snapshot.data?.docs ??
                                      [];

                                  if (farmerDocs.isEmpty) {
                                    return const Text(
                                      'No registered farmers found.',
                                    );
                                  }

                                  return DropdownButtonFormField<
                                    String
                                  >(
                                    initialValue: selectedFarmerId,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      labelText: 'Farmer Name',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          8,
                                        ),
                                      ),
                                    ),
                                    hint: const Text(
                                      'Select a Farmer',
                                    ),
                                    items: farmerDocs.map(
                                      (
                                        doc,
                                      ) {
                                        final data =
                                            doc.data()
                                                as Map<
                                                  String,
                                                  dynamic
                                                >;
                                        final String fullName =
                                            data['fullName'] ??
                                            'Unknown Farmer';
                                        final String? currentFarm = data['allocatedFarm'];
                                        final String label =
                                            currentFarm !=
                                                    null &&
                                                currentFarm.isNotEmpty
                                            ? '$fullName (Currently: $currentFarm)'
                                            : fullName;

                                        return DropdownMenuItem<
                                          String
                                        >(
                                          value: doc.id,
                                          child: Text(
                                            label,
                                          ),
                                        );
                                      },
                                    ).toList(),
                                    onChanged:
                                        (
                                          value,
                                        ) {
                                          setState(
                                            () => selectedFarmerId = value,
                                          );
                                        },
                                  );
                                },
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.of(
                                  dialogContext,
                                ).pop(),
                                child: const Text(
                                  'Cancel',
                                ),
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              ElevatedButton(
                                onPressed:
                                    selectedFarmerId ==
                                        null
                                    ? null
                                    : () async {
                                        EasyLoading.show(
                                          status: 'Assigning Farm...',
                                        );
                                        try {
                                          await FirebaseFirestore.instance
                                              .collection(
                                                'farmer',
                                              )
                                              .doc(
                                                selectedFarmerId,
                                              )
                                              .update(
                                                {
                                                  'allocatedFarm': farm.name,
                                                },
                                              );

                                          if (context.mounted) {
                                            Navigator.of(
                                              dialogContext,
                                            ).pop();
                                          }
                                          EasyLoading.showSuccess(
                                            'Farmer allocated successfully!',
                                          );
                                        } catch (
                                          e
                                        ) {
                                          EasyLoading.showError(
                                            'Failed to allocate farmer',
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryGreenColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      8,
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Allocate',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
          );
        },
  );
}
