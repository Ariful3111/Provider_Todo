import 'package:flutter/material.dart';
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

  TodosProvider({
    required this.getTodosUseCase,
    required this.addTodoUseCase,
    required this.editTodoUseCase,
    required this.deleteTodoUseCase,
    required this.toggleTodoUseCase,
  }) {
    // Load todos when provider is first created
    loadTodos();
  }

  TodoStatus _status = TodoStatus.initial;
  List<TodoEntity> _todos = [];
  String? _errorMessage;

  TodoStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<TodoEntity> get todos =>
      _todos.where((t) => !t.isCompleted).toList();

  List<TodoEntity> get completedTodos =>
      _todos.where((t) => t.isCompleted).toList();

  // ─── Load ────────────────────────────────────────────────────
  void loadTodos() {
    final result = getTodosUseCase();
    result.fold(
      (failure) {
        _status = TodoStatus.error;
        _errorMessage = failure.message;
      },
      (todos) {
        _todos = todos.toList();
        _status = TodoStatus.success;
      },
    );
    notifyListeners();
  }

  // ─── Add ─────────────────────────────────────────────────────
  void addTodo({required String title, required String description}) {
    final todo = TodoEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );

    final result = addTodoUseCase(todo);
    result.fold(
      (failure) => _setError(failure.message),
      (newTodo) {
        _todos.add(newTodo);
        _clearError();
      },
    );
    notifyListeners();
  }

  // ─── Edit ────────────────────────────────────────────────────
  void editTodo({
    required String id,
    required String title,
    required String description,
  }) {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final updated = _todos[index].copyWith(
      title: title,
      description: description,
      createdAt: DateTime.now(), // refresh timestamp on edit
    );

    final result = editTodoUseCase(updated);
    result.fold(
      (failure) => _setError(failure.message),
      (editedTodo) {
        _todos[index] = editedTodo;
        _clearError();
      },
    );
    notifyListeners();
  }

  // ─── Delete ──────────────────────────────────────────────────
  void deleteTodo(String id) {
    final result = deleteTodoUseCase(id);
    result.fold(
      (failure) => _setError(failure.message),
      (_) {
        _todos.removeWhere((t) => t.id == id);
        _clearError();
      },
    );
    notifyListeners();
  }

  // ─── Toggle ──────────────────────────────────────────────────
  void toggleTodo(String id) {
    final result = toggleTodoUseCase(id);
    result.fold(
      (failure) => _setError(failure.message),
      (updatedTodo) {
        final index = _todos.indexWhere((t) => t.id == id);
        if (index != -1) _todos[index] = updatedTodo;
        _clearError();
      },
    );
    notifyListeners();
  }

  // ─── Re-add for undo ─────────────────────────────────────────
  void reAddTodo(TodoEntity todo) {
    final result = addTodoUseCase(todo);
    result.fold(
      (failure) => _setError(failure.message),
      (newTodo) {
        _todos.add(newTodo);
        _clearError();
      },
    );
    notifyListeners();
  }

  void _setError(String message) {
    _status = TodoStatus.error;
    _errorMessage = message;
  }

  void _clearError() {
    _status = TodoStatus.success;
    _errorMessage = null;
  }
}