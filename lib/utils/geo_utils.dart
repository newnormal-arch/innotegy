import 'dart:math';
import 'package:latlong2/latlong.dart';

class GeoUtils {
  /// Calculates polygon surface area in hectares
  static double calculateHectares(
    List<
      LatLng
    >
    points,
  ) {
    if (points.length <
        3) {
      return 0.0;
    }

    const double radiusOfEarth = 6378137.0; // Radius in meters
    double area = 0.0;

    for (
      int i = 0;
      i <
          points.length;
      i++
    ) {
      final p1 = points[i];
      final p2 =
          points[(i +
                  1) %
              points.length];

      final lat1Rad =
          p1.latitude *
          pi /
          180;
      final lat2Rad =
          p2.latitude *
          pi /
          180;
      final deltaLngRad =
          (p2.longitude -
              p1.longitude) *
          pi /
          180;

      area +=
          deltaLngRad *
          (2 +
              sin(
                lat1Rad,
              ) +
              sin(
                lat2Rad,
              ));
    }

    area =
        (area *
                radiusOfEarth *
                radiusOfEarth /
                4.0)
            .abs();
    return area /
        10000.0; // Convert m² to hectares
  }
}
