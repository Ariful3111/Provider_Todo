// lib/features/todo/presentation/pages/homepage.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:provider_todo/core/constant/app_colors.dart';
import 'package:provider_todo/core/constant/icons_path.dart';
import 'package:provider_todo/features/auth/presentation/provider/auth_provider.dart';
import 'package:provider_todo/features/todo/presentation/pages/complete_todo.dart';
import 'package:provider_todo/features/todo/presentation/provider/todos_provider.dart';
import 'package:provider_todo/features/profile/presentation/pages/profile_page.dart';
import 'package:provider_todo/features/todo/presentation/widgets/date_stripe.dart';
import 'package:provider_todo/features/todo/presentation/widgets/todo_list.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _currentIndex = 0;
  late final PageController _pageController;

  // ── Auth listener for error snackbars ────────────────────
  late final AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _authProvider = context.read<AuthProvider>();
    _authProvider.addListener(_onAuthChanged);

    // Load todos when homepage first appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodosProvider>().loadTodos();
    });
  }

  void _onAuthChanged() {
    if (!mounted) return;
    if (_authProvider.status == AuthStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_authProvider.errorMessage ?? 'Something went wrong'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final todos = context.watch<TodosProvider>();

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(currentTabIndex: _currentIndex),
            SizedBox(height: 16.h),
            if (_currentIndex != 2) ...[
              DateStrip(
                selectedDate: todos.selectedDate,
                onDateSelected: (date) =>
                    context.read<TodosProvider>().selectDate(date),
              ),
              SizedBox(height: 12.h),
            ],
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.r),
                    topRight: Radius.circular(24.r),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _currentIndex = i),
                  children: const [
                    TodoList(),
                    CompletedTodosPage(),
                    ProfilePage(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Bottom Navigation ──────────────────────────────────
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        activeTodoCount: todos.allActiveTodos.length,
        completedTodoCount: todos.allCompletedTodos.length,
      ),

      // ── FAB — only on todos tab ────────────────────────────
      floatingActionButton: _currentIndex == 0
          ? _AddFab(onTap: _showAddDialog)
          : null,
    );
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddTodoSheet(),
    );
  }
}

// ── Header ────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final int currentTabIndex;
  const _Header({required this.currentTabIndex});

  String _title(TodosProvider todos) {
    if (currentTabIndex == 2) return 'Profile';
    if (currentTabIndex == 1) return 'Completed';

    final now = DateTime.now();
    final sel = todos.selectedDate;
    final isToday =
        sel.year == now.year && sel.month == now.month && sel.day == now.day;
    if (isToday) return 'Today';
    return DateFormat('EEE, d MMM').format(sel);
  }

  @override
  Widget build(BuildContext context) {
    final todos = context.watch<TodosProvider>();

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      child: Row(
        children: [
          // ── Calendar icon ─────────────────────────────────
          Image.asset(IconsPath.calender, height: 24.h, width: 24.w),
          SizedBox(width: 12.w),

          // ── Title ─────────────────────────────────────────
          AnimatedSwitcher(
            duration: Duration(milliseconds: 200),
            child: Text(
              _title(todos),
              key: ValueKey(_title(todos)),
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom Navigation ──────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;
  final int activeTodoCount;
  final int completedTodoCount;
  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.activeTodoCount,
    required this.completedTodoCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            children: [
              _NavItem(
                icon: Icons.check_circle_outline_rounded,
                activeIcon: Icons.check_circle_rounded,
                label: 'Todos',
                count: activeTodoCount,
                selected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.done_all_outlined,
                activeIcon: Icons.done_all_rounded,
                label: 'Completed',
                count: completedTodoCount,
                selected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profile',
                count: 0,
                selected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primaryColor : const Color(0xFFB0BEC5);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge + icon
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    selected ? activeIcon : icon,
                    key: ValueKey(selected),
                    size: 26.sp,
                    color: color,
                  ),
                ),
                if (count > 0)
                  Positioned(
                    right: -8.w,
                    top: -4.h,
                    child: Container(
                      padding: EdgeInsets.all(3.r),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Floating Action Button ─────────────────────────────────────
class _AddFab extends StatelessWidget {
  final VoidCallback onTap;
  const _AddFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56.r,
        height: 56.r,
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(Icons.add_rounded, color: Colors.white, size: 28.sp),
      ),
    );
  }
}

// ── Add Todo bottom sheet ──────────────────────────────────────
class _AddTodoSheet extends StatefulWidget {
  const _AddTodoSheet();

  @override
  State<_AddTodoSheet> createState() => _AddTodoSheetState();
}

class _AddTodoSheetState extends State<_AddTodoSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<TodosProvider>().addTodo(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 24.h + bottom),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 20.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFDEE2E6),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),

            Text(
              'New Task',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 20.h),

            // Title field
            _SheetTextField(
              controller: _titleCtrl,
              hint: 'Task title',
              icon: Icons.title_rounded,
              isDark: isDark,
              validator: (v) =>
                  (v?.trim().isEmpty ?? true) ? 'Title is required' : null,
            ),
            SizedBox(height: 12.h),

            // Description field
            _SheetTextField(
              controller: _descCtrl,
              hint: 'Description (optional)',
              icon: Icons.notes_rounded,
              isDark: isDark,
              maxLines: 3,
            ),
            SizedBox(height: 24.h),

            // Add button
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Add Task',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isDark;
  final int maxLines;
  final String? Function(String?)? validator;
  const _SheetTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.isDark,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(
        fontSize: 15.sp,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: const Color(0xFFB0BEC5), fontSize: 15.sp),
        prefixIcon: Icon(icon, color: AppColors.primaryColor, size: 20.sp),
        filled: true,
        fillColor: isDark ? AppColors.surfaceDark : const Color(0xFFF5F7FF),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}
