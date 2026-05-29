import 'package:flutter/material.dart';
import '../models/forecast_day.dart';

class ForecastList extends StatelessWidget {
  const ForecastList({super.key, required this.days});

  final List<ForecastDay> days;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: days.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final day = days[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
            child: Text(
              _emojiForCode(day.weatherCode),
              style: const TextStyle(fontSize: 20),
            ),
          ),
          title: Text(_formatDate(day.date)),
          subtitle: Text(day.description),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${day.maxTemp.toStringAsFixed(1)}°C', style: theme.textTheme.titleMedium),
              Text('min ${day.minTemp.toStringAsFixed(1)}°C', style: theme.textTheme.bodyMedium),
              Text('${day.windSpeed.toStringAsFixed(1)} m/s', style: theme.textTheme.bodyMedium),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime d) {
    const weekdays = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${weekdays[d.weekday-1]} ${d.day} ${months[d.month-1]}';
  }

  

  String _emojiForCode(int code) {
    if (code == 0) return '☀️';
    if (code <= 3) return '⛅️';
    if (code == 45 || code == 48) return '🌫️';
    if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82)) return '🌧️';
    if ((code >= 71 && code <= 86)) return '❄️';
    if (code >= 95) return '⛈️';
    return '🌈';
  }
}
