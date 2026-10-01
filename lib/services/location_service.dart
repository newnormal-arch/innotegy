import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<
    Position
  >
  getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled on the browser/device
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
        'Location services are disabled in your browser or system.',
      );
    }

    // Check current permission status
    permission = await Geolocator.checkPermission();
    if (permission ==
        LocationPermission.denied) {
      // Trigger native browser permission prompt
      permission = await Geolocator.requestPermission();
      if (permission ==
          LocationPermission.denied) {
        throw Exception(
          'Location permission denied by user.',
        );
      }
    }

    if (permission ==
        LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied. Please update browser site settings.',
      );
    }

    // Retrieve current coordinates
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low, // Low accuracy is faster and sufficient for city-level weather
      ),
    );
  }
}
