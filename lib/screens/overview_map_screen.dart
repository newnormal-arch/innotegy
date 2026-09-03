import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/farm_model.dart';

class OverviewMapScreen
    extends
        StatefulWidget {
  final List<
    FarmModel
  >
  farms;

  const OverviewMapScreen({
    super.key,
    required this.farms,
  });

  @override
  State<
    OverviewMapScreen
  >
  createState() => _OverviewMapScreenState();
}

class _OverviewMapScreenState
    extends
        State<
          OverviewMapScreen
        > {
  final MapController _mapController = MapController();
  FarmModel? _selectedFarm;

  final List<
    Color
  >
  _polygonColors = [
    Colors.green,
    Colors.amber,
    Colors.cyan,
    Colors.orange,
    Colors.purple,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (
        _,
      ) => _zoomToFitAll(),
    );
  }

  void _zoomToFitAll() {
    final allPoints = widget.farms
        .expand(
          (
            farm,
          ) => farm.points,
        )
        .toList();
    if (allPoints.isEmpty) return;

    final bounds = LatLngBounds.fromPoints(
      allPoints,
    );
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(
          60.0,
        ),
      ),
    );

    setState(
      () => _selectedFarm = null,
    );
  }

  void _zoomToFarm(
    FarmModel farm,
  ) {
    if (farm.points.isEmpty) return;

    final bounds = LatLngBounds.fromPoints(
      farm.points,
    );
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(
          80.0,
        ),
      ),
    );

    setState(
      () => _selectedFarm = farm,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Farms Overview',
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.zoom_out_map,
            ),
            tooltip: 'Fit All Farms',
            onPressed: _zoomToFitAll,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(
                0,
                0,
              ),
              initialZoom: 2,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                userAgentPackageName: 'com.example.farm_app',
              ),
              PolygonLayer(
                polygons: widget.farms.asMap().entries.map(
                  (
                    entry,
                  ) {
                    final index = entry.key;
                    final farm = entry.value;
                    final color =
                        _polygonColors[index %
                            _polygonColors.length];
                    final isSelected =
                        _selectedFarm?.id ==
                        farm.id;

                    return Polygon(
                      points: farm.points,
                      color: color.withValues(
                        alpha: isSelected
                            ? 0.55
                            : 0.35,
                      ),
                      borderColor: isSelected
                          ? Colors.white
                          : color,
                      borderStrokeWidth: isSelected
                          ? 4.0
                          : 2.5,
                      // isFilled: true,
                      label: '${farm.name}\n(${farm.areaInHectares.toStringAsFixed(1)} ha)',
                      labelStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isSelected
                            ? 14
                            : 12,
                        backgroundColor: Colors.black87,
                      ),
                    );
                  },
                ).toList(),
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.farms.length,
                itemBuilder:
                    (
                      context,
                      index,
                    ) {
                      final farm = widget.farms[index];
                      final isSelected =
                          _selectedFarm?.id ==
                          farm.id;
                      final color =
                          _polygonColors[index %
                              _polygonColors.length];

                      return Padding(
                        padding: const EdgeInsets.only(
                          right: 12,
                        ),
                        child: Material(
                          elevation: isSelected
                              ? 8
                              : 4,
                          borderRadius: BorderRadius.circular(
                            16,
                          ),
                          color: isSelected
                              ? Colors.green.shade900
                              : Colors.black87,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(
                              16,
                            ),
                            onTap: () => _zoomToFarm(
                              farm,
                            ),
                            child: Container(
                              width: 200,
                              padding: const EdgeInsets.all(
                                12,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  16,
                                ),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.lightGreenAccent
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Expanded(
                                        child: Text(
                                          farm.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${farm.areaInHectares.toStringAsFixed(2)} ha',
                                        style: const TextStyle(
                                          color: Colors.lightGreenAccent,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.center_focus_strong,
                                        color: Colors.white70,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
