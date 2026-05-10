// lib/features/todo/data/datasources/todo_local_datasource.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider_todo/core/errors/exceptions.dart';
import 'package:provider_todo/features/todo/data/model/todo_model.dart';

abstract class TodoLocalDataSource {
  List<TodoModel> getTodos();
  TodoModel addTodo(TodoModel todo);
  TodoModel editTodo(TodoModel todo);
  String deleteTodo(String id);
  TodoModel toggleTodo(String id);
}

class TodoLocalDataSourceImpl implements TodoLocalDataSource {
  final Box<TodoModel> _box;

  TodoLocalDataSourceImpl(this._box);   // ✅ box injected via DI

  @override
  List<TodoModel> getTodos() {
    try {
      return _box.values.toList();
    } catch (e) {
      throw const CacheException('Failed to retrieve todos from Hive');
    }
  }

  @override
  TodoModel addTodo(TodoModel todo) {
    try {
      _box.put(todo.id, todo);
      return todo;
    } catch (e) {
      throw const CacheException('Failed to add todo to Hive');
    }
  }

  @override
  TodoModel editTodo(TodoModel todo) {
    if (!_box.containsKey(todo.id)) {
      throw const NotFoundException('Todo not found in Hive for editing');
    }
    _box.put(todo.id, todo);
    return todo;
  }

  @override
  String deleteTodo(String id) {
    if (!_box.containsKey(id)) {
      throw const NotFoundException('Todo not found in Hive for deletion');
    }
    _box.delete(id);
    return id;
  }

  @override
  TodoModel toggleTodo(String id) {
    final todo = _box.get(id);
    if (todo == null) {
      throw const NotFoundException('Todo not found in Hive for toggle');
    }
    final updated = todo.copyWith(isCompleted: !todo.isCompleted);
    _box.put(id, updated);
    return updated;
  }
}