import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../models/gym_routine.dart';
import '../../providers/gym_provider.dart';
import '../../providers/workout_provider.dart';
import 'workout_detail_screen.dart';

class GymScreen extends StatelessWidget {
  const GymScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gym     = context.watch<GymProvider>();
    final workout = context.watch<WorkoutProvider>();
    final today   = gym.todayPlan;

    final bg        = AppColors.bg(context);
    final surface   = AppColors.surface(context);
    final border    = AppColors.border(context);
    final primary   = AppColors.textPrimary(context);
    final secondary = AppColors.textSecondary(context);
    final muted     = AppColors.textMuted(context);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [

            // ── Header ────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          PulseDateUtils.formatDate(
                                  DateTime.now())
                              .toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: muted,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Gym',
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => _showRoutineEditor(
                          context, gym, bg, surface, border,
                          primary, muted, secondary),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius:
                              BorderRadius.circular(20),
                          border: Border.all(color: border),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.edit_rounded,
                                size: 14, color: secondary),
                            const SizedBox(width: 6),
                            Text(
                              'Edit Split',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: secondary,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Today card ─────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _TodayCard(
                  plan: today,
                  workoutLog: workout.todayLog,
                  surface: surface,
                  border: border,
                  primary: primary,
                  muted: muted,
                  bg: bg,
                  onTap: today != null && !today.isRest
                      ? () => _openWorkout(
                          context, today, workout)
                      : null,
                ),
              ),
            ),

            // ── Consistency card ───────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: _ConsistencyCard(
                  last7: gym.last7Completions,
                  percent: gym.weeklyConsistency,
                  surface: surface,
                  border: border,
                  primary: primary,
                  muted: muted,
                ),
              ),
            ),

            const SliverToBoxAdapter(
                child: SizedBox(height: 28)),

            // ── Weekly split header ────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 4, height: 18,
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Weekly Split',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: primary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(
                child: SizedBox(height: 12)),

            // ── Split tiles ────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final day = gym.routine[i];
                    final todayWd = [
                      'Mon','Tue','Wed','Thu','Fri','Sat','Sun'
                    ][DateTime.now().weekday - 1];
                    final isToday = day.weekday == todayWd;
                    return _SplitTile(
                      day: day,
                      isToday: isToday,
                      surface: surface,
                      border: border,
                      primary: primary,
                      muted: muted,
                      secondary: secondary,
                      onTap: day.isRest
                          ? null
                          : () => _openWorkoutForDay(
                              context, day, workout),
                    );
                  },
                  childCount: gym.routine.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(
                child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  void _openWorkout(BuildContext context, GymDay plan,
      WorkoutProvider workout) async {
    final dateKey =
        PulseDateUtils.formatDateKey(PulseDateUtils.today);
    await workout.getOrCreate(
        dateKey: dateKey, muscleGroup: plan.muscleGroup);
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: workout,
          child: WorkoutDetailScreen(
            dateKey: dateKey,
            muscleGroup: plan.muscleGroup,
          ),
        ),
      ),
    );
  }

  void _openWorkoutForDay(BuildContext context, GymDay day,
      WorkoutProvider workout) {
    final now = DateTime.now();
    DateTime? targetDate;
    for (int i = 0; i < 7; i++) {
      final d = now.subtract(Duration(days: i));
      final wd =
          ['Mon','Tue','Wed','Thu','Fri','Sat','Sun']
              [d.weekday - 1];
      if (wd == day.weekday) {
        targetDate = d;
        break;
      }
    }
    final dateKey = PulseDateUtils.formatDateKey(
        targetDate ?? PulseDateUtils.today);
    workout
        .getOrCreate(
            dateKey: dateKey,
            muscleGroup: day.muscleGroup)
        .then((_) {
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: workout,
            child: WorkoutDetailScreen(
              dateKey: dateKey,
              muscleGroup: day.muscleGroup,
            ),
          ),
        ),
      );
    });
  }

  void _showRoutineEditor(
      BuildContext context,
      GymProvider gym,
      Color bg,
      Color surface,
      Color border,
      Color primary,
      Color muted,
      Color secondary) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: gym,
        child: _RoutineEditorSheet(
          bg: bg,
          surface: surface,
          border: border,
          primary: primary,
          muted: muted,
          secondary: secondary,
        ),
      ),
    );
  }
}

// ── Today Card ────────────────────────────────────────────────
class _TodayCard extends StatelessWidget {
  final GymDay? plan;
  final dynamic workoutLog;
  final Color surface, border, primary, muted, bg;
  final VoidCallback? onTap;

