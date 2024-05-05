import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/common/errors.dart';
// import '../common/errors.dart';
import 'weather_notifier.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Timer? _debounce;

  void _onTextFieldChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      Provider.of<WeatherNotifier>(context, listen: false)
          .getCurrentWeather(query);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff1D1E22),
        title: const Text(
          'Weather App',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'Enter city name',
                fillColor: const Color(0xffF3F3F3),
                filled: true,
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10)),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10)),
              ),
              // debouncing the API calls
              onChanged: _onTextFieldChanged,
            ),
            const SizedBox(height: 32.0),
            Consumer<WeatherNotifier>(
              builder: (context, notifier, child) {
                if (notifier.failure is CityNotFoundFailure) {
                  return Container();
                } else if (notifier.failure is ApiKeyFailure ||
                    notifier.failure is ServerFailure ||
                    notifier.failure is ConnectionFailure) {
                  return Center(
                    key: const Key('error_message'),
                    child: Text(notifier.failure!.message),
                  );
                }
                if (notifier.weatherEntity == null) {
                  return Container();
                }
                // return Container();
                // TODO handle slow loading
                // if (state is WeatherLoading) {
                //   return const Center(
                //     child: CircularProgressIndicator(),
                //   );
                // }
                // if (state is WeatherLoaded) {
                return Column(
                  key: const Key('weather_data'),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          notifier.weatherEntity!.city,
                          style: const TextStyle(
                            fontSize: 22.0,
                          ),
                        ),
                        // TODO implement later
                        // here the ui directly accesses the API ??
                        // Image(
                        //   image: NetworkImage(
                        //     Urls.weatherIcon(
                        //       state.result.iconCode,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      '${notifier.weatherEntity!.main} | ${notifier.weatherEntity!.description}',
                      style: const TextStyle(
                        fontSize: 16.0,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    Table(
                      defaultColumnWidth: const FixedColumnWidth(170.0),
                      border: TableBorder.all(
                        color: Colors.grey,
                        style: BorderStyle.solid,
                        width: 1,
                      ),
                      children: [
                        TableRow(children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Temperature ℃', // ℃ looks ok in the output
                              style: TextStyle(
                                fontSize: 16.0,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              notifier.weatherEntity!.temperature.toString(),
                              style: const TextStyle(
                                fontSize: 16.0,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ]),
                        TableRow(children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Pressure',
                              style: TextStyle(
                                fontSize: 16.0,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              notifier.weatherEntity!.pressure.toString(),
                              style: const TextStyle(
                                  fontSize: 16.0,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ]),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Humidity',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                notifier.weatherEntity!.humidity.toString(),
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
