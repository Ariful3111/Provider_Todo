// lib/features/profile/domain/entities/user_entity.dart

class UserEntity {
  final String  id;
  final String  name;
  final String  email;
  final String? avatarUrl;
  final String  provider;   // 'email' | 'google' | 'github' | 'facebook'
  final String? phone;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.provider,
    this.avatarUrl,
    this.phone,
  });
}