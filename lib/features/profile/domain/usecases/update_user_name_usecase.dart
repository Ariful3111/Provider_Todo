import 'package:dartz/dartz.dart';
import 'package:provider_todo/core/errors/failures.dart';
import 'package:provider_todo/features/profile/domain/entities/user_entity.dart';
import 'package:provider_todo/features/profile/domain/repositories/user_repository.dart';

class UpdateUserNameUseCase {
  final UserRepository repository;
  const UpdateUserNameUseCase(this.repository);
  Future<Either<Failure, UserEntity>> call(String name) =>
      repository.updateUserName(name);
}
