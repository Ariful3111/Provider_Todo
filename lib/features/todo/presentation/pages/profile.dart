import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:provider_todo/core/constant/app_colors.dart';
import 'package:provider_todo/core/routes/app_routes.dart';
import 'package:provider_todo/core/shared/widgets/app_primary_button.dart';
import 'package:provider_todo/core/shared/widgets/app_scaffold.dart';
import 'package:provider_todo/features/auth/presentation/provider/parts/signin_provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Column(
        children: [
          Consumer<SignInProvider>(
            builder: (context, auth, _) {
              return AppPrimaryButton(
                label: 'Logout',
                isLoading: auth.isEmailLoading,
                backgroundColor: AppColors.error,
                onPressed: auth.isEmailLoading
                    ? null
                    : () async {
                        await auth.signOut();
                        // GoRouter redirect handles navigation to sign in
                        // automatically via onAuthStateChange → signedOut event
                        if (context.mounted) {
                          context.go(AppRoutes.signIn);
                        }
                      },
              );
            },
          ),
        ],
      ),
    );
  }
}
