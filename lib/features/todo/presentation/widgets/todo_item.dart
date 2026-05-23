// lib/features/todo/presentation/widgets/todo_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:provider_todo/core/constant/app_colors.dart';
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
        dismissible: DismissiblePane(
          onDismissed: () => _deleteTodo(context),
        ),
        children: [
          SlidableAction(
            onPressed: (_) => _deleteTodo(context),
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline_rounded,
            label: 'Delete',
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(12.r),
              bottomRight: Radius.circular(12.r),
            ),
          ),
        ],
      ),
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _editTodo(context),
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            icon: Icons.edit_outlined,
            label: 'Edit',
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.r),
              bottomLeft: Radius.circular(12.r),
            ),
          ),
        ],
      ),
      child: _TodoItemContent(todoEntity: todoEntity),
    );
  }

  void _deleteTodo(BuildContext context) {
    final provider  = context.read<TodosProvider>();
    final snapshot  = todoEntity;
    provider.deleteTodo(todoEntity.id);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.black87,
        duration: const Duration(seconds: 3),
        content: Text('"${snapshot.title}" deleted'),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.blue[200],
          onPressed: () => provider.reAddTodo(snapshot),
        ),
      ));
  }

  void _editTodo(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditTodoDialog(todoEntity: todoEntity),
    );
  }
}

class _TodoItemContent extends StatelessWidget {
  final TodoEntity todoEntity;
  const _TodoItemContent({required this.todoEntity});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<TodosProvider>().toggleTodo(todoEntity.id),
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Row(
          children: [
            // ── Custom Checkbox ──────────────────────────
            _RoundedCheckbox(
              checked: todoEntity.isCompleted,
              onTap: () =>
                  context.read<TodosProvider>().toggleTodo(todoEntity.id),
            ),
            SizedBox(width: 16.w),

            // ── Title ────────────────────────────────────
            Expanded(
              child: Text(
                todoEntity.title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: todoEntity.isCompleted
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF1A1D2E),
                  decoration: todoEntity.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Custom rounded-square checkbox ────────────────────────────
class _RoundedCheckbox extends StatelessWidget {
  final bool checked;
  final VoidCallback onTap;
  const _RoundedCheckbox({required this.checked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 26.r,
        height: 26.r,
        decoration: BoxDecoration(
          color: checked
              ? AppColors.primaryColor
              : const Color(0xFFDEEAFF),
          borderRadius: BorderRadius.circular(7.r),
        ),
        child: checked
            ? Icon(Icons.check_rounded,
                size: 16.sp,
                color: Colors.white)
            : null,
      ),
    );
  }
}