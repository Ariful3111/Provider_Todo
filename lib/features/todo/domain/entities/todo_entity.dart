// lib/features/todo/domain/entities/todo_entity.dart

class TodoEntity {
  final String    id;
  final String    title;
  final String    description;
  final DateTime  createdAt;
  final bool      isCompleted;
  final DateTime? completedAt;   // ✅ NEW — tracks when completed

  const TodoEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.isCompleted  = false,
    this.completedAt,
  });

  TodoEntity copyWith({
    String?    id,
    String?    title,
    String?    description,
    DateTime?  createdAt,
    bool?      isCompleted,
    DateTime?  completedAt,
    bool       clearCompletedAt = false,
  }) {
    return TodoEntity(
      id:           id          ?? this.id,
      title:        title       ?? this.title,
      description:  description ?? this.description,
      createdAt:    createdAt   ?? this.createdAt,
      isCompleted:  isCompleted ?? this.isCompleted,
      completedAt:  clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }
}