import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_todo/core/shared/widgets/app_snackbar.dart';
import 'package:provider_todo/features/auth/presentation/provider/auth_provider.dart';
import 'package:provider_todo/features/todo/presentation/pages/complete_todo.dart';
import 'package:provider_todo/features/todo/presentation/pages/profile.dart';
import 'package:provider_todo/features/todo/presentation/provider/todos_provider.dart';
import 'package:provider_todo/features/todo/presentation/widgets/add_todo_dialog.dart';
import 'package:provider_todo/features/todo/presentation/widgets/todo_list.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  // _currentIndex is LOCAL UI state → setState is correct here
  int _currentIndex = 0;
  late final PageController _pageController;

  late final AuthProvider _authProvider;
  bool _successShown = false;

  late final TodosProvider _todosProvider;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _authProvider = context.read<AuthProvider>();
    _authProvider.addListener(_onAuthChanged);

    // ✅ Listen to todos errors
    _todosProvider = context.read<TodosProvider>();
    _todosProvider.addListener(_onTodosChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _todosProvider.loadTodos();
      _checkShowWelcome();
    });
  }

  void _checkShowWelcome() {
    if (_successShown) return;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final provider = user.appMetadata['provider'] ?? '';
    final isOAuth = ['google', 'github', 'facebook'].contains(provider);

    if (isOAuth) {
      _successShown = true;
      AppSnackbar().successSnackbar(
        context: context,
        message:
            'Welcome,  ${user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? user.email ?? 'User'}🎉',
      );
    }
  }

  void _onAuthChanged() {
    if (!mounted) return;
    if (_authProvider.status == AuthStatus.error) {
      AppSnackbar().errorSnackBar(
        message: _authProvider.errorMessage ?? 'Something went wrong',
        context: context,
      );
    }
  }

  void _onTodosChanged() {
    if (!mounted) return;
    if (_todosProvider.status == TodoStatus.error &&
        _todosProvider.errorMessage != null) {
      AppSnackbar().errorSnackBar(
        message: _todosProvider.errorMessage ?? 'Todo operation failed',
        context: context,
      );
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthChanged);
    _todosProvider.removeListener(_onTodosChanged); // ✅ cleanup
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TodosProvider>();
    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            _currentIndex == 0 ? 'My Todos' : 'Completed',
            key: ValueKey(_currentIndex),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  _currentIndex == 0
                      ? '${provider.todos.length} remaining'
                      : '${provider.completedTodos.length} done',
                  key: ValueKey(_currentIndex),
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: const [TodoList(), CompletedTodosPage(), Profile()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.white.withValues(alpha: 0.6),
        selectedItemColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: _BadgedIcon(
              icon: Icons.fact_check_outlined,
              count: provider.todos.length,
              primaryColor: Theme.of(context).primaryColor,
            ),
            label: 'Todos',
          ),
          BottomNavigationBarItem(
            icon: _BadgedIcon(
              icon: Icons.done_all_rounded,
              count: provider.completedTodos.length,
              primaryColor: Theme.of(context).primaryColor,
            ),
            label: 'Completed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Theme.of(context).primaryColor),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: AnimatedSlide(
        offset: _currentIndex == 0 ? Offset.zero : const Offset(0, 2),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          opacity: _currentIndex == 0 ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: FloatingActionButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.black,
            onPressed: _currentIndex != 0
                ? null
                : () => showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const AddTodoDialog(),
                  ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// Small reusable badge widget for nav icons
class _BadgedIcon extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color primaryColor;

  const _BadgedIcon({
    required this.icon,
    required this.count,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (count > 0)
          Positioned(
            right: -6,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 9,
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
