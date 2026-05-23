// lib/features/todo/presentation/widgets/date_strip.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider_todo/core/constant/app_colors.dart';

class DateStrip extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const DateStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<DateStrip> createState() => _DateStripState();
}

class _DateStripState extends State<DateStrip> {
  late final ScrollController _scrollController;

  // Generate 90 days: 45 before today → 45 after today
  static const int _pastDays   = 45;
  static const int _futureDays = 45;
  static const int _total      = _pastDays + _futureDays + 1;

  final DateTime _origin = () {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }();

  late final List<DateTime> _dates;

  // Item dimensions
  double get _itemWidth  => 64.w;
  double get _itemHeight => 72.h;
  double get _spacing    => 8.w;

  @override
  void initState() {
    super.initState();
    _dates = List.generate(
      _total,
      (i) => _origin.subtract(Duration(days: _pastDays - i)),
    );
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void didUpdateWidget(DateStrip old) {
    super.didUpdateWidget(old);
    if (old.selectedDate != widget.selectedDate) {
      _scrollToSelected();
    }
  }

  void _scrollToSelected() {
    final index = _dates.indexWhere((d) =>
        d.year  == widget.selectedDate.year  &&
        d.month == widget.selectedDate.month &&
        d.day   == widget.selectedDate.day);
    if (index == -1) return;

    final itemTotal = _itemWidth + _spacing;
    final screenWidth = MediaQuery.of(context).size.width;
    // Center selected item
    final offset = (itemTotal * index) - (screenWidth / 2) + (itemTotal / 2);

    _scrollController.animateTo(
      offset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _isSelected(DateTime d) =>
      d.year  == widget.selectedDate.year  &&
      d.month == widget.selectedDate.month &&
      d.day   == widget.selectedDate.day;

  bool _isToday(DateTime d) {
    final n = DateTime.now();
    return d.year == n.year && d.month == n.month && d.day == n.day;
  }

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _itemHeight,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        physics: const BouncingScrollPhysics(),
        itemCount: _total,
        separatorBuilder: (_, __) => SizedBox(width: _spacing),
        itemBuilder: (context, index) {
          final date     = _dates[index];
          final selected = _isSelected(date);
          final today    = _isToday(date);

          return GestureDetector(
            onTap: () => widget.onDateSelected(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _itemWidth,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primaryColor
                    : const Color(0xFFDEEAFF),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Day name
                  Text(
                    _days[date.weekday - 1],
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: selected
                          ? Colors.white.withValues(alpha: 0.85)
                          : const Color(0xFF7AAFD4),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  // Date number
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: selected
                          ? Colors.white
                          : today
                              ? AppColors.primaryColor
                              : const Color(0xFF3A5A8C),
                    ),
                  ),
                  // Today dot
                  if (today && !selected)
                    Container(
                      width: 5.r,
                      height: 5.r,
                      margin: EdgeInsets.only(top: 3.h),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}