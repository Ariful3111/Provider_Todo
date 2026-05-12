// lib/core/errors/exceptions.dart

// Thrown by data sources, caught and mapped to Failures by repositories

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException(this.message, {this.statusCode});
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache error']);
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException([this.message = 'Item not found']);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'No internet connection']);
}