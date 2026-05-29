import 'package:flutter/material.dart';
import 'info_pill.dart';

class CurrentWeatherCard extends StatelessWidget {
  const CurrentWeatherCard({
    super.key,
    required this.cityName,
    this.country,
    this.temp,
    this.wind,
    this.description,
    this.iconCode,
  });

  final String cityName;
  final String? country;
  final double? temp;
  final double? wind;
  final String? description;
  final String? iconCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (iconCode != null)
                  Image.network('https://openweathermap.org/img/wn/$iconCode@2x.png', width: 72, height: 72),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$cityName${country != null ? ', $country' : ''}', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 6),
                      Text('${temp?.toStringAsFixed(1) ?? '--'}°C', style: theme.textTheme.headlineSmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                InfoPill(icon: Icons.thermostat, label: '${temp?.toStringAsFixed(1) ?? '--'}°C'),
                InfoPill(icon: Icons.air, label: '${wind?.toStringAsFixed(1) ?? '--'} m/s'),
                InfoPill(icon: Icons.wb_cloudy, label: description ?? '--'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
