import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:provider_todo/core/shared/widgets/app_snackbar.dart';
import 'package:provider_todo/features/todo/domain/entities/todo_entity.dart';
import 'package:provider_todo/features/todo/presentation/provider/todos_provider.dart';

class CompletedTodosPage extends StatelessWidget {
  const CompletedTodosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final completedTodos = context.watch<TodosProvider>().completedTodos;

    if (completedTodos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.done_all_rounded, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No completed todos yet.\nCheck off some tasks!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: completedTodos.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final todo = completedTodos[index];
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: _CompletedTodoItem(key: ValueKey(todo.id), todoEntity: todo),
        );
      },
    );
  }
}

class _CompletedTodoItem extends StatelessWidget {
  final TodoEntity todoEntity;
  const _CompletedTodoItem({super.key, required this.todoEntity});

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(todoEntity.id),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        dismissible: DismissiblePane(
          onDismissed: () {
            context.read<TodosProvider>().deleteTodo(todoEntity.id);
            AppSnackbar().errorSnackBar(
              context: context,
              message: '"${todoEntity.title}" removed',
            );
          },
        ),
        children: [
          SlidableAction(
            onPressed: (_) =>
                context.read<TodosProvider>().deleteTodo(todoEntity.id),
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
            onPressed: (_) =>
                context.read<TodosProvider>().toggleTodo(todoEntity.id),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            icon: Icons.undo,
            label: 'Undo',
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(12),
            ),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Checkbox(
              activeColor: Theme.of(context).primaryColor,
              checkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              value: true,
              onChanged: (_) =>
                  context.read<TodosProvider>().toggleTodo(todoEntity.id),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todoEntity.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  if (todoEntity.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        todoEntity.description,
                        style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.check_circle_rounded,
              color: Theme.of(context).primaryColor,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
