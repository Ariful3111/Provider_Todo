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

  // ✅ Direct reference to repository for remote operations
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
  List<TodoEntity> _todos = [];
  String? _errorMessage;

  TodoStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<TodoEntity> get todos => _todos.where((t) => !t.isCompleted).toList();
  List<TodoEntity> get completedTodos =>
      _todos.where((t) => t.isCompleted).toList();

  // ─── Load — fetch from Supabase ──────────────────────────
  Future<void> loadTodos() async {
    _status = TodoStatus.loading;
    notifyListeners();

    // ✅ Fetch from Supabase and sync to local cache
    final result = await repository.fetchAndSyncTodos();
    result.fold(
      (failure) {
        debugPrint('❌ Load todos error: ${failure.message}');
        // Fallback to local cache
        final localResult = getTodosUseCase();
        localResult.fold(
          (e) {
            _status = TodoStatus.error;
            _errorMessage = failure.message;
          },
          (todos) {
            _todos = todos.toList();
            _status = TodoStatus.success;
          },
        );
      },
      (todos) {
        _todos = todos.toList();
        _status = TodoStatus.success;
        debugPrint('✅ Loaded ${todos.length} todos from Supabase');
      },
    );
    notifyListeners();
  }

  // ─── Add — saves to Supabase ─────────────────────────────
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

    // ✅ Optimistic update — add to UI immediately
    _todos.add(todo);
    notifyListeners();

    // ✅ Save to Supabase
    final result = await repository.addTodoRemote(todo);
    result.fold(
      (failure) {
        debugPrint('❌ Add todo error: ${failure.message}');
        // Rollback if failed
        _todos.removeWhere((t) => t.id == todo.id);
        _errorMessage = failure.message;
      //  notifyListeners();

        // ✅ Auto-clear error after showing it
        Future.delayed(const Duration(seconds: 1), () {
          _errorMessage = null;
          notifyListeners();
        });
      },
      (savedTodo) {
        // Replace optimistic with saved version
        final index = _todos.indexWhere((t) => t.id == todo.id);
        if (index != -1) _todos[index] = savedTodo;
        debugPrint('✅ Todo saved to Supabase: ${savedTodo.title}');
      },
    );
    notifyListeners();
  }

  // ─── Edit — updates Supabase ─────────────────────────────
  Future<void> editTodo({
    required String id,
    required String title,
    required String description,
  }) async {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final oldTodo = _todos[index];
    final updated = oldTodo.copyWith(
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );

    // Optimistic update
    _todos[index] = updated;
    notifyListeners();

    // Save to Supabase
    final result = await repository.editTodoRemote(updated);
    result.fold(
      (failure) {
        debugPrint('❌ Edit todo error: ${failure.message}');
        _todos[index] = oldTodo; // rollback
        _errorMessage = failure.message;
      },
      (editedTodo) {
        _todos[index] = editedTodo;
        debugPrint('✅ Todo updated in Supabase: ${editedTodo.title}');
      },
    );
    notifyListeners();
  }

  // ─── Delete — removes from Supabase ─────────────────────
  Future<void> deleteTodo(String id) async {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final deletedTodo = _todos[index];

    // Optimistic delete
    _todos.removeAt(index);
    notifyListeners();

    // Delete from Supabase
    final result = await repository.deleteTodoRemote(id);
    result.fold((failure) {
      debugPrint('❌ Delete todo error: ${failure.message}');
      _todos.insert(index, deletedTodo); // rollback
      _errorMessage = failure.message;
    }, (_) => debugPrint('✅ Todo deleted from Supabase: $id'));
    notifyListeners();
  }

  // ─── Toggle — updates Supabase ───────────────────────────
  Future<void> toggleTodo(String id) async {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final oldTodo = _todos[index];
    // Optimistic toggle
    _todos[index] = oldTodo.copyWith(isCompleted: !oldTodo.isCompleted);
    notifyListeners();

    // Update in Supabase
    final result = await repository.toggleTodoRemote(id);
    result.fold(
      (failure) {
        debugPrint('❌ Toggle todo error: ${failure.message}');
        _todos[index] = oldTodo; // rollback
        _errorMessage = failure.message;
      },
      (updatedTodo) {
        _todos[index] = updatedTodo;
        debugPrint('✅ Todo toggled in Supabase: $id');
      },
    );
    notifyListeners();
  }

  // ─── Re-add for undo ─────────────────────────────────────
  Future<void> reAddTodo(TodoEntity todo) async {
    _todos.add(todo);
    notifyListeners();

    final result = await repository.addTodoRemote(todo);
    result.fold(
      (failure) {
        debugPrint('❌ Re-add todo error: ${failure.message}');
        _todos.removeWhere((t) => t.id == todo.id);
      },
      (savedTodo) {
        final index = _todos.indexWhere((t) => t.id == todo.id);
        if (index != -1) _todos[index] = savedTodo;
      },
    );
    notifyListeners();
  }
}
