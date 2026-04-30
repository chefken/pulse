import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../providers/gym_provider.dart';
import '../../../providers/workout_provider.dart';

class GymCalendar extends StatefulWidget {
  final GymProvider gymProvider;
  final WorkoutProvider workoutProvider;

  const GymCalendar({
    super.key,
    required this.gymProvider,
    required this.workoutProvider,
  });

  @override
  State<GymCalendar> createState() => _GymCalendarState();
}

class _GymCalendarState extends State<GymCalendar> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  void _prev() =>
      setState(() => _month = DateTime(_month.year, _month.month - 1));

  void _next() {
    final now  = DateTime.now();
    final next = DateTime(_month.year, _month.month + 1);
    if (!next.isAfter(DateTime(now.year, now.month))) {
      setState(() => _month = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.textPrimary(context);
    final muted   = AppColors.textMuted(context);
    final surface = AppColors.surface(context);
    final border  = AppColors.border(context);
    final dot     = AppColors.dot(context);

    final firstDay    = DateTime(_month.year, _month.month, 1);
    final daysInMonth =
        DateTime(_month.year, _month.month + 1, 0).day;
    // weekday: Mon=1, startWd 0-indexed for grid offset
    final startOffset = firstDay.weekday - 1;

    final today = PulseDateUtils.today;
    const hdrs  = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Column(
        children: [
          // Month nav
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _prev,
                child: Icon(Icons.chevron_left_rounded,
                    size: 20, color: muted),
              ),
              Text(
                DateFormat('MMMM yyyy').format(_month),
                style: GoogleFonts.dmSans(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: primary,
                ),
              ),
              GestureDetector(
                onTap: _next,
                child: Icon(Icons.chevron_right_rounded,
                    size: 20, color: muted),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: hdrs.map((h) => SizedBox(
              width: 30,
              child: Text(h,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 10, fontWeight: FontWeight.w600,
                    color: muted,
                  )),
            )).toList(),
          ),

          const SizedBox(height: 8),

          // Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              childAspectRatio: 1,
            ),
            itemCount: startOffset + daysInMonth,
            itemBuilder: (_, idx) {
              if (idx < startOffset) return const SizedBox();

              final day  = idx - startOffset + 1;
              final date = DateTime(_month.year, _month.month, day);
              final key  = PulseDateUtils.formatDateKey(date);

              final isToday  = PulseDateUtils.isSameDay(date, today);
              final isFuture = date.isAfter(today);
              final done     = !isFuture &&
                  widget.gymProvider.sessionCompletedOn(date);
              final log      = widget.workoutProvider.logFor(key);
              final hasLog   = log != null && log.exercises.isNotEmpty;

              return GestureDetector(
                onTap: () => _showSheet(
                    context, date, log, primary, muted, surface, border),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: isToday
                        ? Border.all(color: primary, width: 1.2)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: isToday
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isFuture
                              ? muted.withOpacity(0.35)
                              : primary,
                        ),
                      ),
                      if (done || hasLog)
                        Container(
                          width: 4, height: 4,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, color: dot,
                          ),
                        )
                      else
                        const SizedBox(height: 6),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showSheet(BuildContext context, DateTime date,
      dynamic log, Color primary, Color muted,
      Color surface, Color border) {
    final bg = AppColors.bg(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: border, width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 32, height: 3,
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                decoration: BoxDecoration(
                  color: border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              DateFormat('d MMMM yyyy').format(date),
              style: GoogleFonts.dmSans(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: primary, letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 16),
            if (log == null || log.exercises.isEmpty)
              Text('No workout logged.',
                  style: GoogleFonts.dmSans(
                      fontSize: 14, color: muted))
            else
              ...log.exercises.map<Widget>(
                (ex) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ex.name,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: primary,
                          )),
                      const SizedBox(height: 3),
                      Text(
                        '${ex.sets.length} set${ex.sets.length != 1 ? 's' : ''}' +
                            (ex.maxWeight > 0
                                ? '  ·  up to ${ex.maxWeight % 1 == 0 ? ex.maxWeight.toInt() : ex.maxWeight}kg'
                                : ''),
                        style: GoogleFonts.dmSans(
                            fontSize: 12, color: muted),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}