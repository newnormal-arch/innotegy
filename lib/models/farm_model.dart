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
