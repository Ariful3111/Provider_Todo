// lib/features/todo/presentation/widgets/date_strip.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider_todo/core/constant/app_colors.dart';
import 'package:provider_todo/core/shared/widgets/app_text.dart';

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
  late final ScrollController _sc;

  // 45 days before → 45 days after today = 91 total
  static const _past = 45;
  static const _future = 45;
  static const _total = _past + _future + 1;

  static DateTime get _todayMidnight {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  late final List<DateTime> _dates;

  // Item layout
  double get _w => 62.w;
  double get _h => 74.h;
  double get _gap => 8.w;

  @override
  void initState() {
    super.initState();
    final origin = _todayMidnight;
    _dates = List.generate(
      _total,
      (i) => origin.subtract(Duration(days: _past - i)),
    );
    _sc = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollTo(widget.selectedDate),
    );
  }

  @override
  void didUpdateWidget(DateStrip old) {
    super.didUpdateWidget(old);
    if (!_sameDay(old.selectedDate, widget.selectedDate)) {
      _scrollTo(widget.selectedDate);
    }
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _scrollTo(DateTime target) {
    final idx = _dates.indexWhere((d) => _sameDay(d, target));
    if (idx == -1) return;
    if (!_sc.hasClients) return;

    final screenW = MediaQuery.of(context).size.width;
    final itemFull = _w + _gap;
    final offset = (itemFull * idx) - (screenW - itemFull) / 2;

    _sc.animateTo(
      offset.clamp(0.0, _sc.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  static const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _h,
      child: ListView.separated(
        controller: _sc,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        physics: const BouncingScrollPhysics(),
        itemCount: _total,
        separatorBuilder: (_, __) => SizedBox(width: _gap),
        itemBuilder: (context, i) {
          final date = _dates[i];
          final selected = _sameDay(date, widget.selectedDate);
          final isToday = _sameDay(date, _todayMidnight);

          return GestureDetector(
            onTap: () => widget.onDateSelected(date),
            child: AnimatedContainer(
              padding: EdgeInsets.zero,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              width: _w,
              decoration: BoxDecoration(
                color: selected ? AppColors.primaryColor : Color(0xFFEEF5FF),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.all(10.r),
                    child: AppText(
                      _dayNames[date.weekday - 1],
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: selected
                          ? AppColors.whiteColor
                          : Color(0xFF76B5FF),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.all(10.r),
                    width: MediaQuery.widthOf(context),
                    decoration: BoxDecoration(
                      color: selected ? Color(0xFF318FFF) : Color(0xFFDDECFF),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.r),
                        topRight: Radius.circular(10.r),
                      ),
                    ),
                    child: Center(
                      child: AppText(
                        '${date.day}',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: selected
                            ? Colors.white
                            : isToday
                            ? AppColors.primaryColor
                            : Color(0xFF3A5A8C),
                      ),
                    ),
                  ),

                  // Dot under today (when not selected)
                  // SizedBox(height: 4.h),
                  // AnimatedOpacity(
                  //   duration: const Duration(milliseconds: 200),
                  //   opacity: isToday && !selected ? 1.0 : 0.0,
                  //   child: Container(
                  //     width: 5.r,
                  //     height: 5.r,
                  //     decoration: const BoxDecoration(
                  //       color: AppColors.primaryColor,
                  //       shape: BoxShape.circle,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
