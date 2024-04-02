import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/common/urls.dart';
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
  final successJsonData = readJson('test/utils/weather_response.json');
  final cityNotFoundJsonData =
      readJson('test/utils/city_not_found_response.json');
  final apiKeyResponseJsonData = readJson('test/utils/api_key_response.json');
  final errorResponseJsonData = readJson('test/utils/error_response.json');

  setUp(() {
    mockHttpClient = MockHttpClient();
    sut = WeatherRemoteDataSource(client: mockHttpClient);
  });

  test('should return a valid model when the HTTP response is 200', () async {
    when(() => mockHttpClient
            .get(Uri.parse(Urls.currentWeatherByCity(testCityName))))
        .thenAnswer((_) async => http.Response(successJsonData, 200));

    final result = await sut.getCurrentWeather(testCityName);

    expect(result, isA<WeatherModel>());
  });

  test(
      'should throw a CityNotFoundException when the HTTP response is 404 and the message field of the response body is "city not found"',
      () {
    when(() => mockHttpClient
            .get(Uri.parse(Urls.currentWeatherByCity(testNonCityName))))
        .thenAnswer((_) async => http.Response(cityNotFoundJsonData, 404));

    // NOTE this test fails if we await getCurrentWeather
    final result = sut.getCurrentWeather(testNonCityName);

    expect(result, throwsA(isA<CityNotFoundException>()));
  });

  test(
      'should throw a ApiKeyException when the HTTP response is 401 and the message field of the response body starts with "Invalid API key."',
      () {
    when(() => mockHttpClient
            .get(Uri.parse(Urls.currentWeatherByCity(testCityName))))
        .thenAnswer((_) async => http.Response(apiKeyResponseJsonData, 401));

    // NOTE this test fails if we await getCurrentWeather
    final result = sut.getCurrentWeather(testCityName);

    expect(result, throwsA(isA<ApiKeyException>()));
  });

  test('should throw a ServerException when the HTTP response is 404', () {
    when(() => mockHttpClient
            .get(Uri.parse(Urls.currentWeatherByCity(testCityName))))
        .thenAnswer((_) async => http.Response(errorResponseJsonData, 404));

    // NOTE this test fails if we await getCurrentWeather
    final result = sut.getCurrentWeather(testCityName);

    expect(result, throwsA(isA<ServerException>()));
  });
}
