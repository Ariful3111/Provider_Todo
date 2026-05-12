// lib/features/todo/data/repositories/todo_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:provider_todo/core/errors/exceptions.dart';
import 'package:provider_todo/core/errors/failures.dart';
import 'package:provider_todo/core/errors/server_exception.dart' hide NotFoundException, CacheException;
import 'package:provider_todo/core/errors/server_failure.dart' hide UnknownFailure, Failure, NotFoundFailure, CacheFailure;
import 'package:provider_todo/features/todo/data/datasources/todo_local_datasources.dart';
import 'package:provider_todo/features/todo/data/datasources/todo_remote_datasources.dart';
import 'package:provider_todo/features/todo/data/model/todo_model.dart';
import 'package:provider_todo/features/todo/domain/entities/todo_entity.dart';
import 'package:provider_todo/features/todo/domain/repositories/todo_repositories.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoRemoteDataSource remoteDataSource; // Supabase ← primary
  final TodoLocalDataSource localDataSource;   // Hive ← cache/offline

  const TodoRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  // ─── Get Todos ────────────────────────────────────────────
  @override
  Either<Failure, List<TodoEntity>> getTodos() {
    // Return local cache immediately (fast UI)
    // Remote fetch happens in TodosProvider.loadTodos()
    try {
      final todos = localDataSource.getTodos();
      return Right(todos);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ─── Fetch from Supabase and sync to Hive ─────────────────
  Future<Either<Failure, List<TodoEntity>>> fetchAndSyncTodos() async {
    try {
      // 1. Fetch from Supabase
      final remoteTodos = await remoteDataSource.getTodos();

      // 2. Sync to local Hive cache
      for (final todo in remoteTodos) {
        try {
          localDataSource.addTodo(todo);
        } catch (_) {
          // Already exists — update it
          localDataSource.editTodo(todo);
        }
      }

      return Right(remoteTodos);
    } on ServerException catch (e) {
      // 3. Fallback to local cache if offline
      try {
        final cachedTodos = localDataSource.getTodos();
        return Right(cachedTodos);
      } catch (_) {
        return Left(ServerFailure(e.message) as Failure);
      }
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ─── Add Todo ─────────────────────────────────────────────
  @override
  Either<Failure, TodoEntity> addTodo(TodoEntity todo) {
    // Add to local immediately for fast UI
    try {
      final model = TodoModel.fromEntity(todo);
      localDataSource.addTodo(model);
      // Remote add happens async in provider
      return Right(model);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ─── Add Todo Remote ──────────────────────────────────────
  Future<Either<Failure, TodoEntity>> addTodoRemote(TodoEntity todo) async {
    try {
      final model = TodoModel.fromEntity(todo);
      final result = await remoteDataSource.addTodo(model);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message) as Failure);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ─── Edit Todo ────────────────────────────────────────────
  @override
  Either<Failure, TodoEntity> editTodo(TodoEntity todo) {
    try {
      final model = TodoModel.fromEntity(todo);
      final result = localDataSource.editTodo(model);
      return Right(result);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ─── Edit Todo Remote ─────────────────────────────────────
  Future<Either<Failure, TodoEntity>> editTodoRemote(TodoEntity todo) async {
    try {
      final model = TodoModel.fromEntity(todo);
      final result = await remoteDataSource.editTodo(model);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message) as Failure);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ─── Delete Todo ──────────────────────────────────────────
  @override
  Either<Failure, String> deleteTodo(String id) {
    try {
      localDataSource.deleteTodo(id);
      return Right(id);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ─── Delete Todo Remote ───────────────────────────────────
  Future<Either<Failure, String>> deleteTodoRemote(String id) async {
    try {
      await remoteDataSource.deleteTodo(id);
      return Right(id);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message) as Failure);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ─── Toggle Todo ──────────────────────────────────────────
  @override
  Either<Failure, TodoEntity> toggleTodo(String id) {
    try {
      final result = localDataSource.toggleTodo(id);
      return Right(result);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ─── Toggle Todo Remote ───────────────────────────────────
  Future<Either<Failure, TodoEntity>> toggleTodoRemote(String id) async {
    try {
      final result = await remoteDataSource.toggleTodo(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message) as Failure);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}