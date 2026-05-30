import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../providers/gym_provider.dart';
import '../../../providers/score_provider.dart';
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

class _GymCalendarState extends State<GymCalendar>
    with SingleTickerProviderStateMixin {
  late DateTime _month;
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    final now  = DateTime.now();
    _month     = DateTime(now.year, now.month);
    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 260));
    _slideAnim = AlwaysStoppedAnimation(Offset.zero);
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    super.dispose();
  }

  Future<void> _navigate(bool goLeft) async {
    _slideAnim = Tween<Offset>(
      begin: Offset(goLeft ? 0.07 : -0.07, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
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

    final firstDay    = DateTime(_month.year, _month.month, 1);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final startOffset = firstDay.weekday % 7;

    final today = PulseDateUtils.today;
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
              Text(DateFormat('MMMM yyyy').format(_month),
                  style: GoogleFonts.dmSans(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: primary,
                  )),
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

          // Weekday headers
          Row(
            children: hdrs.map((h) => Expanded(
              child: Center(
                child: Text(h,
                    style: GoogleFonts.dmSans(
                      fontSize: 10, fontWeight: FontWeight.w600,
                      color: muted,
                    )),
              ),
            )).toList(),
          ),

          const SizedBox(height: 8),

          // Grid
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
                      primary, muted, surface, border),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: isToday
                          ? Border.all(color: primary, width: 1.2)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('$day',
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: isToday
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: isFuture
                                  ? muted.withOpacity(0.30)
                                  : primary,
                            )),
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
    final record = context.read<ScoreProvider>().recordFor(dateKey);

    final moodRating        = record?.userRating ?? 0;
    final disciplinePercent = record != null
        ? (record.disciplineScore * 100).toInt()
        : null;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _GymDaySheet(
        date: date,
        log: log,
        moodRating: moodRating,
        disciplinePercent: disciplinePercent,
        primary: primary,
        muted: muted,
        bg: bg,
        border: border,
        surface: surface,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Gym day sheet
// Fixed top, scrollable body, compact exercise rows
// ─────────────────────────────────────────────────────────────
class _GymDaySheet extends StatelessWidget {
  final DateTime date;
  final dynamic log;
  final int moodRating;
  final int? disciplinePercent;
  final Color primary, muted, bg, border, surface;

  const _GymDaySheet({
    required this.date,
    required this.log,
    required this.moodRating,
    required this.disciplinePercent,
    required this.primary,
    required this.muted,
    required this.bg,
    required this.border,
    required this.surface,
  });

  @override
  Widget build(BuildContext context) {
    final exercises = log?.exercises as List? ?? [];
    final hasWorkout = exercises.isNotEmpty;

    // Format: "5 August" then "Monday" on next line
    final dateLine = DateFormat('d MMMM').format(date);
    final dayLine  = DateFormat('EEEE').format(date);

    return Container(
      // Fixed max height — always the same regardless of content
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.60,
      ),
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Fixed header — never scrolls ─────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 32, height: 3,
                    margin:
                        const EdgeInsets.only(top: 12, bottom: 18),
                    decoration: BoxDecoration(
                      color: border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Date: "5 August" big, "Monday" small below
                Text(dateLine,
                    style: GoogleFonts.dmSans(
                      fontSize: 20, fontWeight: FontWeight.w700,
                      color: primary, letterSpacing: -0.5,
                    )),
                const SizedBox(height: 2),
                Text(dayLine,
                    style: GoogleFonts.dmSans(
                      fontSize: 12, color: muted,
                    )),

                const SizedBox(height: 16),

                // Mood + Discipline row
                Row(
                  children: [
                    Expanded(
                      child: _Stat(
                        label: 'Mood',
                        value: moodRating > 0
                            ? '$moodRating/10'
                            : '—',
                        primary: primary, muted: muted,
                      ),
                    ),
                    Expanded(
                      child: _Stat(
                        label: 'Discipline',
                        value: disciplinePercent != null
                            ? '$disciplinePercent%'
                            : '—',
                        primary: primary, muted: muted,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                Container(height: 0.5, color: border),
                const SizedBox(height: 4),
              ],
            ),
          ),

          // ── Scrollable body ──────────────────────────────
          Flexible(
            child: !hasWorkout
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('No workout logged.',
                          style: GoogleFonts.dmSans(
                              fontSize: 13, color: muted)),
                    ),
                  )
                : ListView(
                    padding:
                        const EdgeInsets.fromLTRB(24, 12, 24, 28),
                    children: exercises.map<Widget>((ex) {
                      final sets   = ex.sets as List;
                      final name   = ex.name as String;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            // Exercise name
                            Text(name,
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: primary,
                                )),
                            const SizedBox(height: 5),

                            if (sets.isEmpty)
                              Text('No sets logged.',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 11, color: muted))
                            else
                              // Compact set rows
                              ...sets.asMap().entries.map<Widget>((e) {
                                final idx  = e.key + 1;
                                final s    = e.value;
                                final w    = s.weight as double;
                                final r    = s.reps as int;
                                final wStr = w % 1 == 0
                                    ? '${w.toInt()}kg'
                                    : '${w}kg';

                                return Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 4),
                                  child: Row(
                                    children: [
                                      // Set number
                                      SizedBox(
                                        width: 20,
                                        child: Text('$idx',
                                            style: GoogleFonts.dmSans(
                                              fontSize: 11,
                                              color: muted,
                                            )),
                                      ),
                                      // Weight
                                      Text(wStr,
                                          style: GoogleFonts.dmSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: primary,
                                          )),
                                      const SizedBox(width: 6),
                                      Text('·',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 12, color: muted,
                                          )),
                                      const SizedBox(width: 6),
                                      // Reps
                                      Text('$r reps',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 12, color: muted,
                                          )),
                                    ],
                                  ),
                                );
                              }),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  final Color primary, muted;
  const _Stat({
    required this.label, required this.value,
    required this.primary, required this.muted,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: GoogleFonts.dmSans(
              fontSize: 9, fontWeight: FontWeight.w600,
              color: muted, letterSpacing: 1.4,
            )),
        const SizedBox(height: 3),
        Text(value,
            style: GoogleFonts.dmSans(
              fontSize: 15, fontWeight: FontWeight.w700,
              color: primary,
            )),
      ],
    );
  }
}