  const _TodayCard({
    this.plan,
    this.workoutLog,
    required this.surface,
    required this.border,
    required this.primary,
    required this.muted,
    required this.bg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRest      = plan?.isRest ?? true;
    final muscle      = plan?.muscleGroup ?? 'Rest Day';
    final isCompleted = workoutLog?.completed ?? false;
    final exCount     = workoutLog?.exercises.length ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: isCompleted
              ? AppColors.success.withOpacity(0.08)
              : surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isCompleted
                ? AppColors.success.withOpacity(0.35)
                : border,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "TODAY'S WORKOUT",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: muted,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isRest ? '😴  Rest Day' : muscle,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: isRest ? muted : primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (!isRest) ...[
                    const SizedBox(height: 6),
                    Text(
                      isCompleted
                          ? '✓  Workout complete'
                          : exCount > 0
                              ? '$exCount exercise${exCount > 1 ? 's' : ''} — tap to continue'
                              : 'Tap to start workout',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!isRest)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 46, height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? AppColors.success.withOpacity(0.15)
                      : primary.withOpacity(0.08),
                  border: Border.all(
                    color: isCompleted
                        ? AppColors.success.withOpacity(0.4)
                        : border,
                  ),
                ),
                child: Icon(
                  isCompleted
                      ? Icons.check_rounded
                      : Icons.arrow_forward_rounded,
                  color: isCompleted
                      ? AppColors.success
                      : primary,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Consistency Card ──────────────────────────────────────────
class _ConsistencyCard extends StatelessWidget {
  final List<bool> last7;
  final double percent;
  final Color surface, border, primary, muted;

  const _ConsistencyCard({
    required this.last7,
    required this.percent,
    required this.surface,
    required this.border,
    required this.primary,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final surfHigh = AppColors.surfaceHigh(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '7-DAY CONSISTENCY',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: muted,
                  letterSpacing: 0.6,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(percent * 100).toInt()}%',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: primary,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final done    = i < last7.length ? last7[i] : false;
              final isToday = i == 6;
              return Column(
                children: [
                  AnimatedContainer(
                    duration:
                        Duration(milliseconds: 300 + i * 40),
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done
                          ? AppColors.success.withOpacity(0.15)
                          : surfHigh,
                      border: Border.all(
                        color: isToday
                            ? primary
                            : done
                                ? AppColors.success
                                    .withOpacity(0.4)
                                : border,
                        width: isToday ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        done
                            ? Icons.check_rounded
                            : Icons.close_rounded,
                        size: 14,
                        color:
                            done ? AppColors.success : muted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    days[i],
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: isToday
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: isToday ? primary : muted,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Split Tile ─────────────────────────────────────────────────
class _SplitTile extends StatelessWidget {
  final GymDay day;
  final bool isToday;
  final Color surface, border, primary, muted, secondary;
  final VoidCallback? onTap;

  const _SplitTile({
    required this.day,
    required this.isToday,
    required this.surface,
    required this.border,
    required this.primary,
    required this.muted,
    required this.secondary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color:
              isToday ? primary.withOpacity(0.06) : surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isToday
                ? primary.withOpacity(0.25)
                : border,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 38,
              child: Text(
                day.weekday,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isToday ? primary : muted,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                day.isRest ? 'Rest Day' : day.muscleGroup,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: day.isRest ? muted : primary,
                  height: 1.4,
                ),
              ),
            ),
            if (!day.isRest)
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: muted),
            if (day.isRest)
              const Text('😴',
                  style: TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

// ── Routine Editor Sheet ──────────────────────────────────────
class _RoutineEditorSheet extends StatefulWidget {
  final Color bg, surface, border, primary, muted, secondary;

  const _RoutineEditorSheet({
    required this.bg,
    required this.surface,
    required this.border,
    required this.primary,
    required this.muted,
    required this.secondary,
  });

  @override
  State<_RoutineEditorSheet> createState() =>
      _RoutineEditorSheetState();
}

class _RoutineEditorSheetState
    extends State<_RoutineEditorSheet> {
  late List<Map<String, dynamic>> _edits;
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    final routine = context.read<GymProvider>().routine;
    _edits = routine
        .map((d) => {
              'weekday': d.weekday,
              'muscle': d.muscleGroup,
              'isRest': d.isRest,
            })
        .toList();
    _controllers = _edits
        .map((e) =>
            TextEditingController(text: e['muscle'] as String))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  void _save() {
    final updated = List.generate(
      _edits.length,
      (i) => GymDay(
        weekday: _edits[i]['weekday'] as String,
        muscleGroup: _controllers[i].text.trim(),
        isRest: _edits[i]['isRest'] as bool,
      ),
    );
    context.read<GymProvider>().updateRoutine(updated);
    HapticFeedback.mediumImpact();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom =
        MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: BoxDecoration(
        color: widget.bg,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
        border:
            Border(top: BorderSide(color: widget.border)),
      ),
      padding:
          EdgeInsets.fromLTRB(20, 20, 20, bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: widget.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Edit Weekly Split',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: widget.primary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight:
                  MediaQuery.of(context).size.height * 0.45,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(_edits.length, (i) {
                  final isRest =
                      _edits[i]['isRest'] as bool;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: Text(
                            _edits[i]['weekday'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: widget.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            enabled: !isRest,
                            controller: _controllers[i],
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                color: widget.primary),
                            cursorColor: widget.primary,
                            decoration: InputDecoration(
                              hintText: isRest
                                  ? 'Rest Day'
                                  : 'e.g. Chest & Triceps',
                              hintStyle: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: widget.muted),
                              filled: true,
                              fillColor: isRest
                                  ? widget.border
                                      .withOpacity(0.3)
                                  : widget.surface,
                              contentPadding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: widget.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: widget.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: widget.primary,
                                    width: 1.5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => setState(() =>
                              _edits[i]['isRest'] = !isRest),
                          child: AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: isRest
                                  ? widget.primary
                                      .withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius:
                                  BorderRadius.circular(8),
                              border: Border.all(
                                color: isRest
                                    ? widget.primary
                                        .withOpacity(0.4)
                                    : widget.border,
                              ),
                            ),
                            child: Text(
                              'Rest',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isRest
                                    ? widget.primary
                                    : widget.muted,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _save,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: widget.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'Save Routine',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: widget.bg,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}