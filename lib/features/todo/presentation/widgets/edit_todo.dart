// ─── Edit Todo Dialog ─────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_todo/features/todo/domain/entities/todo_entity.dart';
import 'package:provider_todo/features/todo/presentation/provider/todos_provider.dart';
import 'package:provider_todo/features/todo/presentation/widgets/todo_form.dart';

class EditTodoDialog extends StatelessWidget {
  final TodoEntity todoEntity;
  const EditTodoDialog({super.key, required this.todoEntity});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Edit Todo',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TodoForm(
            title: todoEntity.title,
            description: todoEntity.description,
            buttonLabel: 'Update Todo',
            onSubmit: (title, description) {
              context.read<TodosProvider>().editTodo(
                    id: todoEntity.id,
                    title: title,
                    description: description,
                  );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}