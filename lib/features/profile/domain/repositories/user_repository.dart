// lib/features/profile/domain/repositories/user_repository.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:provider_todo/core/errors/failures.dart';
import 'package:provider_todo/features/profile/domain/entities/user_entity.dart';
import 'package:provider_todo/features/profile/domain/entities/user_stats_entity.dart';

abstract class UserRepository {
  Either<Failure, UserEntity> getUser();
  Future<Either<Failure, UserStatsEntity>> getUserStats();
  Future<Either<Failure, String>> uploadAvatar(File image);
  Future<Either<Failure, UserEntity>> updateUserName(String name);
  Future<Either<Failure, void>> updatePassword(String newPassword);
}
