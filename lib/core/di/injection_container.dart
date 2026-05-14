// lib/core/di/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider_todo/core/constant/static_datas.dart';
import 'package:provider_todo/core/theme/theme_provider.dart';
import 'package:provider_todo/features/auth/presentation/provider/auth_provider.dart';
import 'package:provider_todo/features/auth/presentation/provider/oauth_provider.dart';
import 'package:provider_todo/features/auth/presentation/provider/parts/auth_listener.dart';
import 'package:provider_todo/features/auth/presentation/provider/parts/forgot_password_provider.dart';
import 'package:provider_todo/features/auth/presentation/provider/parts/otp_provider.dart';
import 'package:provider_todo/features/auth/presentation/provider/parts/signin_provider.dart';
import 'package:provider_todo/features/auth/presentation/provider/parts/signup_provider.dart';
import 'package:provider_todo/features/todo/data/datasources/todo_local_datasources.dart';
import 'package:provider_todo/features/todo/data/datasources/todo_remote_datasources.dart';
import 'package:provider_todo/features/todo/data/repositories/todo_repository_impl.dart';
import 'package:provider_todo/features/todo/domain/repositories/todo_repositories.dart';
import 'package:provider_todo/features/todo/domain/usecases/add_todos_usecase.dart';
import 'package:provider_todo/features/todo/domain/usecases/delete_todos_usecase.dart';
import 'package:provider_todo/features/todo/domain/usecases/edit_todos_usecase.dart';
import 'package:provider_todo/features/todo/domain/usecases/get_todos_usecase.dart';
import 'package:provider_todo/features/todo/domain/usecases/toggle_todos_usecase.dart';
import 'package:provider_todo/features/todo/presentation/provider/todos_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider_todo/features/todo/data/model/todo_model.dart';

final sl = GetIt.instance;

// ✅ async — called with await in main.dart
Future<void> initDependencies() async {
  await _initHive();
  await _initSupabase();      // ← Supabase init lives HERE only
  _registerDataSources();
  _registerRepositories();
  _registerUseCases();
  _registerProviders();           // ← separated for clarity
}

// ─── Hive ─────────────────────────────────────────────────────
Future<void> _initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TodoModelAdapter());
  final box = await Hive.openBox<TodoModel>('todos');
  sl.registerSingleton<Box<TodoModel>>(box);
}

// ─── Supabase ─────────────────────────────────────────────────
Future<void> _initSupabase() async {
  await Supabase.initialize(
    url: StaticDatas.superbaseProjectUrl,
    anonKey: StaticDatas.superbaseAnnonKey,
  );
  sl.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );
}

// ─── Data Sources ─────────────────────────────────────────────
void _registerDataSources() {
  sl.registerLazySingleton<TodoLocalDataSource>(
    () => TodoLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<TodoRemoteDataSource>(
    () => TodoRemoteDataSourceImpl(sl()),
  );
}

// ─── Repository ───────────────────────────────────────────────
void _registerRepositories() {
  sl.registerLazySingleton<TodoRepository>(
    () => TodoRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
    ),
  );
}

// ─── Use Cases ────────────────────────────────────────────────
void _registerUseCases() {
  sl.registerLazySingleton(() => GetTodosUseCase(sl()));
  sl.registerLazySingleton(() => AddTodoUseCase(sl()));
  sl.registerLazySingleton(() => EditTodoUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTodoUseCase(sl()));
  sl.registerLazySingleton(() => ToggleTodoUseCase(sl()));
}

// ─── Todo Provider ────────────────────────────────────────────
// lib/core/di/injection_container.dart
// ─── Only change needed — update _registerProviders() ─────

void _registerProviders() {

  // ─── Theme ────────────────────────────────────────────────
  // ✅ Singleton — theme must be same everywhere in app
  sl.registerLazySingleton(() => ThemeProvider());

  // ─── Auth — Base ──────────────────────────────────────────
  // ✅ Singleton — shared state (isPasswordRecovery etc.)
  sl.registerLazySingleton(() => AuthProvider(sl<SupabaseClient>()));

  // ─── Auth Listener ────────────────────────────────────────
  // ✅ Singleton — must only have ONE auth stream listener
  // registerFactory would create multiple stream subscriptions ❌
  sl.registerLazySingleton(() => AuthListener(sl<SupabaseClient>()));

  // ─── Sign In ──────────────────────────────────────────────
  // ✅ Singleton — login state must persist across pages
  sl.registerLazySingleton(() => SignInProvider(sl<SupabaseClient>()));

  // ─── Sign Up ──────────────────────────────────────────────
  // ✅ Singleton — stores _pendingFullName, _pendingPhone
  // registerFactory loses pending data between pages ❌
  sl.registerLazySingleton(() => SignUpProvider(sl<SupabaseClient>()));

  // ─── OTP ──────────────────────────────────────────────────
  // ✅ Singleton — needs to hold email set from signup/forgot page
  // registerFactory means email is always empty when OTP page reads it ❌
  sl.registerLazySingleton(() => OtpProvider(sl<SupabaseClient>()));

  // ─── OAuth ────────────────────────────────────────────────
  // ✅ Singleton — loading state must reflect correctly in UI
  sl.registerLazySingleton(
      () => OAuthSignInProvider(sl<SupabaseClient>()));

  // ─── Forgot Password ──────────────────────────────────────
  // ✅ Singleton — stores email across forgot → otp → new password flow
  sl.registerLazySingleton(
      () => ForgotPasswordProvider(sl<SupabaseClient>()));

  // ─── Todo ─────────────────────────────────────────────────
  // ✅ Singleton — todo list state must be same across all screens
  sl.registerLazySingleton(() => TodosProvider(
    getTodosUseCase: sl(),
    addTodoUseCase: sl(),
    editTodoUseCase: sl(),
    deleteTodoUseCase: sl(),
    toggleTodoUseCase: sl(),
    repository: sl<TodoRepository>() as TodoRepositoryImpl,
  ));
}