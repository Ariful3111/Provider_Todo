// lib/features/profile/data/datasources/user_remote_datasource.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider_todo/core/errors/server_exception.dart';
import 'package:provider_todo/features/profile/data/models/user_model.dart';
import 'package:provider_todo/features/profile/domain/entities/user_stats_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class UserRemoteDataSource {
  UserModel              getUser();
  Future<UserStatsEntity> getUserStats();
  Future<String>          uploadAvatar(File image);
  Future<UserModel>       updateUserName(String name);
  Future<void>            updatePassword(String newPassword);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final SupabaseClient client;
  const UserRemoteDataSourceImpl(this.client);

  String get _userId {
    final user = client.auth.currentUser;
    if (user == null) throw const ServerException('Not authenticated');
    return user.id;
  }

  // ── Get user from session ──────────────────────────────
  @override
  UserModel getUser() {
    final user = client.auth.currentUser;
    if (user == null) throw const ServerException('Not authenticated');
    return UserModel.fromSupabaseUser(user);
  }

  // ── Get todo stats ─────────────────────────────────────
  @override
  Future<UserStatsEntity> getUserStats() async {
    try {
      final response = await client
          .from('todos')
          .select('is_completed')
          .eq('user_id', _userId);
      final list      = response as List;
      final completed = list.where((t) => t['is_completed'] == true).length;
      return UserStatsEntity(
        total:     list.length,
        active:    list.length - completed,
        completed: completed,
      );
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  // ── Upload avatar to Supabase Storage ──────────────────
  // Setup: Supabase → Storage → New bucket → name: "avatars" → public: true
  @override
  Future<String> uploadAvatar(File image) async {
    try {
      final ext      = image.path.split('.').last.toLowerCase();
      final filePath = '$_userId/avatar.$ext';
      final bytes    = await image.readAsBytes();

      await client.storage.from('avatars').uploadBinary(
        filePath,
        bytes,
        fileOptions: FileOptions(
          upsert:      true,
          contentType: 'image/$ext',
        ),
      );

      final publicUrl = client.storage
          .from('avatars')
          .getPublicUrl(filePath);

      // Cache-bust so UI refreshes the image
      final urlWithBust =
          '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';

      // Save URL to user metadata
      await client.auth.updateUser(
        UserAttributes(data: {'avatar_url': urlWithBust}),
      );

      debugPrint('✅ Avatar uploaded: $urlWithBust');
      return urlWithBust;
    } on StorageException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ── Update display name ────────────────────────────────
  @override
  Future<UserModel> updateUserName(String name) async {
    try {
      await client.auth.updateUser(
        UserAttributes(data: {'full_name': name.trim()}),
      );
      final updated = client.auth.currentUser!;
      debugPrint('✅ Name updated: $name');
      return UserModel.fromSupabaseUser(updated);
    } on AuthException catch (e) {
      throw ServerException(e.message);
    }
  }

  // ── Update password ────────────────────────────────────
  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      await client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      debugPrint('✅ Password updated');
    } on AuthException catch (e) {
      throw ServerException(e.message);
    }
  }
}