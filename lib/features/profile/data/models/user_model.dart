// lib/features/profile/data/models/user_model.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider_todo/features/profile/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.provider,
    super.avatarUrl,
    super.phone,
  });

  // ✅ Map from Supabase User object
  factory UserModel.fromSupabaseUser(User user) {
    final meta     = user.userMetadata ?? {};
    final appMeta  = user.appMetadata;

    // Name: full_name (email signup) → name (OAuth) → email prefix
    final String name =
        _str(meta['full_name'])?.trim().isNotEmpty == true
            ? _str(meta['full_name'])!
            : _str(meta['name'])?.trim().isNotEmpty == true
                ? _str(meta['name'])!
                : (user.email?.split('@').first ?? 'User');

    // Avatar: avatar_url (GitHub) or picture (Google)
    final String? avatar =
        _str(meta['avatar_url']) ?? _str(meta['picture']);

    return UserModel(
      id:        user.id,
      name:      name,
      email:     user.email    ?? '',
      phone:     user.phone,
      provider:  _str(appMeta['provider']) ?? 'email',
      avatarUrl: avatar,
    );
  }

  static String? _str(dynamic v) =>
      v is String && v.isNotEmpty ? v : null;
}