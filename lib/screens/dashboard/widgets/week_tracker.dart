import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../providers/score_provider.dart';
import '../../../providers/task_provider.dart';
import '../../../providers/gym_provider.dart';

class WeekTracker extends StatelessWidget {
  final ScoreProvider score;
  final TaskProvider tasks;

  const WeekTracker({super.key, required this.score, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final primary  = AppColors.textPrimary(context);
    final muted    = AppColors.textMuted(context);
    final surface  = AppColors.surface(context);
    final border   = AppColors.border(context);

    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    final today      = PulseDateUtils.today;
    // todayIndex: Mon=0 … Sun=6
    final todayIndex = today.weekday - 1;
    // Monday of this week
    final monday     = today.subtract(Duration(days: todayIndex));

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'This week',
                style: GoogleFonts.dmSans(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: muted, letterSpacing: 0.4,
                ),
              ),
              Text(
                DateFormat('MMM yyyy').format(today),
                style: GoogleFonts.dmSans(
                  fontSize: 10, color: muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final dayDate  = monday.add(Duration(days: index));
              final dateKey  = DateFormat('yyyy-MM-dd').format(dayDate);
              final isToday  = index == todayIndex;
              final isFuture = dayDate.isAfter(today);
              final record   = score.recordFor(dateKey);
              final isGood   = !isFuture && (record?.isGoodDay ?? false);

              return GestureDetector(
                onTap: () => _showSheet(
                  context,
                  dayDate,
                  dateKey,
                  record,
                  primary,
                  muted,
                  surface,
                  border,
                ),
                child: SizedBox(
                  width: 34,
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isGood
                              ? primary.withOpacity(0.10)
                              : Colors.transparent,
                          border: Border.all(
                            color: isToday
                                ? primary
                                : isGood
                                    ? primary.withOpacity(0.30)
                                    : border,
                            width: isToday ? 1.5 : 0.7,
                          ),
                        ),
                        child: Center(
                          child: isGood
                              ? Icon(Icons.check_rounded,
                                  size: 14, color: primary)
                              : isFuture
                                  ? const SizedBox()
                                  : Container(
                                      width: 4, height: 4,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: muted.withOpacity(0.4),
                                      ),
                                    ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        labels[index],
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: isToday
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isToday ? primary : muted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showSheet(
    BuildContext context,
    DateTime date,
    String dateKey,
    dynamic record,
    Color primary,
    Color muted,
    Color surface,
    Color border,
  ) {
    final gym = context.read<GymProvider>();
    final workoutDone = gym.sessionCompletedOn(date);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DaySheet(
        date: date,
        dateKey: dateKey,
        record: record,
        workoutDone: workoutDone,
        primary: primary,
        muted: muted,
        surface: surface,
        border: border,
        bg: AppColors.bg(context),
      ),
    );
  }
}

class _DaySheet extends StatelessWidget {
  final DateTime date;
  final String dateKey;
  final dynamic record;
  final bool workoutDone;
  final Color primary, muted, surface, border, bg;

  const _DaySheet({
    required this.date,
    required this.dateKey,
    required this.record,
    required this.workoutDone,
    required this.primary,
    required this.muted,
    required this.surface,
    required this.border,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = record != null &&
        (record.totalTasks > 0 || record.completedTasks > 0);

    final habitTitles = record?.completedHabitTitles as List<String>? ?? [];
    final taskTitles  = record?.completedTaskTitles  as List<String>? ?? [];

    const days = [
      'MONDAY','TUESDAY','WEDNESDAY','THURSDAY',
      'FRIDAY','SATURDAY','SUNDAY',
    ];

    return Container(
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
              margin: const EdgeInsets.only(top: 12, bottom: 22),
              decoration: BoxDecoration(
                color: border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Text(
            days[date.weekday - 1],
            style: GoogleFonts.dmSans(
              fontSize: 10, fontWeight: FontWeight.w600,
              color: muted, letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            DateFormat('d MMMM yyyy').format(date),
            style: GoogleFonts.dmSans(
              fontSize: 18, fontWeight: FontWeight.w700,
              color: primary, letterSpacing: -0.4,
            ),
          ),

          const SizedBox(height: 22),

          if (!hasData && !workoutDone)
            Text(
              'No activity logged.',
              style: GoogleFonts.dmSans(fontSize: 14, color: muted),
            )
          else ...[
            if (hasData) ...[
              _Row('Score',
                  '${(record.disciplineScore * 100).toInt()}%',
                  primary, muted),
              const SizedBox(height: 10),
              _Row('Tasks done',
                  '${record.completedTasks} of ${record.totalTasks}',
                  primary, muted),
            ],
            if (habitTitles.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text('Habits completed',
                  style: GoogleFonts.dmSans(
                    fontSize: 10, fontWeight: FontWeight.w600,
                    color: muted, letterSpacing: 0.8,
                  )),
              const SizedBox(height: 8),
              ...habitTitles.map((h) => _BulletItem(h, primary, muted)),
            ],
            if (taskTitles.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text('Tasks completed',
                  style: GoogleFonts.dmSans(
                    fontSize: 10, fontWeight: FontWeight.w600,
                    color: muted, letterSpacing: 0.8,
                  )),
              const SizedBox(height: 8),
              ...taskTitles.map((t) => _BulletItem(t, primary, muted)),
            ],
            if (workoutDone) ...[
              const SizedBox(height: 14),
              _Row('Workout', 'Completed', primary, muted),
            ],
          ],

          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label, value;
  final Color primary, muted;
  const _Row(this.label, this.value, this.primary, this.muted);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.dmSans(fontSize: 14, color: muted)),
        Text(value, style: GoogleFonts.dmSans(
          fontSize: 14, fontWeight: FontWeight.w600, color: primary,
        )),
      ],
    );
  }
}

class _BulletItem extends StatelessWidget {
  final String text;
  final Color primary, muted;
  const _BulletItem(this.text, this.primary, this.muted);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Container(
            width: 5, height: 5, margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: muted.withOpacity(0.6),
            ),
          ),
          Expanded(child: Text(text,
              style: GoogleFonts.dmSans(fontSize: 13, color: primary))),
        ],
      ),
    );
  }
}