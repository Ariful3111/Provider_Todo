// lib/features/profile/presentation/pages/profile_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:provider_todo/core/constant/app_colors.dart';
import 'package:provider_todo/core/routes/app_routes.dart';
import 'package:provider_todo/core/shared/widgets/app_primary_button.dart';
import 'package:provider_todo/core/shared/widgets/app_scaffold.dart';
import 'package:provider_todo/core/shared/widgets/app_text.dart';
import 'package:provider_todo/features/auth/presentation/provider/parts/signin_provider.dart';
import 'package:provider_todo/features/profile/domain/entities/user_entity.dart';
import 'package:provider_todo/features/profile/domain/entities/user_stats_entity.dart';
import 'package:provider_todo/features/profile/presentation/provider/profile_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile();
    });
  }

  // ── Pick image from gallery or camera ──────────────────
  Future<void> _pickAndUpload(ProfileProvider provider) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => _ImageSourceSheet(),
    );
    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (picked == null) return;

    await provider.uploadAvatar(File(picked.path));

    if (mounted && provider.errorMessage != null) {
      _showSnackbar(provider.errorMessage!, isError: true);
    } else if (mounted && provider.successMessage != null) {
      _showSnackbar(provider.successMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppScaffold(
      child: Consumer<ProfileProvider>(
        builder: (context, profile, _) {
          if (profile.isLoading && profile.user == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }

          final UserEntity? user = profile.user;
          if (user == null) return const SizedBox.shrink();

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              children: [
                // ── Avatar with upload button ─────────────
                _AvatarWithUpload(
                  user: user,
                  isUploading: profile.isUploadingAvatar,
                  onTap: () => _pickAndUpload(profile),
                ),
                SizedBox(height: 14.h),

                // ── Name ────────────────────────────────────
                AppText(
                  user.name,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
                SizedBox(height: 4.h),

                // ── Email ────────────────────────────────────
                AppText(
                  user.email,
                  fontSize: 13.sp,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
                SizedBox(height: 8.h),

                // ── Provider badge ───────────────────────────
                _ProviderBadge(provider: user.provider),
                SizedBox(height: 24.h),

                // ── Stats ────────────────────────────────────
                _StatsRow(stats: profile.stats),
                SizedBox(height: 24.h),

                // ── Menu items ───────────────────────────────
                _MenuCard(
                  isDark: isDark,
                  items: [
                    _MenuItem(
                      icon: Icons.person_outline_rounded,
                      label: 'My Profile',
                      color: AppColors.primaryColor,
                      onTap: () => context.push(AppRoutes.myProfile),
                    ),
                    _MenuItem(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      color: const Color(0xFF6366F1),
                      onTap: () => context.push(AppRoutes.settings),
                    ),
                    _MenuItem(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
                      color: const Color(0xFFF59E0B),
                      onTap: () => context.push(AppRoutes.notification),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),

                // ── Logout ───────────────────────────────────
                Consumer<SignInProvider>(
                  builder: (context, auth, _) => AppPrimaryButton(
                    label: 'Logout',
                    isLoading: auth.isEmailLoading,
                    backgroundColor: AppColors.error,
                    onPressed: auth.isEmailLoading
                        ? null
                        : () async {
                            await auth.signOut(context: context);
                            if (context.mounted) {
                              context.go(AppRoutes.signIn);
                            }
                          },
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSnackbar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: AppText.whiteText(msg),
          backgroundColor: isError ? AppColors.error : AppColors.success,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }
}

// ────────────────────────────────────────────────────────────
// Avatar with upload overlay
// ────────────────────────────────────────────────────────────
class _AvatarWithUpload extends StatelessWidget {
  final UserEntity user;
  final bool isUploading;
  final VoidCallback onTap;
  const _AvatarWithUpload({
    required this.user,
    required this.isUploading,
    required this.onTap,
  });

  String get _initials {
    final p = user.name.trim().split(' ');
    return p.length >= 2
        ? '${p[0][0]}${p[1][0]}'.toUpperCase()
        : user.name.isNotEmpty
        ? user.name[0].toUpperCase()
        : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Avatar circle
        Container(
          width: 96.r,
          height: 96.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(width: 3.r, color: AppColors.primaryColor),
          ),
          child: ClipOval(
            child: isUploading
                ? Container(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : (user.avatarUrl?.isNotEmpty == true
                      ? Image.network(
                          user.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _InitialsFallback(_initials),
                        )
                      : _InitialsFallback(_initials)),
          ),
        ),

        // Camera button
        GestureDetector(
          onTap: isUploading ? null : onTap,
          child: Container(
            width: 28.r,
            height: 28.r,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
              border: Border.all(width: 2, color: Colors.white),
            ),
            child: Icon(
              Icons.camera_alt_rounded,
              size: 14.sp,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _InitialsFallback extends StatelessWidget {
  final String initials;
  const _InitialsFallback(this.initials);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryColor.withValues(alpha: 0.12),
      child: Center(
        child: AppText(
          initials,
          fontSize: 30.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
// Provider badge
// ────────────────────────────────────────────────────────────
class _ProviderBadge extends StatelessWidget {
  final String provider;
  const _ProviderBadge({required this.provider});

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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 13.sp, color: _color),
          SizedBox(width: 4.w),
          AppText(
            provider[0].toUpperCase() + provider.substring(1),
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: _color,
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
// Stats row
// ────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final UserStatsEntity stats;
  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        _Stat(
          label: 'Total',
          value: stats.total,
          color: AppColors.primaryColor,
          isDark: isDark,
        ),
        SizedBox(width: 10.w),
        _Stat(
          label: 'Active',
          value: stats.active,
          color: AppColors.secondaryColor,
          isDark: isDark,
        ),
        SizedBox(width: 10.w),
        _Stat(
          label: 'Completed',
          value: stats.completed,
          color: AppColors.success,
          isDark: isDark,
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final bool isDark;
  const _Stat({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            AppText(
              '$value',
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            SizedBox(height: 2.h),
            AppText(
              label,
              fontSize: 11.sp,
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

// ────────────────────────────────────────────────────────────
// Modern menu card
// ────────────────────────────────────────────────────────────
class _MenuCard extends StatelessWidget {
  final bool isDark;
  final List<_MenuItem> items;
  const _MenuCard({required this.isDark, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16.r),
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
              _MenuItemTile(item: item, isDark: isDark),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 56.w,
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _MenuItemTile extends StatelessWidget {
  final _MenuItem item;
  final bool isDark;
  const _MenuItemTile({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(item.icon, size: 18.sp, color: item.color),
            ),
            SizedBox(width: 14.w),

            // Label
            Expanded(
              child: AppText(
                item.label,
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),

            // Chevron
            Icon(
              Icons.chevron_right_rounded,
              size: 20.sp,
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

// ────────────────────────────────────────────────────────────
// Image source bottom sheet
// ────────────────────────────────────────────────────────────
class _ImageSourceSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              'Change Profile Photo',
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SourceOption(
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                  isDark: isDark,
                ),
                _SourceOption(
                  icon: Icons.camera_alt_outlined,
                  label: 'Camera',
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                  isDark: isDark,
                ),
              ],
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  const _SourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64.r,
            height: 64.r,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Icon(icon, size: 28.sp, color: AppColors.primaryColor),
          ),
          SizedBox(height: 8.h),
          AppText(
            label,
            fontSize: 13.sp,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}
