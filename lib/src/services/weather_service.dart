import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/forecast_day.dart';

class WeatherResult {
  final String cityName;
  final String? country;
  final double? temp;
  final double? wind;
  final String? description;
  final String? iconCode;
  final List<ForecastDay> forecast;

  WeatherResult({
    required this.cityName,
    this.country,
    this.temp,
    this.wind,
    this.description,
    this.iconCode,
    required this.forecast,
  });
}

class WeatherService {
  final String _openWeatherKey;

  WeatherService(this._openWeatherKey);

  Future<WeatherResult> fetchWeather(String city) async {
    final weatherUrl = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$_openWeatherKey&units=metric');

    final weatherResponse = await http.get(weatherUrl);
    if (weatherResponse.statusCode != 200) {
      throw Exception('Weather fetch failed: ${weatherResponse.statusCode}');
    }

    final weatherData = jsonDecode(weatherResponse.body);
    final name = weatherData['name'] as String;
    final country = weatherData['sys']?['country'] as String?;
    final temp = (weatherData['main']?['temp'] as num?)?.toDouble();
    final wind = (weatherData['wind']?['speed'] as num?)?.toDouble();
    final description = weatherData['weather']?[0]?['description'] as String?;
    final icon = weatherData['weather']?[0]?['icon'] as String?;
    final lat = (weatherData['coord']?['lat'] as num?)?.toDouble();
    final lon = (weatherData['coord']?['lon'] as num?)?.toDouble();

    List<ForecastDay> forecast = [];
    if (lat != null && lon != null) {
      final forecastUrl = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&daily=weather_code,temperature_2m_max,temperature_2m_min,wind_speed_10m_max&forecast_days=7&timezone=auto');

      final forecastResponse = await http.get(forecastUrl);
      if (forecastResponse.statusCode == 200) {
        final forecastData = jsonDecode(forecastResponse.body);
        final daily = forecastData['daily'] as Map<String, dynamic>;
        final times = (daily['time'] as List).length;
        final count = times.clamp(0, 7);
        for (var i = 0; i < count; i++) {
          forecast.add(ForecastDay.fromOpenMeteo(i, daily));
        }
      }
    }

    return WeatherResult(
      cityName: name,
      country: country,
      temp: temp,
      wind: wind,
      description: description,
      iconCode: icon,
      forecast: forecast,
    );
  }
}
