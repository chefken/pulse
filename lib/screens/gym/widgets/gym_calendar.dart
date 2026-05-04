import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../providers/gym_provider.dart';
import '../../../providers/workout_provider.dart';
import '../../../providers/score_provider.dart';

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

class _GymCalendarState extends State<GymCalendar>
    with SingleTickerProviderStateMixin {
  late DateTime _month;
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;
  bool _slidingLeft = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 280));
    _slideAnim = Tween<Offset>(begin: Offset.zero, end: Offset.zero)
        .animate(_slideCtrl);
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    super.dispose();
  }

  Future<void> _navigate(bool goLeft) async {
    _slidingLeft = goLeft;
    final begin = Offset(goLeft ? 0.08 : -0.08, 0);
    _slideAnim  = Tween<Offset>(begin: begin, end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _slideCtrl, curve: Curves.easeOutCubic));
    setState(() {
      _month = goLeft
          ? DateTime(_month.year, _month.month - 1)
          : DateTime(_month.year, _month.month + 1);
    });
    _slideCtrl.forward(from: 0);
  }

  void _prev() => _navigate(true);

  void _next() {
    final now  = DateTime.now();
    final next = DateTime(_month.year, _month.month + 1);
    if (!next.isAfter(DateTime(now.year, now.month))) _navigate(false);
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.textPrimary(context);
    final muted   = AppColors.textMuted(context);
    final surface = AppColors.surface(context);
    final border  = AppColors.border(context);
    final dot     = AppColors.dot(context);

    // Sun-first: 0=Sun, 1=Mon … 6=Sat
    // Flutter weekday: Mon=1 … Sun=7
    // To convert Flutter weekday to Sun-first index:
    //   index = weekday % 7   (Sun=7→0, Mon=1→1 … Sat=6→6)
    final firstDay    = DateTime(_month.year, _month.month, 1);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    // Sun-first offset for first day of month
    final startOffset = firstDay.weekday % 7; // Sun=0, Mon=1 … Sat=6

    final today = PulseDateUtils.today;
    // Sun-first headers
    const hdrs  = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
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
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.chevron_left_rounded,
                      size: 20, color: muted),
                ),
              ),
              Text(
                DateFormat('MMMM yyyy').format(_month),
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: primary,
                ),
              ),
              GestureDetector(
                onTap: _next,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.chevron_right_rounded,
                      size: 20, color: muted),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Weekday headers (Sun first)
          Row(
            children: hdrs.map((h) => Expanded(
              child: Center(
                child: Text(h,
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: muted,
                    )),
              ),
            )).toList(),
          ),

          const SizedBox(height: 8),

          // Calendar grid with slide animation
          SlideTransition(
            position: _slideAnim,
            child: GridView.builder(
              key: ValueKey(_month),
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
                    context, date, key, log,
                    primary, muted, surface, border,
                  ),
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
                                ? muted.withOpacity(0.30)
                                : primary,
                          ),
                        ),
                        if (done || hasLog)
                          Container(
                            width: 4, height: 4,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: dot,
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
          ),
        ],
      ),
    );
  }

  void _showSheet(
    BuildContext context,
    DateTime date,
    String dateKey,
    dynamic log,
    Color primary,
    Color muted,
    Color surface,
    Color border,
  ) {
    final bg     = AppColors.bg(context);
    final score  = context
        .read<ScoreProvider>()
        .recordFor(dateKey);

    // Friendly names from ScoreProvider
    final moodRating    = score?.userRating ?? 0;
    final habitTitles   = score?.completedHabitTitles ?? <String>[];
    final taskTitles    = score?.completedTaskTitles  ?? <String>[];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: border, width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
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

            // Date
            Text(
              DateFormat('EEEE, d MMMM').format(date),
              style: GoogleFonts.dmSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: primary,
                letterSpacing: -0.4,
              ),
            ),

            const SizedBox(height: 20),

            // Mood
            if (moodRating > 0) ...[
              _SheetRow('Mood', '$moodRating / 10', primary, muted),
              const SizedBox(height: 12),
            ],

            // Habits
            if (habitTitles.isNotEmpty) ...[
              _SheetLabel('Habits', muted),
              const SizedBox(height: 6),
              ...habitTitles.map((h) => _Bullet(h, primary, muted)),
              const SizedBox(height: 12),
            ],

            // Tasks
            if (taskTitles.isNotEmpty) ...[
              _SheetLabel('Tasks', muted),
              const SizedBox(height: 6),
              ...taskTitles.map((t) => _Bullet(t, primary, muted)),
              const SizedBox(height: 12),
            ],

            // Workout
            if (log != null && log.exercises.isNotEmpty) ...[
              _SheetLabel('Workout', muted),
              const SizedBox(height: 6),
              ...log.exercises.map<Widget>((ex) => _Bullet(
                '${ex.name} — ${ex.sets.length} set${ex.sets.length != 1 ? 's' : ''}',
                primary,
                muted,
              )),
            ],

            // Nothing logged
            if (moodRating == 0 &&
                habitTitles.isEmpty &&
                taskTitles.isEmpty &&
                (log == null || log.exercises.isEmpty))
              Text(
                'Nothing logged for this day.',
                style: GoogleFonts.dmSans(
                    fontSize: 14, color: muted),
              ),

            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Sheet helper widgets
// ─────────────────────────────────────────────────────────────
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
              fontSize: 14,
              fontWeight: FontWeight.w600,
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
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.dmSans(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        color: muted,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  final Color primary, muted;
  const _Bullet(this.text, this.primary, this.muted);

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
                color: muted.withOpacity(0.5),
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

