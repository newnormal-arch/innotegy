import 'dart:convert';
import 'package:http/http.dart' as http;

class DailyWeatherData {
  final String date;
  final double maxTemp;
  final double minTemp;
  final double rainSum; // Rain accumulation in mm
  final int maxRainProbability;

  DailyWeatherData({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.rainSum,
    required this.maxRainProbability,
  });
}

class WeatherService {
  static Future<
    List<
      DailyWeatherData
    >
  >
  fetchDailyForecast({
    required double latitude,
    required double longitude,
  }) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$latitude'
      '&longitude=$longitude'
      '&daily=temperature_2m_max,temperature_2m_min,rain_sum,precipitation_probability_max'
      '&timezone=auto',
    );

    final response = await http.get(
      url,
    );

    if (response.statusCode ==
        200) {
      final data = jsonDecode(
        response.body,
      );
      final daily = data['daily'];

      List<
        DailyWeatherData
      >
      forecast = [];
      for (
        int i = 0;
        i <
            (daily['time']
                    as List)
                .length;
        i++
      ) {
        forecast.add(
          DailyWeatherData(
            date: daily['time'][i],
            maxTemp:
                (daily['temperature_2m_max'][i]
                        as num)
                    .toDouble(),
            minTemp:
                (daily['temperature_2m_min'][i]
                        as num)
                    .toDouble(),
            rainSum:
                (daily['rain_sum'][i]
                        as num)
                    .toDouble(),
            maxRainProbability:
                (daily['precipitation_probability_max'][i]
                        as num)
                    .toInt(),
          ),
        );
      }
      return forecast;
    } else {
      throw Exception(
        'Failed to load weather data',
      );
    }
  }
}
