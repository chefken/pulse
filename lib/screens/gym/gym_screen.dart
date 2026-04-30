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
import 'widgets/gym_calendar.dart';

class GymScreen extends StatelessWidget {
  const GymScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gym     = context.watch<GymProvider>();
    final workout = context.watch<WorkoutProvider>();

    final bg        = AppColors.bg(context);
    final surface   = AppColors.surface(context);
    final border    = AppColors.border(context);
    final primary   = AppColors.textPrimary(context);
    final secondary = AppColors.textSecondary(context);
    final muted     = AppColors.textMuted(context);
    final surfHigh  = AppColors.surfaceHigh(context);

    final today    = gym.todayPlan;
    final isRest   = today?.isRest ?? true;
    final muscle   = today?.muscleGroup ?? '';
    final todayLog = workout.todayLog;
    final isDone   = todayLog?.completed ?? false;
    final exCount  = todayLog?.exercises.length ?? 0;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: [

            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          PulseDateUtils.formatDisplay(DateTime.now())
                              .toUpperCase(),
                          style: GoogleFonts.dmSans(
                            fontSize: 10, fontWeight: FontWeight.w500,
                            color: muted, letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text('Gym', style: GoogleFonts.dmSans(
                          fontSize: 20, fontWeight: FontWeight.w600,
                          color: primary, letterSpacing: -0.4,
                        )),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => _editSplit(context, gym, bg, surface,
                          border, primary, muted, secondary),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: surfHigh,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: border, width: 0.5),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined,
                                size: 13, color: secondary),
                            const SizedBox(width: 5),
                            Text('Split', style: GoogleFonts.dmSans(
                              fontSize: 12, color: secondary,
                            )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Today card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: GestureDetector(
                  onTap: isRest
                      ? null
                      : () => _openWorkout(context, today!, workout),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: isDone
                          ? primary.withOpacity(0.06)
                          : surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isDone
                            ? primary.withOpacity(0.18)
                            : border,
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('TODAY', style: GoogleFonts.dmSans(
                                fontSize: 9, fontWeight: FontWeight.w700,
                                color: muted, letterSpacing: 1.8,
                              )),
                              const SizedBox(height: 6),
                              Text(
                                isRest ? 'Rest day' : muscle,
                                style: GoogleFonts.dmSans(
                                  fontSize: 20, fontWeight: FontWeight.w600,
                                  color: isRest ? muted : primary,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              if (!isRest) ...[
                                const SizedBox(height: 4),
                                Text(
                                  isDone
                                      ? 'Completed'
                                      : exCount > 0
                                          ? '$exCount exercise${exCount > 1 ? 's' : ''} logged'
                                          : 'Tap to start',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12, color: muted,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (!isRest)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 42, height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primary.withOpacity(0.08),
                              border:
                                  Border.all(color: border, width: 0.5),
                            ),
                            child: Icon(
                              isDone
                                  ? Icons.check_rounded
                                  : Icons.arrow_forward_rounded,
                              color: primary, size: 17,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Calendar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: GymCalendar(
                  gymProvider: gym,
                  workoutProvider: workout,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 26)),

            // Split header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('Weekly split',
                    style: GoogleFonts.dmSans(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: muted, letterSpacing: 0.4,
                    )),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Split tiles
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
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
                      onTap: day.isRest
                          ? null
                          : () => _openDayWorkout(
                              context, day, workout),
                    );
                  },
                  childCount: gym.routine.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 110)),
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
            dateKey: dateKey, muscleGroup: plan.muscleGroup,
          ),
        ),
      ),
    );
  }

  void _openDayWorkout(BuildContext context, GymDay day,
      WorkoutProvider workout) {
    final now = DateTime.now();
    DateTime? target;
    for (int i = 0; i < 7; i++) {
      final d = now.subtract(Duration(days: i));
      if (['Mon','Tue','Wed','Thu','Fri','Sat','Sun']
              [d.weekday - 1] ==
          day.weekday) {
        target = d;
        break;
      }
    }
    final dateKey = PulseDateUtils.formatDateKey(
        target ?? PulseDateUtils.today);
    workout
        .getOrCreate(
            dateKey: dateKey, muscleGroup: day.muscleGroup)
        .then((_) {
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: workout,
            child: WorkoutDetailScreen(
              dateKey: dateKey, muscleGroup: day.muscleGroup,
            ),
          ),
        ),
      );
    });
  }

  void _editSplit(
      BuildContext context, GymProvider gym,
      Color bg, Color surface, Color border,
      Color primary, Color muted, Color secondary) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: gym,
        child: _RoutineSheet(
          bg: bg, surface: surface, border: border,
          primary: primary, muted: muted, secondary: secondary,
        ),
      ),
    );
  }
}

