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
                        // Auto-fit camera to polygon bounds
                        initialCameraFit: CameraFit.bounds(
                          bounds: bounds,
                          padding: const EdgeInsets.all(
                            16.0,
                          ),
                        ),
                        // Disable all gestures so touch events scroll the list cleanly
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        // Satellite imagery tile layer
                        TileLayer(
                          urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                          userAgentPackageName: 'com.example.farm_app',
                        ),
                        // Field polygon overlay
                        PolygonLayer(
                          polygons: [
                            Polygon(
                              points: farm.points,
                              color: Colors.green.withValues(
                                alpha: 0.45,
                              ),
                              borderColor: Colors.lightGreenAccent,
                              borderStrokeWidth: 2.5,
                              // isFilled: true,
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
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => showAllocateFarmerDialog(
                        context,
                        farm,
                      ),
                      icon: const Icon(
                        Icons.person_add_alt_1,
                        color: primaryGreenColor,
                      ),
                      label: const Text(
                        'Allocate Farmer',
                        style: TextStyle(
                          color: primaryGreenColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: primaryGreenColor,
                        ),
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
                      horizontal: 200,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(
                        32.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Allocate Farmer to ${farm.name}',
                            style: const TextStyle(
                              fontSize: 22,
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
                            height: 24,
                          ),

                          // Query Firestore Farmers
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
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                          20.0,
                                        ),
                                        child: CircularProgressIndicator(),
                                      ),
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
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16.0,
                                      ),
                                      child: Text(
                                        'No registered farmers found.',
                                      ),
                                    );
                                  }

                                  return DropdownButtonFormField<
                                    String
                                  >(
                                    initialValue: selectedFarmerId,
                                    hint: const Text(
                                      'Select a Farmer',
                                    ),
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      labelText: 'Farmer Name',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          8,
                                        ),
                                      ),
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
                            height: 30,
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
                                          // Update the selected farmer doc in Firestore
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
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
                                    fontWeight: FontWeight.bold,
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
