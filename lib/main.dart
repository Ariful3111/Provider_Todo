// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:provider_todo/core/di/injection_container.dart';
import 'package:provider_todo/core/routes/app_router.dart';
import 'package:provider_todo/core/theme/app_theme.dart';
import 'package:provider_todo/core/theme/theme_provider.dart';
import 'package:provider_todo/features/auth/presentation/provider/auth_provider.dart';
import 'package:provider_todo/features/todo/presentation/provider/todos_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

await initDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sl<TodosProvider>()),
        ChangeNotifierProvider(create: (_) => sl<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(430, 930),
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'Todo App',
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeProvider.themeMode,
              routerConfig: AppRouter.router,
            );
          },
        ),
      ),
    );
  }
}