import 'package:flutter/material.dart';
import 'src/models/forecast_day.dart';
import 'src/services/weather_service.dart';
import 'src/widgets/current_weather_card.dart';
import 'src/widgets/forecast_list.dart';

void main() {
  runApp(const MyApp());
}

// Models, services and widgets are in `lib/src/`

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Greener, pimped palette
    const seedColor = Color(0xFF2ECC71); // lively green
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFF0B9E4A),
      secondary: const Color(0xFF2ECC71),
      tertiary: const Color(0xFF7AF7B0),
      surface: const Color(0xFFFFFFFF),
      surfaceContainerHighest: const Color(0xFFF2FFFA),
      onSurface: const Color(0xFF04251A),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      outlineVariant: const Color(0xFFBFEFDC),
    );

    return MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: colorScheme.onSurface,
          elevation: 0,
        ),
        textTheme: TextTheme(
          headlineSmall: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: colorScheme.onSurface,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
        ),
        scaffoldBackgroundColor: colorScheme.surface,
      ),
      home: const MyHomePage(title: 'Weather App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _cityController = TextEditingController();
  String _weatherText = '';
  bool _loading = false;
  List<ForecastDay> _forecastDays = [];
  final WeatherService _service = WeatherService('055e78f2005f9e43d2031b711a8973d8');

  // Detailed weather data
  String? _cityName;
  String? _country;
  double? _tempC;
  double? _windSpeed;
  String? _description;
  String? _iconCode;

  Future<void> fetchWeather(String city) async {
    setState(() {
      _loading = true;
      _weatherText = 'Loading...';
      _cityName = null;
      _country = null;
      _tempC = null;
      _windSpeed = null;
      _description = null;
      _iconCode = null;
      _forecastDays = [];
    });

    try {
      final result = await _service.fetchWeather(city);
      setState(() {
        _cityName = result.cityName;
        _country = result.country;
        _tempC = result.temp;
        _windSpeed = result.wind;
        _description = result.description;
        _iconCode = result.iconCode;
        _forecastDays = result.forecast;
        _weatherText = '';
      });
    } catch (e) {
      setState(() {
        _weatherText = 'Failed to fetch weather: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Header: show large weather image when available, otherwise a styled placeholder
              if (_iconCode != null)
                Center(
                  child: Image.network(
                    'https://openweathermap.org/img/wn/$_iconCode@4x.png',
                    width: 128,
                    height: 128,
                    fit: BoxFit.contain,
                  ),
                )
              else
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                    child: Icon(Icons.cloud, size: 48, color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                child: TextField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    hintText: 'Enter a city',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: ElevatedButton(
                  onPressed: _loading
                      ? null
                      : () {
                          final city = _cityController.text.trim();
                          if (city.isEmpty) {
                            setState(() {
                              _weatherText = 'Please enter a city name.';
                            });
                            return;
                          }
                          fetchWeather(city);
                        },
                  child: const Text('Search'),
                ),
              ),
              const SizedBox(height: 24),
              // Result area: loading, detailed card, or message
              _loading ? const Center(child: CircularProgressIndicator()) : SizedBox.shrink(),
              if (!_loading && _cityName != null)
                Column(
                  children: [
                    CurrentWeatherCard(
                      cityName: _cityName!,
                      country: _country,
                      temp: _tempC,
                      wind: _windSpeed,
                      description: _description,
                      iconCode: _iconCode,
                    ),
                    const SizedBox(height: 20),
                    if (_forecastDays.isNotEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '7 prochains jours',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    if (_forecastDays.isNotEmpty) const SizedBox(height: 12),
                    if (_forecastDays.isNotEmpty) ForecastList(days: _forecastDays),
                  ],
                ),
              if (_weatherText.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _weatherText,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              if (!_loading && _cityName == null)
                Text(
                  _weatherText,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
            ],
          ),
        ),
      ),
    );
  }
}