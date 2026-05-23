// lib/features/todo/presentation/pages/todo_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:provider_todo/core/constant/app_colors.dart';
import 'package:provider_todo/features/todo/presentation/provider/todos_provider.dart';
import 'package:provider_todo/features/todo/presentation/widgets/todo_item.dart';

class TodoList extends StatelessWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context) {
    final todos = context.watch<TodosProvider>().todos;

    if (todos.isEmpty) return const _EmptyState();

    return ListView.separated(
      padding: EdgeInsets.only(top: 8.h, bottom: 100.h),
      physics: const BouncingScrollPhysics(),
      itemCount: todos.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: const Color(0xFFEEF0F4),
        indent: 20.w,
        endIndent: 20.w,
      ),
      itemBuilder: (context, index) {
        final todo = todos[index];
        return TodoItem(key: ValueKey(todo.id), todoEntity: todo);
      },
    );
  }
}

// ── Empty state ───────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ Asset image — add your image at assets/images/no_todos.png
          // Falls back to icon if asset not found
          _NoTodosImage(),
          SizedBox(height: 20.h),
          Text(
            'No to-dos',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF93B4D4),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoTodosImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/no_todos.png',
      width: 80.w,
      height: 80.w,
      color: const Color(0xFFB8D4EF),
      errorBuilder: (_, __, ___) => _FallbackIcon(),
    );
  }
}

class _FallbackIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(72.r, 72.r),
      painter: _CheckCirclePainter(),
    );
  }
}

// Draws the circular checkmark icon from the design
class _CheckCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const color = Color(0xFFB8D4EF);
    final strokeW = size.width * 0.08;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeW / 2;

    // Circle (not full — open on top right like the design)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0.6,   // start angle (radians)
      5.0,   // sweep angle (almost full circle)
      false,
      paint,
    );

    // Checkmark
    final cx = size.width / 2;
    final cy = size.height / 2;
    final checkPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(cx - size.width * 0.18, cy + size.height * 0.02)
      ..lineTo(cx - size.width * 0.04, cy + size.height * 0.17)
      ..lineTo(cx + size.width * 0.22, cy - size.height * 0.12);

    canvas.drawPath(path, checkPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}