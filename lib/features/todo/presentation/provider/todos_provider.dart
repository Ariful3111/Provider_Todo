// lib/features/todo/presentation/provider/todos_provider.dart
import 'package:flutter/material.dart';
import 'package:provider_todo/features/todo/data/repositories/todo_repository_impl.dart';
import 'package:provider_todo/features/todo/domain/entities/todo_entity.dart';
import 'package:provider_todo/features/todo/domain/usecases/add_todos_usecase.dart';
import 'package:provider_todo/features/todo/domain/usecases/delete_todos_usecase.dart';
import 'package:provider_todo/features/todo/domain/usecases/edit_todos_usecase.dart';
import 'package:provider_todo/features/todo/domain/usecases/get_todos_usecase.dart';
import 'package:provider_todo/features/todo/domain/usecases/toggle_todos_usecase.dart';

enum TodoStatus { initial, loading, success, error }

class TodosProvider extends ChangeNotifier {
  final GetTodosUseCase getTodosUseCase;
  final AddTodoUseCase addTodoUseCase;
  final EditTodoUseCase editTodoUseCase;
  final DeleteTodoUseCase deleteTodoUseCase;
  final ToggleTodoUseCase toggleTodoUseCase;
  final TodoRepositoryImpl repository;

  TodosProvider({
    required this.getTodosUseCase,
    required this.addTodoUseCase,
    required this.editTodoUseCase,
    required this.deleteTodoUseCase,
    required this.toggleTodoUseCase,
    required this.repository,
  }) {
    loadTodos();
  }

  TodoStatus _status = TodoStatus.initial;

  // ✅ KEY FIX: explicitly typed growable List<TodoEntity>
  // Use <TodoEntity>[] NOT just [] — prevents runtime type lock to List<TodoModel>
  List<TodoEntity> _todos = <TodoEntity>[];

  String? _errorMessage;

  TodoStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<TodoEntity> get todos => _todos.where((t) => !t.isCompleted).toList();
  List<TodoEntity> get completedTodos =>
      _todos.where((t) => t.isCompleted).toList();

  // ✅ Always use this to assign — never assign toList() directly from remote
  List<TodoEntity> _toEntityList(List<dynamic> source) =>
      List<TodoEntity>.of(source.cast<TodoEntity>());

  // ─── Load ─────────────────────────────────────────────────
  Future<void> loadTodos() async {
    _status = TodoStatus.loading;
    notifyListeners();

    final result = await repository.fetchAndSyncTodos();
    result.fold(
      (failure) {
        debugPrint('❌ Load error: ${failure.message}');
        final localResult = getTodosUseCase();
        localResult.fold(
          (e) {
            _status = TodoStatus.error;
            _errorMessage = failure.message;
          },
          (todos) {
            _todos = _toEntityList(todos);
            _status = TodoStatus.success;
          },
        );
      },
      (todos) {
        _todos = _toEntityList(todos);
        _status = TodoStatus.success;
        debugPrint('✅ Loaded ${_todos.length} todos');
      },
    );
    notifyListeners();
  }

  // ─── Add ──────────────────────────────────────────────────
  Future<void> addTodo({
    required String title,
    required String description,
  }) async {
    final todo = TodoEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );

    _todos.add(todo); // ✅ works now — _todos is genuinely List<TodoEntity>
    notifyListeners();

    final result = await repository.addTodoRemote(todo);
    result.fold(
      (failure) {
        debugPrint('❌ Add error: ${failure.message}');
        _todos.removeWhere((t) => t.id == todo.id);
        _errorMessage = failure.message;
        notifyListeners();
        Future.delayed(const Duration(seconds: 2), () {
          _errorMessage = null;
          notifyListeners();
        });
      },
      (savedTodo) {
        final index = _todos.indexWhere((t) => t.id == todo.id);
        if (index != -1) _todos[index] = savedTodo;
        debugPrint('✅ Saved: ${savedTodo.title}');
        notifyListeners();
      },
    );
  }

  // ─── Edit ─────────────────────────────────────────────────
  Future<void> editTodo({
    required String id,
    required String title,
    required String description,
  }) async {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final oldTodo = _todos[index];
    _todos[index] = oldTodo.copyWith(
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );
    notifyListeners();

    final result = await repository.editTodoRemote(_todos[index]);
    result.fold(
      (failure) {
        debugPrint('❌ Edit error: ${failure.message}');
        _todos[index] = oldTodo;
        notifyListeners();
      },
      (editedTodo) {
        _todos[index] = editedTodo;
        debugPrint('✅ Updated: ${editedTodo.title}');
        notifyListeners();
      },
    );
  }

  // ─── Delete ───────────────────────────────────────────────
  Future<void> deleteTodo(String id) async {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final deletedTodo = _todos[index];
    _todos.removeAt(index);
    notifyListeners();

    final result = await repository.deleteTodoRemote(id);
    result.fold(
      (failure) {
        debugPrint('❌ Delete error: ${failure.message}');
        _todos.insert(index, deletedTodo);
        notifyListeners();
      },
      (_) {
        debugPrint('✅ Deleted: $id');
        notifyListeners();
      },
    );
  }

  // ─── Toggle ───────────────────────────────────────────────
  Future<void> toggleTodo(String id) async {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final oldTodo = _todos[index];
    _todos[index] = oldTodo.copyWith(isCompleted: !oldTodo.isCompleted);
    notifyListeners();

    final result = await repository.toggleTodoRemote(id);
    result.fold(
      (failure) {
        debugPrint('❌ Toggle error: ${failure.message}');
        _todos[index] = oldTodo;
        notifyListeners();
      },
      (updatedTodo) {
        _todos[index] = updatedTodo;
        debugPrint('✅ Toggled: $id');
        notifyListeners();
      },
    );
  }

  // ─── Re-add for undo ──────────────────────────────────────
  Future<void> reAddTodo(TodoEntity todo) async {
    _todos.add(todo);
    notifyListeners();
    final result = await repository.addTodoRemote(todo);
    result.fold(
      (failure) {
        _todos.removeWhere((t) => t.id == todo.id);
        notifyListeners();
      },
      (savedTodo) {
        final index = _todos.indexWhere((t) => t.id == todo.id);
        if (index != -1) _todos[index] = savedTodo;
        notifyListeners();
      },
    );
  }
}
