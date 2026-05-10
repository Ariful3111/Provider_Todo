// Thrown by data sources, caught and mapped to Failures by repositories

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache error']);
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException([this.message = 'Item not found']);
}