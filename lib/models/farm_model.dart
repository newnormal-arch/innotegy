import 'package:latlong2/latlong.dart';
import '../utils/geo_utils.dart';

class FarmModel {
  final String id;
  final String name;
  final String locationName;
  final String mapId;
  final List<
    LatLng
  >
  points;
  final double areaInHectares;

  FarmModel({
    required this.id,
    required this.name,
    required this.locationName,
    required this.mapId,
    required this.points,
    required this.areaInHectares,
  });

  /// Getter for the farm's center latitude (centroid of points)
  double get latitude {
    if (points.isEmpty) return -26.2041;
    double sumLat = 0.0;
    for (var p in points) {
      sumLat += p.latitude;
    }
    return sumLat /
        points.length;
  }

  /// Getter for the farm's center longitude (centroid of points)
  double get longitude {
    if (points.isEmpty) return 28.0473;
    double sumLng = 0.0;
    for (var p in points) {
      sumLng += p.longitude;
    }
    return sumLng /
        points.length;
  }

  /// Factory to instantiate a farm directly from KML Placemark data
  factory FarmModel.fromKmlPlacemark({
    required String id,
    required String name,
    required String mapId,
    required List<
      LatLng
    >
    points,
    String locationName = 'Google My Maps',
  }) {
    final area = GeoUtils.calculateHectares(
      points,
    );
    return FarmModel(
      id: id,
      name: name,
      locationName: locationName,
      mapId: mapId,
      points: points,
      areaInHectares: area,
    );
  }
}
