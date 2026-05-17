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
import 'package:provider_todo/features/profile/data/data_sources/user_remote_data_source.dart';
import 'package:provider_todo/features/profile/data/repositories/user_repositoey_impl.dart';
import 'package:provider_todo/features/profile/domain/repositories/user_repository.dart';
import 'package:provider_todo/features/profile/domain/usecases/get_user_stats_usecase.dart';
import 'package:provider_todo/features/profile/domain/usecases/get_user_usecase.dart';
import 'package:provider_todo/features/profile/domain/usecases/update_user_name_usecase.dart';
import 'package:provider_todo/features/profile/domain/usecases/update_password_usecase.dart';
import 'package:provider_todo/features/profile/domain/usecases/upload_avater_usecase.dart';
import 'package:provider_todo/features/profile/presentation/provider/profile_provider.dart';
import 'package:provider_todo/features/todo/data/datasources/todo_local_datasources.dart';
import 'package:provider_todo/features/todo/data/datasources/todo_remote_datasources.dart';
import 'package:provider_todo/features/todo/data/model/todo_model.dart';
import 'package:provider_todo/features/todo/data/repositories/todo_repository_impl.dart';
import 'package:provider_todo/features/todo/domain/repositories/todo_repositories.dart';
import 'package:provider_todo/features/todo/domain/usecases/add_todos_usecase.dart';
import 'package:provider_todo/features/todo/domain/usecases/delete_todos_usecase.dart';
import 'package:provider_todo/features/todo/domain/usecases/edit_todos_usecase.dart';
import 'package:provider_todo/features/todo/domain/usecases/get_todos_usecase.dart';
import 'package:provider_todo/features/todo/domain/usecases/toggle_todos_usecase.dart';
import 'package:provider_todo/features/todo/presentation/provider/todos_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  await _initHive();
  await _initSupabase();
  _registerDataSources();   // datasources only
  _registerRepositories();  // repositories only
  _registerUseCases();      // use cases only
  _registerProviders();     // providers only
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
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
}

// ─── Data Sources ─────────────────────────────────────────────
void _registerDataSources() {
  // Todo
  sl.registerLazySingleton<TodoLocalDataSource>(
    () => TodoLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<TodoRemoteDataSource>(
    () => TodoRemoteDataSourceImpl(sl()),
  );
  // Profile
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(sl<SupabaseClient>()),
  );
}

// ─── Repositories ─────────────────────────────────────────────
void _registerRepositories() {
  // Todo
  sl.registerLazySingleton<TodoRepository>(
    () => TodoRepositoryImpl(
      localDataSource:  sl(),
      remoteDataSource: sl(),
    ),
  );
  // Profile
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(remoteDataSource: sl()),
  );
}

// ─── Use Cases ────────────────────────────────────────────────
void _registerUseCases() {
  // Todo
  sl.registerLazySingleton(() => GetTodosUseCase(sl()));
  sl.registerLazySingleton(() => AddTodoUseCase(sl()));
  sl.registerLazySingleton(() => EditTodoUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTodoUseCase(sl()));
  sl.registerLazySingleton(() => ToggleTodoUseCase(sl()));

  // Profile — all 5 registered HERE only, nowhere else
  sl.registerLazySingleton(() => GetUserUseCase(sl()));
  sl.registerLazySingleton(() => GetUserStatsUseCase(sl()));
  sl.registerLazySingleton(() => UploadAvatarUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserNameUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePasswordUseCase(sl()));
}

// ─── Providers ────────────────────────────────────────────────
void _registerProviders() {
  // Theme
  sl.registerLazySingleton(() => ThemeProvider());

  // Auth
  sl.registerLazySingleton(() => AuthProvider(sl<SupabaseClient>()));
  sl.registerLazySingleton(() => AuthListener(sl<SupabaseClient>()));
  sl.registerLazySingleton(() => SignInProvider(sl<SupabaseClient>()));
  sl.registerLazySingleton(() => SignUpProvider(sl<SupabaseClient>()));
  sl.registerLazySingleton(() => OtpProvider(sl<SupabaseClient>()));
  sl.registerLazySingleton(() => OAuthSignInProvider(sl<SupabaseClient>()));
  sl.registerLazySingleton(() => ForgotPasswordProvider(sl<SupabaseClient>()));

  // Todo
  sl.registerLazySingleton(() => TodosProvider(
    getTodosUseCase:   sl(),
    addTodoUseCase:    sl(),
    editTodoUseCase:   sl(),
    deleteTodoUseCase: sl(),
    toggleTodoUseCase: sl(),
    repository: sl<TodoRepository>() as TodoRepositoryImpl,
  ));

  // Profile — only providers here, NO datasources/repos/usecases
  sl.registerLazySingleton(() => ProfileProvider(
    getUserUseCase:        sl(),
    getUserStatsUseCase:   sl(),
    uploadAvatarUseCase:   sl(),
    updateUserNameUseCase: sl(),
    updatePasswordUseCase: sl(),
  ));
}