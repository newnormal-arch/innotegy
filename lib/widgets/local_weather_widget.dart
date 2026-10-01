import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:innotegy/services/location_service.dart';
import 'package:innotegy/widgets/weather_widget.dart';

class LocalWeatherWidget
    extends
        StatelessWidget {
  const LocalWeatherWidget({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return FutureBuilder<
      Position
    >(
      future: LocationService.getCurrentLocation(),
      builder:
          (
            context,
            snapshot,
          ) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    Text(
                      'Getting location...',
                    ),
                  ],
                ),
              );
            }

            // Handle permission errors or disabled location by providing fallbacks
            if (snapshot.hasError) {
              return Card(
                color: Colors.amber.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(
                    12.0,
                  ),
                  child: Text(
                    'Location access unavailable (${snapshot.error}). Loading default city...',
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),
              );
              // Note: You can return WeatherWidget(lat: 51.5074, lng: -0.1278) here as a fallback (e.g. London)
            }

            final position = snapshot.data!;

            // Pass dynamic lat/lng to your WeatherWidget
            return WeatherWidget(
              lat: position.latitude,
              lng: position.longitude,
            );
          },
    );
  }
}
