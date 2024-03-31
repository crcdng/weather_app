import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/common/constants.dart';
import 'package:weather_app/common/errors.dart';
import 'package:weather_app/data/remote_datasource.dart';
import 'package:weather_app/data/weather_model.dart';

import '../utils/read_json.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late WeatherRemoteDataSource sut;
  late MockHttpClient mockHttpClient;
  const testCityName = "Berlin";
  const testNonCityName = "Beeeeerlin";
  final testJsonData = readJson('test/utils/weather_response.json');

  setUp(() {
    mockHttpClient = MockHttpClient();
    sut = WeatherRemoteDataSource(client: mockHttpClient);
  });

  test('should return a valid model when the HTTP response is 200', () async {
    when(() => mockHttpClient
            .get(Uri.parse(Urls.currentWeatherByCity(testCityName))))
        .thenAnswer((_) async => http.Response(testJsonData, 200));

    final result = await sut.getCurrentWeather(testCityName);

    expect(result, isA<WeatherModel>());
  });

  test('should throw an exception when the HTTP response is 404', () {
    when(() => mockHttpClient
            .get(Uri.parse(Urls.currentWeatherByCity(testNonCityName))))
        .thenAnswer((_) async => http.Response('not found', 404));

    // NOTE this test fails if we await getCurrentWeather
    final result = sut.getCurrentWeather(testNonCityName);

    expect(result, throwsA(isA<ServerException>()));
  });
}
