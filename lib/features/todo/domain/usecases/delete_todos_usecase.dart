import 'package:dartz/dartz.dart';
import 'package:provider_todo/core/errors/failures.dart';
import 'package:provider_todo/features/todo/domain/repositories/todo_repositories.dart';

class DeleteTodoUseCase {
  final TodoRepository repository;
  const DeleteTodoUseCase(this.repository);

  Either<Failure, String> call(String id) => repository.deleteTodo(id);
}
