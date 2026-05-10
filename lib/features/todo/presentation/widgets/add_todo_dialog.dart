import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_todo/features/todo/presentation/provider/todos_provider.dart';
import 'package:provider_todo/features/todo/presentation/widgets/todo_form.dart';

// ─── Add Todo Dialog ──────────────────────────────────────────
class AddTodoDialog extends StatelessWidget {
  const AddTodoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add Todo',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TodoForm(
            title: '',
            description: '',
            buttonLabel: 'Add Todo',
            onSubmit: (title, description) {
              context.read<TodosProvider>().addTodo(
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

