// lib/features/profile/domain/usecases/get_user_stats_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:provider_todo/core/errors/failures.dart';
import 'package:provider_todo/features/profile/domain/entities/user_stats_entity.dart';
import 'package:provider_todo/features/profile/domain/repositories/user_repository.dart';

class GetUserStatsUseCase {
  final UserRepository repository;
  const GetUserStatsUseCase(this.repository);

  Future<Either<Failure, UserStatsEntity>> call() => repository.getUserStats();
}
