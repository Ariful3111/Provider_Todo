import 'package:dartz/dartz.dart';
import 'package:provider_todo/core/errors/exceptions.dart';
import 'package:provider_todo/core/errors/failures.dart';
import 'package:provider_todo/features/todo/data/datasources/todo_local_datasources.dart';
import 'package:provider_todo/features/todo/data/datasources/todo_remote_datasources.dart';
import 'package:provider_todo/features/todo/data/model/todo_model.dart';
import 'package:provider_todo/features/todo/domain/entities/todo_entity.dart';
import 'package:provider_todo/features/todo/domain/repositories/todo_repositories.dart';
class TodoRepositoryImpl implements TodoRepository {
  final TodoLocalDataSource localDataSource;
  final TodoRemoteDataSource remoteDataSource;

  const TodoRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Either<Failure, List<TodoEntity>> getTodos() {
    try {
      // ✅ Always read from Hive first (offline-first)
      final local = localDataSource.getTodos();
      return Right(local);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Either<Failure, TodoEntity> addTodo(TodoEntity todo) {
    try {
      final model = TodoModel.fromEntity(todo);
      // ✅ Save to Hive immediately
      final result = localDataSource.addTodo(model);
      // 🔄 Sync to Supabase in background
      remoteDataSource.addTodo(model);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  // ─── Edit Todo ──────────────────────────────────────────────
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

  // ─── Delete Todo ────────────────────────────────────────────
  @override
  Either<Failure, String> deleteTodo(String id) {
    try {
      final deletedId = localDataSource.deleteTodo(id);
      return Right(deletedId);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ─── Toggle Todo ────────────────────────────────────────────
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
}