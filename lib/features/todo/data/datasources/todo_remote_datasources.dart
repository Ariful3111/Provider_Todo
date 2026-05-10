// lib/features/todo/data/datasources/todo_remote_datasource.dart
import 'package:provider_todo/core/errors/exceptions.dart';
import 'package:provider_todo/features/todo/data/model/todo_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class TodoRemoteDataSource {
  Future<List<TodoModel>> getTodos();
  Future<TodoModel> addTodo(TodoModel todo);
  Future<TodoModel> editTodo(TodoModel todo);
  Future<String> deleteTodo(String id);
  Future<TodoModel> toggleTodo(String id);
}

class TodoRemoteDataSourceImpl implements TodoRemoteDataSource {
  final SupabaseClient _client;
  static const _table = 'todos';

  TodoRemoteDataSourceImpl(this._client);  // ✅ client injected via DI

  @override
  Future<List<TodoModel>> getTodos() async {
    try {
      final response = await _client
          .from(_table)
          .select()
          .order('created_at', ascending: false);
      return (response as List)
          .map((json) => TodoModel.fromJson(json))
          .toList();
    } catch (e) {
      throw CacheException('Failed to fetch todos: $e');
    }
  }

  @override
  Future<TodoModel> addTodo(TodoModel todo) async {
    try {
      final response = await _client
          .from(_table)
          .insert(todo.toJson())
          .select()
          .single();
      return TodoModel.fromJson(response);
    } catch (e) {
      throw CacheException('Failed to add todo: $e');
    }
  }

  @override
  Future<TodoModel> editTodo(TodoModel todo) async {
    try {
      final response = await _client
          .from(_table)
          .update(todo.toJson())
          .eq('id', todo.id)
          .select()
          .single();
      return TodoModel.fromJson(response);
    } catch (e) {
      throw CacheException('Failed to edit todo: $e');
    }
  }

  @override
  Future<String> deleteTodo(String id) async {
    try {
      await _client.from(_table).delete().eq('id', id);
      return id;
    } catch (e) {
      throw CacheException('Failed to delete todo: $e');
    }
  }

  @override
  Future<TodoModel> toggleTodo(String id) async {
    try {
      final current = await _client
          .from(_table)
          .select()
          .eq('id', id)
          .single();
      final updated = await _client
          .from(_table)
          .update({'is_completed': !current['is_completed']})
          .eq('id', id)
          .select()
          .single();
      return TodoModel.fromJson(updated);
    } catch (e) {
      throw CacheException('Failed to toggle todo: $e');
    }
  }
}