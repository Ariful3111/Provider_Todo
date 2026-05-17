// lib/features/profile/presentation/widgets/profile_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider_todo/core/constant/app_colors.dart';
import 'package:provider_todo/core/shared/widgets/app_text.dart';
import 'package:provider_todo/features/profile/domain/entities/user_entity.dart';
import 'package:provider_todo/features/profile/domain/entities/user_stats_entity.dart';

// ── Avatar ────────────────────────────────────────────────────
class ProfileAvatar extends StatelessWidget {
  final UserEntity user;
  const ProfileAvatar({super.key, required this.user});

  String get _initials {
    final parts = user.name.trim().split(' ');
    return parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : user.name.isNotEmpty
        ? user.name[0].toUpperCase()
        : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.r,
      height: 100.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(width: 3.r, color: AppColors.primaryColor),
      ),
      child: ClipOval(
        child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
            ? Image.network(
                user.avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _AvatarFallback(_initials),
              )
            : _AvatarFallback(_initials),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final String initials;
  const _AvatarFallback(this.initials);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryColor.withValues(alpha: 0.12),
      child: Center(
        child: AppText(
          initials,
          fontSize: 32.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }
}

// ── Provider badge ────────────────────────────────────────────
class ProviderBadge extends StatelessWidget {
  final String provider;
  const ProviderBadge({super.key, required this.provider});

  Color get _color => switch (provider) {
    'google' => AppColors.googleColor,
    'github' => AppColors.githubColor,
    'facebook' => AppColors.facebookColor,
    _ => AppColors.primaryColor,
  };

  IconData get _icon => switch (provider) {
    'google' => Icons.g_mobiledata_rounded,
    'github' => Icons.code_rounded,
    'facebook' => Icons.facebook_rounded,
    _ => Icons.email_outlined,
  };

  String get _label => provider[0].toUpperCase() + provider.substring(1);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 14.sp, color: _color),
          SizedBox(width: 4.w),
          AppText(
            _label,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: _color,
          ),
        ],
      ),
    );
  }
}

// ── Stats row ─────────────────────────────────────────────────
class StatsRow extends StatelessWidget {
  final UserStatsEntity stats;
  const StatsRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          label: 'Total',
          value: stats.total,
          color: AppColors.primaryColor,
        ),
        SizedBox(width: 12.w),
        _StatCard(
          label: 'Active',
          value: stats.active,
          color: AppColors.secondaryColor,
        ),
        SizedBox(width: 12.w),
        _StatCard(
          label: 'Completed',
          value: stats.completed,
          color: AppColors.success,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            AppText(
              '$value',
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            SizedBox(height: 4.h),
            AppText(
              label,
              fontSize: 12.sp,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info card ─────────────────────────────────────────────────
class InfoCard extends StatelessWidget {
  final List<InfoCardItem> items;
  const InfoCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final item = e.value;
          final isLast = e.key == items.length - 1;
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                child: GestureDetector(
                  onTap: item.onTap,
                  child: Row(
                    children: [
                      Icon(
                        item.icon,
                        size: 18.sp,
                        color: AppColors.primaryColor,
                      ),
                      SizedBox(width: 12.w),
                      AppText(
                        item.label,
                        fontSize: 13.sp,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                      const Spacer(),
                      Flexible(
                        child: AppText(
                          item.value,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          textAlign: TextAlign.right,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class InfoCardItem {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  const InfoCardItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });
}
