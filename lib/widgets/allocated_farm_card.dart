import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:innotegy/constants.dart';
import 'package:latlong2/latlong.dart';
import '../models/farm_model.dart';

class AllocatedFarmCard
    extends
        StatelessWidget {
  final FarmModel farm;
  final VoidCallback? onTap;

  const AllocatedFarmCard({
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
                    ],
                  ),
                  const SizedBox(
                    height: 12,
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
