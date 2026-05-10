// lib/core/shared/widgets/app_scaffold.dart
import 'package:flutter/material.dart';
import 'package:provider_todo/core/constant/app_colors.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appbar;
  final Widget? drawer;
  final Widget? bottomNav;
  final Widget? floatingActionButton;
  final Color? backgroundColor;

  const AppScaffold({
    super.key,
    required this.child,
    this.appbar,
    this.drawer,
    this.bottomNav,
    this.floatingActionButton,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: appbar,
      drawer: drawer,
      backgroundColor: backgroundColor ??
          (isDark ? AppColors.backgroundDark : AppColors.backgroundLight),
      bottomNavigationBar: bottomNav,
      floatingActionButton: floatingActionButton,
      body: SafeArea(child: child),
    );
  }
}