class _SplitTile extends StatelessWidget {
  final GymDay day;
  final bool isToday;
  final Color surface, border, primary, muted;
  final VoidCallback? onTap;

  const _SplitTile({
    required this.day, required this.isToday,
    required this.surface, required this.border,
    required this.primary, required this.muted, this.onTap,
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
          color: isToday ? primary.withOpacity(0.05) : surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isToday
                ? primary.withOpacity(0.20)
                : border,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              child: Text(day.weekday,
                  style: GoogleFonts.dmSans(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: isToday ? primary : muted,
                  )),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                day.isRest ? 'Rest' : day.muscleGroup,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: day.isRest ? muted : primary,
                ),
              ),
            ),
            if (!day.isRest)
              Icon(Icons.chevron_right_rounded,
                  size: 16, color: muted),
          ],
        ),
      ),
    );
  }
}

class _RoutineSheet extends StatefulWidget {
  final Color bg, surface, border, primary, muted, secondary;
  const _RoutineSheet({
    required this.bg, required this.surface, required this.border,
    required this.primary, required this.muted, required this.secondary,
  });

  @override
  State<_RoutineSheet> createState() => _RoutineSheetState();
}

class _RoutineSheetState extends State<_RoutineSheet> {
  late List<Map<String, dynamic>> _edits;
  late List<TextEditingController> _ctrls;

  @override
  void initState() {
    super.initState();
    final r = context.read<GymProvider>().routine;
    _edits = r.map((d) => {
      'weekday': d.weekday,
      'muscle':  d.muscleGroup,
      'isRest':  d.isRest,
    }).toList();
    _ctrls = _edits.map(
      (e) => TextEditingController(text: e['muscle'] as String),
    ).toList();
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    super.dispose();
  }

  void _save() {
    final updated = List.generate(
      _edits.length,
      (i) => GymDay(
        weekday: _edits[i]['weekday'] as String,
        muscleGroup: _ctrls[i].text.trim(),
        isRest: _edits[i]['isRest'] as bool,
      ),
    );
    context.read<GymProvider>().updateRoutine(updated);
    HapticFeedback.mediumImpact();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: BoxDecoration(
        color: widget.bg,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
            top: BorderSide(color: widget.border, width: 0.5)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(child: Container(
            width: 32, height: 3,
            decoration: BoxDecoration(
              color: widget.border,
              borderRadius: BorderRadius.circular(2),
            ),
          )),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Edit split', style: GoogleFonts.dmSans(
              fontSize: 16, fontWeight: FontWeight.w600,
              color: widget.primary,
            )),
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
                  final isRest = _edits[i]['isRest'] as bool;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 36,
                          child: Text(
                            _edits[i]['weekday'] as String,
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: widget.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            enabled: !isRest,
                            controller: _ctrls[i],
                            style: GoogleFonts.dmSans(
                                fontSize: 14,
                                color: widget.primary),
                            cursorColor: widget.primary,
                            decoration: InputDecoration(
                              hintText: isRest
                                  ? 'Rest'
                                  : 'e.g. Chest & Triceps',
                              hintStyle: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  color: widget.muted),
                              filled: true,
                              fillColor: isRest
                                  ? widget.border.withOpacity(0.2)
                                  : widget.surface,
                              contentPadding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: widget.border,
                                    width: 0.5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: widget.border,
                                    width: 0.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: widget.primary,
                                    width: 1),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => setState(
                              () => _edits[i]['isRest'] = !isRest),
                          child: AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: isRest
                                  ? widget.primary.withOpacity(0.10)
                                  : Colors.transparent,
                              borderRadius:
                                  BorderRadius.circular(8),
                              border: Border.all(
                                color: isRest
                                    ? widget.primary
                                        .withOpacity(0.30)
                                    : widget.border,
                                width: 0.5,
                              ),
                            ),
                            child: Text('Rest',
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isRest
                                      ? widget.primary
                                      : widget.muted,
                                )),
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
                child: Text('Save',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 15, fontWeight: FontWeight.w600,
                      color: widget.bg,
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}