// lib/features/profile/presentation/provider/profile_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider_todo/features/profile/domain/entities/user_entity.dart';
import 'package:provider_todo/features/profile/domain/entities/user_stats_entity.dart';
import 'package:provider_todo/features/profile/domain/usecases/get_user_stats_usecase.dart';
import 'package:provider_todo/features/profile/domain/usecases/get_user_usecase.dart';
import 'package:provider_todo/features/profile/domain/usecases/update_password_usecase.dart';
import 'package:provider_todo/features/profile/domain/usecases/update_user_name_usecase.dart';
import 'package:provider_todo/features/profile/domain/usecases/upload_avater_usecase.dart';

enum ProfileStatus  { initial, loading, success, error }
enum ProfileAction  { none, uploadingAvatar, updatingName, updatingPassword }

class ProfileProvider extends ChangeNotifier {
  final GetUserUseCase        getUserUseCase;
  final GetUserStatsUseCase   getUserStatsUseCase;
  final UploadAvatarUseCase   uploadAvatarUseCase;
  final UpdateUserNameUseCase updateUserNameUseCase;
  final UpdatePasswordUseCase updatePasswordUseCase;

  ProfileProvider({
    required this.getUserUseCase,
    required this.getUserStatsUseCase,
    required this.uploadAvatarUseCase,
    required this.updateUserNameUseCase,
    required this.updatePasswordUseCase,
  });

  ProfileStatus  _status  = ProfileStatus.initial;
  ProfileAction  _action  = ProfileAction.none;
  UserEntity?    _user;
  UserStatsEntity _stats  = const UserStatsEntity.empty();
  String?        _errorMessage;
  String?        _successMessage;

  ProfileStatus   get status         => _status;
  ProfileAction   get action         => _action;
  UserEntity?     get user           => _user;
  UserStatsEntity get stats          => _stats;
  String?         get errorMessage   => _errorMessage;
  String?         get successMessage => _successMessage;

  bool get isLoading         => _status == ProfileStatus.loading;
  bool get isUploadingAvatar => _action == ProfileAction.uploadingAvatar;
  bool get isUpdatingName    => _action == ProfileAction.updatingName;
  bool get isUpdatingPassword=> _action == ProfileAction.updatingPassword;

  // ── Load profile ────────────────────────────────────────
  Future<void> loadProfile() async {
    _status = ProfileStatus.loading;
    _clearMessages();
    notifyListeners();

    final userResult = getUserUseCase();
    bool userLoaded = false;
    userResult.fold(
      (f) { _status = ProfileStatus.error; _errorMessage = f.message; },
      (u) { _user = u; userLoaded = true; },
    );

    if (!userLoaded) { notifyListeners(); return; }

    final statsResult = await getUserStatsUseCase();
    statsResult.fold(
      (_) => _stats = const UserStatsEntity.empty(),
      (s) => _stats = s,
    );

    _status = ProfileStatus.success;
    notifyListeners();
  }

  // ── Upload avatar ────────────────────────────────────────
  Future<void> uploadAvatar(File image) async {
    _action = ProfileAction.uploadingAvatar;
    _clearMessages();
    notifyListeners();

    final result = await uploadAvatarUseCase(image);
    result.fold(
      (f) => _errorMessage = f.message,
      (url) {
        _successMessage = 'Profile photo updated';
        // Refresh user to get new avatar URL
        getUserUseCase().fold((_) {}, (u) => _user = u);
      },
    );

    _action = ProfileAction.none;
    notifyListeners();
    _autoCleanSuccess();
  }

  // ── Update name ──────────────────────────────────────────
  Future<bool> updateUserName(String name) async {
    _action = ProfileAction.updatingName;
    _clearMessages();
    notifyListeners();

    bool success = false;
    final result = await updateUserNameUseCase(name);
    result.fold(
      (f) => _errorMessage = f.message,
      (u) { _user = u; _successMessage = 'Name updated'; success = true; },
    );

    _action = ProfileAction.none;
    notifyListeners();
    if (success) _autoCleanSuccess();
    return success;
  }

  // ── Update password ──────────────────────────────────────
  Future<bool> updatePassword(String newPassword) async {
    _action = ProfileAction.updatingPassword;
    _clearMessages();
    notifyListeners();

    bool success = false;
    final result = await updatePasswordUseCase(newPassword);
    result.fold(
      (f) => _errorMessage = f.message,
      (_) { _successMessage = 'Password updated'; success = true; },
    );

    _action = ProfileAction.none;
    notifyListeners();
    if (success) _autoCleanSuccess();
    return success;
  }

  void _clearMessages() {
    _errorMessage   = null;
    _successMessage = null;
  }

  void _autoCleanSuccess() {
    Future.delayed(const Duration(seconds: 3), () {
      _successMessage = null;
      notifyListeners();
    });
  }
}