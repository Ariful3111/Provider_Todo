// lib/features/todo/data/model/todo_model.dart
import 'package:hive/hive.dart';
import 'package:provider_todo/features/todo/domain/entities/todo_entity.dart';

part 'todo_model.g.dart';

@HiveType(typeId: 0)
class TodoModel extends TodoEntity {
  @HiveField(0) final String    hiveId;
  @HiveField(1) final String    hiveTitle;
  @HiveField(2) final String    hiveDescription;
  @HiveField(3) final DateTime  hiveCreatedAt;
  @HiveField(4) final bool      hiveIsCompleted;
  @HiveField(5) final DateTime? hiveCompletedAt;  // ✅ NEW field

  const TodoModel({
    required super.id,
    required super.title,
    required super.description,
    required super.createdAt,
    super.isCompleted  = false,
    super.completedAt,
  })  : hiveId          = id,
        hiveTitle       = title,
        hiveDescription = description,
        hiveCreatedAt   = createdAt,
        hiveIsCompleted = isCompleted,
        hiveCompletedAt = completedAt;

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id:          json['id']          as String,
      title:       json['title']       as String? ?? '',
      description: json['description'] as String? ?? '',
      isCompleted: json['is_completed'] as bool?  ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':           id,
    'title':        title,
    'description':  description,
    'is_completed': isCompleted,
    'created_at':   createdAt.toIso8601String(),
    'updated_at':   DateTime.now().toIso8601String(),
    'completed_at': completedAt?.toIso8601String(),
  };

  factory TodoModel.fromEntity(TodoEntity e) => TodoModel(
    id:          e.id,
    title:       e.title,
    description: e.description,
    createdAt:   e.createdAt,
    isCompleted: e.isCompleted,
    completedAt: e.completedAt,
  );

  @override
  TodoModel copyWith({
    String?   id,
    String?   title,
    String?   description,
    DateTime? createdAt,
    bool?     isCompleted,
    DateTime? completedAt,
    bool      clearCompletedAt = false,
  }) => TodoModel(
    id:          id          ?? this.id,
    title:       title       ?? this.title,
    description: description ?? this.description,
    createdAt:   createdAt   ?? this.createdAt,
    isCompleted: isCompleted ?? this.isCompleted,
    completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
  );
}