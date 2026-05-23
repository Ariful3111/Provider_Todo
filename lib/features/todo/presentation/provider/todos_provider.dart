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
  final GetTodosUseCase    getTodosUseCase;
  final AddTodoUseCase     addTodoUseCase;
  final EditTodoUseCase    editTodoUseCase;
  final DeleteTodoUseCase  deleteTodoUseCase;
  final ToggleTodoUseCase  toggleTodoUseCase;
  final TodoRepositoryImpl repository;

  TodosProvider({
    required this.getTodosUseCase,
    required this.addTodoUseCase,
    required this.editTodoUseCase,
    required this.deleteTodoUseCase,
    required this.toggleTodoUseCase,
    required this.repository,
  });

  TodoStatus      _status       = TodoStatus.initial;
  List<TodoEntity> _todos       = <TodoEntity>[];
  String?         _errorMessage;
  DateTime        _selectedDate = _today();

  static DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  TodoStatus get status        => _status;
  String?    get errorMessage  => _errorMessage;
  DateTime   get selectedDate  => _selectedDate;

  // ── Date filtering helpers ────────────────────────────────
  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // Active todos for selected date (by createdAt)
  List<TodoEntity> get todos => _todos
      .where((t) => !t.isCompleted && _sameDay(t.createdAt, _selectedDate))
      .toList();

  // Completed todos for selected date (by completedAt)
  List<TodoEntity> get completedTodos => _todos
      .where((t) =>
          t.isCompleted &&
          t.completedAt != null &&
          _sameDay(t.completedAt!, _selectedDate))
      .toList();

  // All active (for badge counts)
  List<TodoEntity> get allActiveTodos =>
      _todos.where((t) => !t.isCompleted).toList();

  List<TodoEntity> get allCompletedTodos =>
      _todos.where((t) => t.isCompleted).toList();

  // ── Select date ───────────────────────────────────────────
  void selectDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    notifyListeners();
  }

  // ── Load ──────────────────────────────────────────────────
  Future<void> loadTodos() async {
    _status = TodoStatus.loading;
    notifyListeners();

    final result = await repository.fetchAndSyncTodos();
    result.fold(
      (failure) {
        debugPrint('❌ Load error: ${failure.message}');
        final localResult = getTodosUseCase();
        localResult.fold(
          (e) { _status = TodoStatus.error; _errorMessage = failure.message; },
          (todos) { _todos = _toList(todos); _status = TodoStatus.success; },
        );
      },
      (todos) {
        _todos = _toList(todos);
        _status = TodoStatus.success;
        debugPrint('✅ Loaded ${_todos.length} todos');
      },
    );
    notifyListeners();
  }

  // ── Add ───────────────────────────────────────────────────
  Future<void> addTodo({
    required String title,
    required String description,
  }) async {
    final todo = TodoEntity(
      id:          DateTime.now().millisecondsSinceEpoch.toString(),
      title:       title,
      description: description,
      createdAt:   DateTime.now(),
    );
    _todos.add(todo);
    notifyListeners();

    final result = await repository.addTodoRemote(todo);
    result.fold(
      (failure) {
        debugPrint('❌ Add error: ${failure.message}');
        _todos.removeWhere((t) => t.id == todo.id);
        _errorMessage = failure.message;
        notifyListeners();
        Future.delayed(const Duration(seconds: 2), () {
          _errorMessage = null; notifyListeners();
        });
      },
      (saved) {
        final i = _todos.indexWhere((t) => t.id == todo.id);
        if (i != -1) _todos[i] = saved;
        debugPrint('✅ Saved: ${saved.title}');
        notifyListeners();
      },
    );
  }

  // ── Edit ──────────────────────────────────────────────────
  Future<void> editTodo({
    required String id,
    required String title,
    required String description,
  }) async {
    final i = _todos.indexWhere((t) => t.id == id);
    if (i == -1) return;
    final old = _todos[i];
    _todos[i] = old.copyWith(title: title, description: description,
        createdAt: DateTime.now());
    notifyListeners();

    final result = await repository.editTodoRemote(_todos[i]);
    result.fold(
      (f) { _todos[i] = old; notifyListeners(); },
      (e) { _todos[i] = e;   notifyListeners(); },
    );
  }

  // ── Delete ────────────────────────────────────────────────
  Future<void> deleteTodo(String id) async {
    final i = _todos.indexWhere((t) => t.id == id);
    if (i == -1) return;
    final del = _todos[i];
    _todos.removeAt(i);
    notifyListeners();

    final result = await repository.deleteTodoRemote(id);
    result.fold(
      (f) { _todos.insert(i, del); notifyListeners(); },
      (_) { debugPrint('✅ Deleted: $id'); },
    );
  }

  // ── Toggle ────────────────────────────────────────────────
  Future<void> toggleTodo(String id) async {
    final i = _todos.indexWhere((t) => t.id == id);
    if (i == -1) return;
    final old = _todos[i];
    final completing = !old.isCompleted;

    // ✅ Set completedAt optimistically
    _todos[i] = old.copyWith(
      isCompleted:  completing,
      completedAt:  completing ? DateTime.now() : null,
      clearCompletedAt: !completing,
    );
    notifyListeners();

    final result = await repository.toggleTodoRemote(id);
    result.fold(
      (f) { _todos[i] = old; notifyListeners(); },
      (u) { _todos[i] = u;   notifyListeners(); },
    );
  }

  // ── Re-add for undo ───────────────────────────────────────
  Future<void> reAddTodo(TodoEntity todo) async {
    _todos.add(todo);
    notifyListeners();
    final result = await repository.addTodoRemote(todo);
    result.fold(
      (f) { _todos.removeWhere((t) => t.id == todo.id); notifyListeners(); },
      (s) {
        final i = _todos.indexWhere((t) => t.id == todo.id);
        if (i != -1) _todos[i] = s;
        notifyListeners();
      },
    );
  }

  List<TodoEntity> _toList(List<dynamic> source) =>
      List<TodoEntity>.of(source.cast<TodoEntity>());
}