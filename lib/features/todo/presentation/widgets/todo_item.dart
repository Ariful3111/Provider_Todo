import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:provider_todo/core/shared/widgets/app_snackbar.dart';
import 'package:provider_todo/features/todo/domain/entities/todo_entity.dart';
import 'package:provider_todo/features/todo/presentation/provider/todos_provider.dart';
import 'package:provider_todo/features/todo/presentation/widgets/edit_todo.dart';

class TodoItem extends StatelessWidget {
  final TodoEntity todoEntity;
  const TodoItem({super.key, required this.todoEntity});

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(todoEntity.id),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        dismissible: DismissiblePane(onDismissed: () => _deleteTodo(context)),
        children: [
          SlidableAction(
            onPressed: (_) => _deleteTodo(context),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(12),
            ),
          ),
        ],
      ),
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _editTodo(context),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(12),
            ),
          ),
        ],
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedScale(
              scale: todoEntity.isCompleted ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Checkbox(
                activeColor: Theme.of(context).primaryColor,
                checkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                value: todoEntity.isCompleted,
                onChanged: (_) =>
                    context.read<TodosProvider>().toggleTodo(todoEntity.id),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: todoEntity.isCompleted
                          ? Colors.grey
                          : Theme.of(context).primaryColor,
                      decoration: todoEntity.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                    child: Text(todoEntity.title),
                  ),
                  if (todoEntity.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        todoEntity.description,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteTodo(BuildContext context) {
    final provider = context.read<TodosProvider>();
    final snapshot = todoEntity; // keep reference for undo
    provider.deleteTodo(todoEntity.id);
    AppSnackbar().errorSnackBar(
      message: '"${snapshot.title}" deleted',
      context: context,
    );
  }

  void _editTodo(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditTodoDialog(todoEntity: todoEntity),
    );
  }
}
