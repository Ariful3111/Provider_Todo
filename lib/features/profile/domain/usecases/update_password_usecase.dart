import 'package:dartz/dartz.dart';
import 'package:provider_todo/core/errors/failures.dart';
import 'package:provider_todo/features/profile/domain/repositories/user_repository.dart';

class UpdatePasswordUseCase {
  final UserRepository repository;
  const UpdatePasswordUseCase(this.repository);
  Future<Either<Failure, void>> call(String newPassword) =>
      repository.updatePassword(newPassword);
}
