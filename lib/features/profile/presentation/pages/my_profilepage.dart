// lib/features/profile/presentation/pages/my_profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:provider_todo/core/constant/app_colors.dart';
import 'package:provider_todo/core/shared/widgets/app_primary_button.dart';
import 'package:provider_todo/core/shared/widgets/app_scaffold.dart';
import 'package:provider_todo/core/shared/widgets/app_text.dart';
import 'package:provider_todo/core/shared/widgets/app_text_field.dart';
import 'package:provider_todo/features/profile/domain/entities/user_entity.dart';
import 'package:provider_todo/features/profile/presentation/provider/profile_provider.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  // ── Name edit ────────────────────────────────────────────
  bool _editingName = false;
  late final TextEditingController _nameController;

  // ── Password section ─────────────────────────────────────
  bool _showPasswordSection = false;
  final _passwordFormKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    final user = context.read<ProfileProvider>().user;
    _nameController = TextEditingController(text: user?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveName(ProfileProvider profile) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final success = await profile.updateUserName(name);
    if (mounted) {
      _showSnackbar(
        success
            ? profile.successMessage ?? 'Name updated'
            : profile.errorMessage ?? 'Failed to update name',
        isError: !success,
      );
      if (success) setState(() => _editingName = false);
    }
  }

  Future<void> _savePassword(ProfileProvider profile) async {
    if (!_passwordFormKey.currentState!.validate()) return;
    final success = await profile.updatePassword(
      _newPasswordController.text.trim(),
    );
    if (mounted) {
      _showSnackbar(
        success
            ? profile.successMessage ?? 'Password updated'
            : profile.errorMessage ?? 'Failed to update password',
        isError: !success,
      );
      if (success) {
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        setState(() => _showPasswordSection = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppScaffold(
      appbar: AppBar(
        title: AppText(
          'My Profile',
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: Consumer<ProfileProvider>(
        builder: (context, profile, _) {
          final UserEntity? user = profile.user;
          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Section: Account Info ─────────────────
                _SectionHeader(label: 'Account Info', isDark: isDark),
                SizedBox(height: 12.h),

                _InfoCard(
                  isDark: isDark,
                  children: [
                    // Name row
                    _editingName
                        ? _EditableNameRow(
                            controller: _nameController,
                            isDark: isDark,
                            isLoading: profile.isUpdatingName,
                            onSave: () => _saveName(profile),
                            onCancel: () {
                              setState(() => _editingName = false);
                              _nameController.text = user.name;
                            },
                          )
                        : _ReadonlyRow(
                            icon: Icons.person_outline_rounded,
                            label: 'Full Name',
                            value: user.name,
                            isDark: isDark,
                            trailingIcon: Icons.edit_outlined,
                            onTrailingTap: () =>
                                setState(() => _editingName = true),
                          ),

                    _Divider(isDark: isDark),

                    // Email row (read-only — Supabase requires re-verification)
                    _ReadonlyRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: user.email,
                      isDark: isDark,
                      trailingIcon: Icons.copy_outlined,
                      onTrailingTap: () {
                        Clipboard.setData(ClipboardData(text: user.email));
                        _showSnackbar('Email copied');
                      },
                    ),

                    if (user.phone != null && user.phone!.isNotEmpty) ...[
                      _Divider(isDark: isDark),
                      _ReadonlyRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: user.phone!,
                        isDark: isDark,
                      ),
                    ],

                    _Divider(isDark: isDark),

                    // Provider
                    _ReadonlyRow(
                      icon: Icons.login_rounded,
                      label: 'Sign-in Method',
                      value:
                          user.provider[0].toUpperCase() +
                          user.provider.substring(1),
                      isDark: isDark,
                    ),

                    _Divider(isDark: isDark),

                    // User ID
                    _ReadonlyRow(
                      icon: Icons.badge_outlined,
                      label: 'User ID',
                      value: '${user.id.substring(0, 8)}...',
                      isDark: isDark,
                      trailingIcon: Icons.copy_outlined,
                      onTrailingTap: () {
                        Clipboard.setData(ClipboardData(text: user.id));
                        _showSnackbar('User ID copied');
                      },
                    ),
                  ],
                ),

                SizedBox(height: 28.h),

                // ── Section: Password ─────────────────────
                // Only show for email provider
                if (user.provider == 'email') ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SectionHeader(label: 'Password', isDark: isDark),
                      GestureDetector(
                        onTap: () => setState(
                          () => _showPasswordSection = !_showPasswordSection,
                        ),
                        child: AppText(
                          _showPasswordSection ? 'Cancel' : 'Change',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // Password display (dots)
                  if (!_showPasswordSection)
                    _InfoCard(
                      isDark: isDark,
                      children: [
                        _ReadonlyRow(
                          icon: Icons.lock_outline,
                          label: 'Password',
                          value: '••••••••',
                          isDark: isDark,
                        ),
                      ],
                    )
                  else
                    // Password edit form
                    Form(
                      key: _passwordFormKey,
                      child: _InfoCard(
                        isDark: isDark,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16.r),
                            child: Column(
                              children: [
                                AppTextField(
                                  controller: _newPasswordController,
                                  label: 'New Password',
                                  hint: 'Min. 8 characters',
                                  obscureText: _obscureNew,
                                  validator: (v) {
                                    if (v == null || v.trim().length < 8) {
                                      return 'At least 8 characters';
                                    }
                                    return null;
                                  },
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureNew
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary,
                                    ),
                                    onPressed: () => setState(
                                      () => _obscureNew = !_obscureNew,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                AppTextField(
                                  controller: _confirmPasswordController,
                                  label: 'Confirm Password',
                                  hint: '••••••••',
                                  obscureText: _obscureConfirm,
                                  validator: (v) {
                                    if (v != _newPasswordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirm
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary,
                                    ),
                                    onPressed: () => setState(
                                      () => _obscureConfirm = !_obscureConfirm,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                AppPrimaryButton(
                                  label: 'Update Password',
                                  isLoading: profile.isUpdatingPassword,
                                  onPressed: profile.isUpdatingPassword
                                      ? null
                                      : () => _savePassword(profile),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],

                SizedBox(height: 32.h),
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

// ── Widgets ──────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionHeader({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AppText(
      label,
      fontSize: 13.sp,
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
    );
  }
}

class _InfoCard extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;
  const _InfoCard({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 52.w,
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
    );
  }
}

class _ReadonlyRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingTap;
  const _ReadonlyRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.trailingIcon,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: AppColors.primaryColor),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                label,
                fontSize: 11.sp,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
              SizedBox(height: 2.h),
              AppText(
                value,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ],
          ),
          const Spacer(),
          if (trailingIcon != null)
            GestureDetector(
              onTap: onTrailingTap,
              child: Icon(
                trailingIcon,
                size: 18.sp,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

class _EditableNameRow extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final bool isLoading;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  const _EditableNameRow({
    required this.controller,
    required this.isDark,
    required this.isLoading,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12.r),
      child: Row(
        children: [
          Icon(
            Icons.person_outline_rounded,
            size: 18.sp,
            color: AppColors.primaryColor,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: true,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 8.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: AppColors.primaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                    color: AppColors.primaryColor,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // Save
          GestureDetector(
            onTap: isLoading ? null : onSave,
            child: Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 16.r,
                      height: 16.r,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(Icons.check_rounded, size: 16.sp, color: Colors.white),
            ),
          ),
          SizedBox(width: 6.w),
          // Cancel
          GestureDetector(
            onTap: onCancel,
            child: Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.close_rounded,
                size: 16.sp,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
