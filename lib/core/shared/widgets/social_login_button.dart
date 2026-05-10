// lib/core/shared/widgets/social_login_button.dart
import 'package:flutter/material.dart';
import 'package:provider_todo/core/constant/app_colors.dart';
import 'package:provider_todo/core/shared/widgets/app_text.dart';

class SocialLoginButton extends StatelessWidget {
  final String label;
  final String iconAsset;
  final IconData? icon;
  final Color iconColor;
  final VoidCallback? onPressed;
  final bool isLoading; // ✅ per-button loading state

  const SocialLoginButton({
    super.key,
    required this.label,
    required this.iconColor,
    required this.onPressed,
    this.iconAsset = '',
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isDisabled = onPressed == null && !isLoading;

    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor:
              isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          disabledBackgroundColor: isDark
              ? AppColors.surfaceDark.withValues(alpha: 0.5)
              : AppColors.surfaceLight.withValues(alpha: 0.5),
          side: BorderSide(
            color: isDisabled
                ? (isDark ? AppColors.borderDark : AppColors.borderLight)
                    .withValues(alpha: 0.4)
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ Show spinner only for the tapped button
            if (isLoading)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: iconColor,
                ),
              )
            else
              Icon(
                icon ?? Icons.login,
                color: isDisabled
                    ? iconColor.withValues(alpha: 0.4)
                    : iconColor,
                size: 20,
              ),
            const SizedBox(width: 10),
            AppText(
              label,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDisabled
                  ? (isDark
                      ? AppColors.textPrimaryDark.withValues(alpha: 0.4)
                      : AppColors.textPrimary.withValues(alpha: 0.4))
                  : (isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}