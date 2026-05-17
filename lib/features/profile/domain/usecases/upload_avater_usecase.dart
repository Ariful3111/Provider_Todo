import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:provider_todo/core/errors/failures.dart';
import 'package:provider_todo/features/profile/domain/repositories/user_repository.dart';

class UploadAvatarUseCase {
  final UserRepository repository;
  const UploadAvatarUseCase(this.repository);
  Future<Either<Failure, String>> call(File image) =>
      repository.uploadAvatar(image);
}
