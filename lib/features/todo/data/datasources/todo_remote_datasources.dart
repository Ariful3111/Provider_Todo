// lib/features/todo/data/datasources/todo_remote_datasource.dart
import 'package:provider_todo/core/errors/server_exception.dart';
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
  final SupabaseClient client;

  TodoRemoteDataSourceImpl(this.client);

  // ✅ Get current user ID — throws if not logged in
  String get _userId {
    final user = client.auth.currentUser;
    if (user == null) throw const ServerException('User not authenticated');
    return user.id;
  }

  // ─── Get all todos for current user ───────────────────────
  @override
  Future<List<TodoModel>> getTodos() async {
    try {
      final response = await client
          .from('todos')
          .select()
          .eq('user_id', _userId)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => TodoModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ─── Add todo ─────────────────────────────────────────────
  @override
  Future<TodoModel> addTodo(TodoModel todo) async {
    try {
      final data = {
        'id': todo.id,
        'user_id': _userId,
        'title': todo.title,
        'description': todo.description,
        'is_completed': todo.isCompleted,
        'created_at': todo.createdAt.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await client
          .from('todos')
          .insert(data)
          .select()
          .single();

      return TodoModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ─── Edit todo ────────────────────────────────────────────
  @override
  Future<TodoModel> editTodo(TodoModel todo) async {
    try {
      final response = await client
          .from('todos')
          .update({
            'title': todo.title,
            'description': todo.description,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', todo.id)
          .eq('user_id', _userId)
          .select()
          .single();

      return TodoModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ─── Delete todo ──────────────────────────────────────────
  @override
  Future<String> deleteTodo(String id) async {
    try {
      await client
          .from('todos')
          .delete()
          .eq('id', id)
          .eq('user_id', _userId);

      return id;
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ─── Toggle todo ──────────────────────────────────────────
  @override
Future<TodoModel> toggleTodo(String id) async {
  try {
    // Get current state
    final current = await client
        .from('todos')
        .select()
        .eq('id', id)
        .eq('user_id', _userId)
        .single();
 
    final isCompleted = !(current['is_completed'] as bool);
 
    // ✅ Set completedAt when completing, clear when uncompleting
    final response = await client
        .from('todos')
        .update({
          'is_completed': isCompleted,
          'completed_at': isCompleted
              ? DateTime.now().toIso8601String()
              : null,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .eq('user_id', _userId)
        .select()
        .single();
 
    return TodoModel.fromJson(response);
  } on PostgrestException catch (e) {
    throw ServerException(e.message);
  } catch (e) {
    throw ServerException(e.toString());
  }
}
}