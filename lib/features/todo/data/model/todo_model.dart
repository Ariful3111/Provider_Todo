// lib/features/todo/data/model/todo_model.dart
import 'package:hive/hive.dart';
import 'package:provider_todo/features/todo/domain/entities/todo_entity.dart';

part 'todo_model.g.dart';

@HiveType(typeId: 0)
class TodoModel extends TodoEntity {
  @HiveField(0)
  final String hiveId;

  @HiveField(1)
  final String hiveTitle;

  @HiveField(2)
  final String hiveDescription;

  @HiveField(3)
  final DateTime hiveCreatedAt;

  @HiveField(4)
  final bool hiveIsCompleted;

  const TodoModel({
    required super.id,
    required super.title,
    required super.description,
    required super.createdAt,
    super.isCompleted = false,
  })  : hiveId = id,
        hiveTitle = title,
        hiveDescription = description,
        hiveCreatedAt = createdAt,
        hiveIsCompleted = isCompleted;

  // ✅ Convert from Supabase JSON response
  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  // ✅ Convert to JSON for Supabase insert/update
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  // Convert from domain entity → model
  factory TodoModel.fromEntity(TodoEntity entity) {
    return TodoModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      createdAt: entity.createdAt,
      isCompleted: entity.isCompleted,
    );
  }

  @override
  TodoModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    bool? isCompleted,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}