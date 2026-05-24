// lib/features/todo/presentation/pages/todo_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:provider_todo/features/todo/presentation/provider/todos_provider.dart';
import 'package:provider_todo/features/todo/presentation/widgets/todo_item.dart';

class TodoList extends StatelessWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context) {
    final todos = context.watch<TodosProvider>().todos;

    if (todos.isEmpty) return const _EmptyState();

    return ListView.separated(
      padding: EdgeInsets.only(top: 0, bottom: 100.h),
      physics: const BouncingScrollPhysics(),
      itemCount: todos.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: const Color(0xFFEEF2F8),
        indent: 72.w, // ✅ starts after checkbox — matches design
        endIndent: 0,
      ),
      itemBuilder: (context, index) {
        final todo = todos[index];
        return TodoItem(key: ValueKey(todo.id), todoEntity: todo);
      },
    );
  }
}

// ── Empty state — pixel perfect match to Image 1 ──────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ Asset image with custom painter fallback
          _NoTodosImage(),
          SizedBox(height: 16.h),
          Text(
            'No to-dos',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF93B4D4),
              letterSpacing: 0.2,
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
    // Try asset first — place your image at assets/images/no_todos.png
    return Image.asset(
      'assets/images/no_todos.png',
      width: 80.w,
      height: 80.w,
      color: const Color(0xFFB8D4EF),
      colorBlendMode: BlendMode.srcIn,
      errorBuilder: (_, __, ___) => _CheckCircleIcon(),
    );
  }
}

// ── Circular checkmark icon — matches Image 1 exactly ─────────
class _CheckCircleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(80.r, 80.r), painter: _CheckCirclePainter());
  }
}

class _CheckCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const color = Color(0xFFB8D4EF);
    final strokeW = size.width * 0.075;

    final circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeW / 2;

    // ✅ Almost full circle — open gap at top right (matches design)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.4, // start: slightly before top
      5.8, // sweep: almost full circle (2π ≈ 6.28)
      false,
      circlePaint,
    );

    // ✅ Checkmark inside the circle
    final checkPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    final path = Path()
      ..moveTo(cx - size.width * 0.20, cy + size.height * 0.02)
      ..lineTo(cx - size.width * 0.04, cy + size.height * 0.18)
      ..lineTo(cx + size.width * 0.22, cy - size.height * 0.14);

    canvas.drawPath(path, checkPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}
