import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'data/remote_datasource.dart';
import 'data/weather_repository_impl.dart';
import 'domain/get_weather_usecase.dart';
import 'presentation/weather_notifier.dart';
import 'presentation/weather_notifier_provider.dart';
import 'presentation/weather_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late WeatherNotifier weatherNotifier;

  @override
  void initState() {
    super.initState();
    weatherNotifier = WeatherNotifier(
      usecase: GetWeatherUsecase(
        repository: WeatherRepositoryImpl(
          remoteDataSource: WeatherRemoteDataSource(client: http.Client()),
        ),
      ),
    );
  }

  @override
  void dispose() {
    weatherNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: WeatherNotifierProvider(
              weatherNotifier: weatherNotifier, child: const WeatherScreen()),
        ),
      ),
    );
  }
}
