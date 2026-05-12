// lib/core/errors/failures.dart

abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local data error.']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Todo not found.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}