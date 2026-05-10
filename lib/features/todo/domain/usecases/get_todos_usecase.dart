import 'package:dartz/dartz.dart';
import 'package:provider_todo/core/errors/failures.dart';
import 'package:provider_todo/features/todo/domain/entities/todo_entity.dart';
import 'package:provider_todo/features/todo/domain/repositories/todo_repositories.dart';
// ─── Get Todos ────────────────────────────────────────────────
class GetTodosUseCase {
  final TodoRepository repository;
  const GetTodosUseCase(this.repository);

  Either<Failure, List<TodoEntity>> call() => repository.getTodos();
}
