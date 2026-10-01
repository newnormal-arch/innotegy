import 'package:flutter/material.dart';
import 'package:innotegy/services/weather_service.dart';

class WeatherWidget
    extends
        StatelessWidget {
  final double lat;
  final double lng;

  const WeatherWidget({
    super.key,
    required this.lat,
    required this.lng,
  });

  @override
  Widget build(
    BuildContext me,
  ) {
    return FutureBuilder<
      List<
        DailyWeatherData
      >
    >(
      future: WeatherService.fetchDailyForecast(
        latitude: lat,
        longitude: lng,
      ),
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
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                ),
              );
            }

            final today = snapshot.data!.first;

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  12,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(
                  16.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weather Forecast (${today.date})',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Temp: ${today.minTemp}°C - ${today.maxTemp}°C',
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.water_drop,
                              color: Colors.blue,
                              size: 18,
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              '${today.rainSum} mm (${today.maxRainProbability}%)',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
    );
  }
}
