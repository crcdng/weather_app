abstract class Failure {
  final String message;
  const Failure(this.message);
}

class CityNotFoundFailure extends Failure {
  const CityNotFoundFailure() : super('City not found.');
}

class ApiKeyFailure extends Failure {
  const ApiKeyFailure()
      : super(
            'Missing or incorrect API key. Check your API key and try again.');
}

class ServerFailure extends Failure {
  const ServerFailure() : super('A Server error occurred. Try again later.');
}

class ConnectionFailure extends Failure {
  const ConnectionFailure()
      : super('No conection to the server. Check your internet connection.');
}

class CityNotFoundException implements Exception {}

class ApiKeyException implements Exception {}

class ServerException implements Exception {}
