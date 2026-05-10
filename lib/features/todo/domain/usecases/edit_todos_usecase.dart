import 'package:dartz/dartz.dart';
import 'package:provider_todo/core/errors/failures.dart';
import 'package:provider_todo/features/todo/domain/entities/todo_entity.dart';
import 'package:provider_todo/features/todo/domain/repositories/todo_repositories.dart';

class EditTodoUseCase {
  final TodoRepository repository;
  const EditTodoUseCase(this.repository);

  Either<Failure, TodoEntity> call(TodoEntity todo) =>
      repository.editTodo(todo);
}