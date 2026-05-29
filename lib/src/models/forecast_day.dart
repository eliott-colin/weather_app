class ForecastDay {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final double windSpeed;
  final String description;
  final int weatherCode;

  ForecastDay({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.windSpeed,
    required this.description,
    required this.weatherCode,
  });

  factory ForecastDay.fromOpenMeteo(int idx, Map<String, dynamic> daily) {
    final times = (daily['time'] as List).cast<String>();
    final maxTemps = (daily['temperature_2m_max'] as List).cast<num>();
    final minTemps = (daily['temperature_2m_min'] as List).cast<num>();
    final windSpeeds = (daily['wind_speed_10m_max'] as List).cast<num>();
    final weatherCodes = (daily['weather_code'] as List).cast<num>();

    return ForecastDay(
      date: DateTime.parse(times[idx]),
      minTemp: minTemps[idx].toDouble(),
      maxTemp: maxTemps[idx].toDouble(),
      windSpeed: windSpeeds[idx].toDouble(),
      description: weatherCodeToLabel(weatherCodes[idx].toInt()),
      weatherCode: weatherCodes[idx].toInt(),
    );
  }

  static String weatherCodeToLabel(int code) {
    // Minimal mapping used for UI
    if (code == 0) return 'Clear';
    if (code <= 3) return 'Clouds';
    if (code <= 67) return 'Precipitation';
    if (code <= 86) return 'Snow/Rain';
    return 'Storm';
  }
}
