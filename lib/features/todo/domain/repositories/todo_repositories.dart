import 'package:dartz/dartz.dart';
import 'package:provider_todo/core/errors/failures.dart';
import 'package:provider_todo/features/todo/domain/entities/todo_entity.dart';

// Abstract contract — domain knows WHAT to do, not HOW
abstract class TodoRepository {
  Either<Failure, List<TodoEntity>> getTodos();
  Either<Failure, TodoEntity> addTodo(TodoEntity todo);
  Either<Failure, TodoEntity> editTodo(TodoEntity todo);
  Either<Failure, String> deleteTodo(String id);
  Either<Failure, TodoEntity> toggleTodo(String id);
}