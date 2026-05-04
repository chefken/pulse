import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../providers/gym_provider.dart';
import '../../../providers/score_provider.dart';
import '../../../providers/task_provider.dart';
import '../../../providers/workout_provider.dart';

class WeekTracker extends StatelessWidget {
  final ScoreProvider score;
  final TaskProvider tasks;

  const WeekTracker({super.key, required this.score, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.textPrimary(context);
    final muted   = AppColors.textMuted(context);
    final surface = AppColors.surface(context);
    final border  = AppColors.border(context);

    // Sunday-first labels
    const labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    final today = PulseDateUtils.today;
    // Flutter weekday: Mon=1…Sun=7
    // Sun-first index: Sun=0, Mon=1…Sat=6  →  weekday % 7
    final todayIndex    = today.weekday % 7;
    final daysSinceSun  = today.weekday % 7;
    final sunday        = today.subtract(Duration(days: daysSinceSun));

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
              Text('This week',
                  style: GoogleFonts.dmSans(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: muted, letterSpacing: 0.4,
                  )),
              Text(DateFormat('MMM yyyy').format(today),
                  style:
                      GoogleFonts.dmSans(fontSize: 10, color: muted)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              // index 0 = Sunday, index 6 = Saturday
              final dayDate  = sunday.add(Duration(days: index));
              final dateKey  = DateFormat('yyyy-MM-dd').format(dayDate);
              final isToday  = index == todayIndex;
              final isFuture = dayDate.isAfter(today);
              final record   = score.recordFor(dateKey);
              final isGood   = !isFuture && (record?.isGoodDay ?? false);

              return GestureDetector(
                onTap: () => _showSheet(
                  context, dayDate, dateKey, record,
                  primary, muted, surface, border,
                ),
                child: SizedBox(
                  width: 34,
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 280),
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
                                    ? primary.withOpacity(0.28)
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
                                        color:
                                            muted.withOpacity(0.38),
                                      ),
                                    ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(labels[index],
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: isToday
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isToday ? primary : muted,
                          )),
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
    final bg          = AppColors.bg(context);
    final gym         = context.read<GymProvider>();
    final workout     = context.read<WorkoutProvider>();
    final workoutDone = gym.sessionCompletedOn(date);
    final log         = workout.logFor(dateKey);

    final moodRating  = record?.userRating ?? 0;
    final habitTitles =
        (record?.completedHabitTitles as List<String>?) ?? <String>[];
    final taskTitles  =
        (record?.completedTaskTitles  as List<String>?) ?? <String>[];

    // Sun-first day labels
    const days = [
      'SUNDAY','MONDAY','TUESDAY','WEDNESDAY',
      'THURSDAY','FRIDAY','SATURDAY',
    ];
    final dayLabel = days[date.weekday % 7];

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
                margin: const EdgeInsets.only(top: 12, bottom: 22),
                decoration: BoxDecoration(
                  color: border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Text(dayLabel,
                style: GoogleFonts.dmSans(
                  fontSize: 10, fontWeight: FontWeight.w600,
                  color: muted, letterSpacing: 1.2,
                )),
            const SizedBox(height: 3),
            Text(
              DateFormat('d MMMM yyyy').format(date),
              style: GoogleFonts.dmSans(
                fontSize: 18, fontWeight: FontWeight.w700,
                color: primary, letterSpacing: -0.4,
              ),
            ),

            const SizedBox(height: 20),

            if (moodRating == 0 &&
                habitTitles.isEmpty &&
                taskTitles.isEmpty &&
                !workoutDone &&
                (log == null || log.exercises.isEmpty))
              Text('No activity logged.',
                  style: GoogleFonts.dmSans(
                      fontSize: 14, color: muted))
            else ...[
              if (moodRating > 0) ...[
                _SheetRow('Mood', '$moodRating / 10',
                    primary, muted),
                const SizedBox(height: 12),
              ],
              if (habitTitles.isNotEmpty) ...[
                _SheetLabel('Habits', muted),
                const SizedBox(height: 6),
                ...habitTitles.map(
                    (h) => _SheetBullet(h, primary, muted)),
                const SizedBox(height: 10),
              ],
              if (taskTitles.isNotEmpty) ...[
                _SheetLabel('Tasks', muted),
                const SizedBox(height: 6),
                ...taskTitles.map(
                    (t) => _SheetBullet(t, primary, muted)),
                const SizedBox(height: 10),
              ],
              if (workoutDone ||
                  (log != null && log.exercises.isNotEmpty)) ...[
                _SheetLabel('Workout', muted),
                const SizedBox(height: 6),
                if (log != null && log.exercises.isNotEmpty)
                  ...log.exercises.map<Widget>((ex) => _SheetBullet(
                    '${ex.name} — ${ex.sets.length} set${ex.sets.length != 1 ? 's' : ''}',
                    primary, muted,
                  ))
                else
                  _SheetBullet('Completed', primary, muted),
              ],
            ],

            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  final String label, value;
  final Color primary, muted;
  const _SheetRow(this.label, this.value, this.primary, this.muted);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.dmSans(fontSize: 14, color: muted)),
        Text(value,
            style: GoogleFonts.dmSans(
              fontSize: 14, fontWeight: FontWeight.w600,
              color: primary,
            )),
      ],
    );
  }
}

class _SheetLabel extends StatelessWidget {
  final String text;
  final Color muted;
  const _SheetLabel(this.text, this.muted);

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(),
        style: GoogleFonts.dmSans(
          fontSize: 9, fontWeight: FontWeight.w700,
          color: muted, letterSpacing: 1.4,
        ));
  }
}

class _SheetBullet extends StatelessWidget {
  final String text;
  final Color primary, muted;
  const _SheetBullet(this.text, this.primary, this.muted);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5, right: 9),
            child: Container(
              width: 4, height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: muted.withOpacity(0.45),
              ),
            ),
          ),
          Expanded(
            child: Text(text,
                style: GoogleFonts.dmSans(
                    fontSize: 13, color: primary)),
          ),
        ],
      ),
    );
  }
}