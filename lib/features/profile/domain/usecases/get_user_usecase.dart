// lib/features/profile/domain/usecases/get_user_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:provider_todo/core/errors/failures.dart';
import 'package:provider_todo/features/profile/domain/entities/user_entity.dart';
import 'package:provider_todo/features/profile/domain/repositories/user_repository.dart';

class GetUserUseCase {
  final UserRepository repository;
  const GetUserUseCase(this.repository);

  Either<Failure, UserEntity> call() => repository.getUser();
}
