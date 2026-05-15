import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:provider_todo/core/constant/app_colors.dart';
import 'package:provider_todo/core/routes/app_routes.dart';
import 'package:provider_todo/core/shared/widgets/app_primary_button.dart';
import 'package:provider_todo/core/shared/widgets/app_scaffold.dart';
import 'package:provider_todo/core/shared/widgets/app_text.dart';
import 'package:provider_todo/features/auth/presentation/provider/parts/signin_provider.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 200.h,
              width: 200.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 4.r, color: AppColors.primaryColor),
                
              ),
            ),

            SizedBox(height: 20.h,),
            AppText(),
            SizedBox(height: 40.h,),

            Consumer<SignInProvider>(
              builder: (context, auth, _) {
                return AppPrimaryButton(
                  label: 'Logout',
                  isLoading: auth.isEmailLoading,
                  backgroundColor: AppColors.error,
                  onPressed: auth.isEmailLoading
                      ? null
                      : () async {
                          await auth.signOut(context: context);
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
      ),
    );
  }
}
