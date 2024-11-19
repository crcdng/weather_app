import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'data/remote_datasource.dart';
import 'data/weather_repository_impl.dart';
import 'domain/get_weather_usecase.dart';
import 'ui/weather_notifier.dart';
import 'ui/weather_notifier_provider.dart';
import 'ui/weather_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: WeatherNotifierProvider(
              weatherNotifier: WeatherNotifier(
                usecase: GetWeatherUsecase(
                  repository: WeatherRepositoryImpl(
                    remoteDataSource:
                        WeatherRemoteDataSource(client: http.Client()),
                  ),
                ),
              ),
              child: const WeatherScreen()),
        ),
      ),
    );
  }
}
