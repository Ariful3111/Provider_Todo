// lib/core/di/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider_todo/core/constant/static_datas.dart';
import 'package:provider_todo/features/auth/presentation/provider/auth_provider.dart';
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
  _registerProviders();
  _registerAuth();            // ← separated for clarity
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
void _registerProviders() {
  sl.registerFactory(
    () => TodosProvider(
      getTodosUseCase: sl(),
      addTodoUseCase: sl(),
      editTodoUseCase: sl(),
      deleteTodoUseCase: sl(),
      toggleTodoUseCase: sl(),
    ),
  );
}

// ─── Auth Provider ────────────────────────────────────────────
void _registerAuth() {
  sl.registerFactory(
    () => AuthProvider(sl<SupabaseClient>()),
  );
}