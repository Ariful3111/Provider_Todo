// lib/features/profile/data/repositories/user_repository_impl.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:provider_todo/core/errors/failures.dart';
import 'package:provider_todo/core/errors/server_exception.dart';
import 'package:provider_todo/features/profile/data/data_sources/user_remote_data_source.dart';
import 'package:provider_todo/features/profile/domain/entities/user_entity.dart';
import 'package:provider_todo/features/profile/domain/entities/user_stats_entity.dart';
import 'package:provider_todo/features/profile/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  const UserRepositoryImpl({required this.remoteDataSource});

  @override
  Either<Failure, UserEntity> getUser() {
    try {
      return Right(remoteDataSource.getUser());
    } on ServerException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserStatsEntity>> getUserStats() async {
    try {
      return Right(await remoteDataSource.getUserStats());
    } on ServerException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar(File image) async {
    try {
      return Right(await remoteDataSource.uploadAvatar(image));
    } on ServerException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateUserName(String name) async {
    try {
      return Right(await remoteDataSource.updateUserName(name));
    } on ServerException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updatePassword(String newPassword) async {
    try {
      await remoteDataSource.updatePassword(newPassword);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}