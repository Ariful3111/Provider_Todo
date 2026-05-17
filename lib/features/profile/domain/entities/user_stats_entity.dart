// lib/features/profile/domain/entities/user_stats_entity.dart

class UserStatsEntity {
  final int total;
  final int active;
  final int completed;

  const UserStatsEntity({
    required this.total,
    required this.active,
    required this.completed,
  });

  const UserStatsEntity.empty()
      : total     = 0,
        active    = 0,
        completed = 0;
}