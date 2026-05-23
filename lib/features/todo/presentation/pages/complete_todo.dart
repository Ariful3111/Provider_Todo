// lib/features/todo/presentation/pages/complete_todo.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:provider_todo/core/constant/app_colors.dart';
import 'package:provider_todo/features/todo/domain/entities/todo_entity.dart';
import 'package:provider_todo/features/todo/presentation/provider/todos_provider.dart';

class CompletedTodosPage extends StatelessWidget {
  const CompletedTodosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final completedTodos = context.watch<TodosProvider>().completedTodos;

    if (completedTodos.isEmpty) {
      return const _EmptyCompleted();
    }

    return ListView.separated(
      padding: EdgeInsets.only(top: 8.h, bottom: 100.h),
      physics: const BouncingScrollPhysics(),
      itemCount: completedTodos.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: const Color(0xFFEEF0F4),
        indent: 20.w,
        endIndent: 20.w,
      ),
      itemBuilder: (context, index) {
        final todo = completedTodos[index];
        return _CompletedItem(key: ValueKey(todo.id), todo: todo);
      },
    );
  }
}

// ── Completed item — matches Image 3 exactly ──────────────────
class _CompletedItem extends StatelessWidget {
  final TodoEntity todo;
  const _CompletedItem({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(todo.id),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        dismissible: DismissiblePane(
          onDismissed: () => _delete(context),
        ),
        children: [
          SlidableAction(
            onPressed: (_) => _delete(context),
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
            onPressed: (_) => _undo(context),
            backgroundColor: const Color(0xFFF59E0B),
            foregroundColor: Colors.white,
            icon: Icons.undo_rounded,
            label: 'Undo',
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.r),
              bottomLeft: Radius.circular(12.r),
            ),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => _undo(context),
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Row(
            children: [
              // ── Blue filled checkbox with checkmark ──────
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 16.w),

              // ── Title + completedAt ───────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Strikethrough title in blue
                    Text(
                      todo.title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryColor,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: AppColors.primaryColor,
                        decorationThickness: 1.5,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    // Completed at timestamp
                    Text(
                      _formatCompleted(todo.completedAt),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCompleted(DateTime? dt) {
    if (dt == null) return 'Completed';
    return 'Completed at ${DateFormat('dd/MM/yyyy HH:mm').format(dt)}';
  }

  void _undo(BuildContext context) {
    context.read<TodosProvider>().toggleTodo(todo.id);
  }

  void _delete(BuildContext context) {
    final provider = context.read<TodosProvider>();
    final snapshot = todo;
    provider.deleteTodo(todo.id);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
}

// ── Empty state for completed ──────────────────────────────────
class _EmptyCompleted extends StatelessWidget {
  const _EmptyCompleted();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72.r,
            height: 72.r,
            decoration: BoxDecoration(
              color: const Color(0xFFDEEAFF),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(
              Icons.done_all_rounded,
              size: 36.sp,
              color: const Color(0xFF93B4D4),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'No completed tasks',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF93B4D4),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Complete some tasks to see them here',
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFFB3C9E0),
            ),
          ),
        ],
      ),
    );
  }
}