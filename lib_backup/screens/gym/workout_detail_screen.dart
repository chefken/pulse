import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/workout_log.dart';
import '../../providers/workout_provider.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final String dateKey;
  final String muscleGroup;

  const WorkoutDetailScreen({
    super.key,
    required this.dateKey,
    required this.muscleGroup,
  });

  @override
  Widget build(BuildContext context) {
    final workout   = context.watch<WorkoutProvider>();
    final log       = workout.logFor(dateKey);
    final exercises = log?.exercises ?? [];
    final isDone    = log?.completed ?? false;
    final isDark    =
        Theme.of(context).brightness == Brightness.dark;

    final bg        = AppColors.bg(context);
    final surface   = AppColors.surface(context);
    final surfHigh  = AppColors.surfaceHigh(context);
    final border    = AppColors.border(context);
    final primary   = AppColors.textPrimary(context);
    final secondary = AppColors.textSecondary(context);
    final muted     = AppColors.textMuted(context);

    return Scaffold(
      backgroundColor: bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────
            Container(
              padding:
                  const EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: BoxDecoration(
                color: bg,
                border: Border(
                    bottom: BorderSide(color: border, width: 1)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: border),
                      ),
                      child: Icon(Icons.arrow_back_rounded,
                          size: 18, color: secondary),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          muscleGroup,
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: primary,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          dateKey,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: muted,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      workout.toggleCompleted(dateKey);
                    },
                    child: AnimatedContainer(
                      duration:
                          const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        color: isDone ? primary : surface,
                        borderRadius:
                            BorderRadius.circular(20),
                        border: Border.all(
                            color: isDone ? primary : border),
                      ),
                      child: Text(
                        isDone ? '✓  Done' : 'Mark Done',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDone ? bg : secondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Exercise list ─────────────────────────────
            Expanded(
              child: exercises.isEmpty
                  ? _EmptyWorkout(
                      primary: primary,
                      muted: muted,
                      surface: surface,
                      border: border,
                      bg: bg,
                      onAdd: () => _showAddExercise(
                          context, workout, bg, surface,
                          surfHigh, border, primary, muted,
                          secondary),
                    )
                  : ListView.builder(
                      physics:
                          const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                          16, 16, 16, 100),
                      itemCount: exercises.length + 1,
                      itemBuilder: (_, i) {
                        if (i == exercises.length) {
                          return _AddExerciseButton(
                            surface: surface,
                            border: border,
                            primary: primary,
                            onTap: () => _showAddExercise(
                                context, workout, bg,
                                surface, surfHigh, border,
                                primary, muted, secondary),
                          );
                        }
                        return _ExerciseCard(
                          key: ValueKey(exercises[i].id),
                          exercise: exercises[i],
                          dateKey: dateKey,
                          provider: workout,
                          isDark: isDark,
                          bg: bg,
                          surface: surface,
                          surfHigh: surfHigh,
                          border: border,
                          primary: primary,
                          secondary: secondary,
                          muted: muted,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddExercise(
      BuildContext ctx,
      WorkoutProvider w,
      Color bg,
      Color surface,
      Color surfHigh,
      Color border,
      Color primary,
      Color muted,
      Color secondary) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddExerciseSheet(
        bg: bg,
        surface: surface,
        surfHigh: surfHigh,
        border: border,
        primary: primary,
        muted: muted,
        secondary: secondary,
        suggestions: w.allExerciseNames.toList(),
        onAdd: (name) {
          w.addExercise(dateKey, name);
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

// ── Exercise Card ─────────────────────────────────────────────
class _ExerciseCard extends StatelessWidget {
  final WorkoutExercise exercise;
  final String dateKey;
  final WorkoutProvider provider;
  final bool isDark;
  final Color bg, surface, surfHigh, border, primary,
      secondary, muted;

  const _ExerciseCard({
    super.key,
    required this.exercise,
    required this.dateKey,
    required this.provider,
    required this.isDark,
    required this.bg,
    required this.surface,
    required this.surfHigh,
    required this.border,
    required this.primary,
    required this.secondary,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise name row
          Padding(
            padding:
                const EdgeInsets.fromLTRB(16, 14, 12, 10),
            child: Row(
              children: [
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                      Icons.fitness_center_rounded,
                      size: 16, color: primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    exercise.name,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: primary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    provider.deleteExercise(
                        dateKey, exercise.id);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                        Icons.delete_outline_rounded,
                        size: 18, color: muted),
                  ),
                ),
              ],
            ),
          ),

          // Column headers
          if (exercise.sets.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(16, 0, 16, 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Text('SET',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: muted,
                          letterSpacing: 1,
                        )),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('WEIGHT (KG)',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: muted,
                          letterSpacing: 1,
                        )),
                  ),
                  Expanded(
                    child: Text('REPS',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: muted,
                          letterSpacing: 1,
                        )),
                  ),
                  const SizedBox(width: 28),
                ],
              ),
            ),

          // Set rows
          ...exercise.sets.asMap().entries.map(
                (e) => _SetRow(
                  index: e.key + 1,
                  set: e.value,
                  primary: primary,
                  muted: muted,
                  surfHigh: surfHigh,
                  onEdit: () => _openSetSheet(
                      context, e.value, isEdit: true),
                  onDelete: () {
                    HapticFeedback.lightImpact();
                    provider.deleteSet(
                        dateKey, exercise.id, e.value.id);
                  },
                ),
              ),

          // Add set button
          GestureDetector(
            onTap: () => _openSetSheet(context, null),
            child: Container(
              margin: const EdgeInsets.all(12),
              padding:
                  const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: primary.withOpacity(0.15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded,
                      size: 15,
                      color: primary.withOpacity(0.7)),
                  const SizedBox(width: 6),
                  Text(
                    'Add Set',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: primary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openSetSheet(BuildContext ctx, ExerciseSet? existing,
      {bool isEdit = false}) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SetEditorSheet(
        title: isEdit ? 'Edit Set' : 'Add Set',
        initialWeight: existing?.weight ?? 0,
        initialReps: existing?.reps ?? 0,
        bg: bg,
        surface: surface,
        surfHigh: surfHigh,
        border: border,
        primary: primary,
        muted: muted,
        onSave: (w, r) {
          if (isEdit && existing != null) {
            provider.updateSet(dateKey, exercise.id,
                existing.id, weight: w, reps: r);
          } else {
            provider.addSet(dateKey, exercise.id,
                weight: w, reps: r);
          }
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

// ── Set Row ───────────────────────────────────────────────────
class _SetRow extends StatelessWidget {
  final int index;
  final ExerciseSet set;
  final Color primary, muted, surfHigh;
  final VoidCallback onEdit, onDelete;

  const _SetRow({
    required this.index,
    required this.set,
    required this.primary,
    required this.muted,
    required this.surfHigh,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      child: Container(
        margin:
            const EdgeInsets.fromLTRB(12, 0, 12, 6),
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: surfHigh,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: primary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${set.weight % 1 == 0 ? set.weight.toInt() : set.weight} kg',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: primary,
                ),
              ),
            ),
            Expanded(
              child: Text(
                '${set.reps} reps',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: primary,
                ),
              ),
            ),
            GestureDetector(
              onTap: onDelete,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(Icons.close_rounded,
                    size: 16, color: muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty Workout ─────────────────────────────────────────────
class _EmptyWorkout extends StatelessWidget {
  final Color primary, muted, surface, border, bg;
  final VoidCallback onAdd;

  const _EmptyWorkout({
    required this.primary,
    required this.muted,
    required this.surface,
    required this.border,
    required this.bg,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70, height: 70,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.06),
                shape: BoxShape.circle,
                border: Border.all(color: border),
              ),
              child: Icon(Icons.fitness_center_rounded,
                  size: 30,
                  color: primary.withOpacity(0.4)),
            ),
            const SizedBox(height: 20),
            Text(
              'No exercises yet',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: primary,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first exercise\nto start tracking.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: muted,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 36, vertical: 15),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'Add Exercise',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: bg,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Add Exercise Button ───────────────────────────────────────
class _AddExerciseButton extends StatelessWidget {
  final Color surface, border, primary;
  final VoidCallback onTap;

  const _AddExerciseButton({
    required this.surface,
    required this.border,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 4, bottom: 20),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 18, color: primary),
            const SizedBox(width: 8),
            Text(
              'Add Exercise',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Add Exercise Sheet ────────────────────────────────────────
class _AddExerciseSheet extends StatefulWidget {
  final Color bg, surface, surfHigh, border, primary, muted,
      secondary;
  final List<String> suggestions;
  final Function(String) onAdd;

  const _AddExerciseSheet({
    required this.bg,
    required this.surface,
    required this.surfHigh,
    required this.border,
    required this.primary,
    required this.muted,
    required this.secondary,
    required this.suggestions,
    required this.onAdd,
  });

  @override
  State<_AddExerciseSheet> createState() =>
      _AddExerciseSheetState();
}

class _AddExerciseSheetState
    extends State<_AddExerciseSheet> {
  final _ctrl = TextEditingController();
  late List<String> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = widget.suggestions;
    _ctrl.addListener(() {
      final q = _ctrl.text.toLowerCase();
      setState(() => _filtered = widget.suggestions
          .where((s) => s.toLowerCase().contains(q))
          .toList());
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
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
        border: Border(
            top: BorderSide(color: widget.border, width: 1)),
      ),
      padding:
          EdgeInsets.fromLTRB(20, 20, 20, bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 20),
          Text(
            'Add Exercise',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: widget.primary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _ctrl,
            autofocus: true,
            style: GoogleFonts.inter(
                fontSize: 15, color: widget.primary),
            cursorColor: widget.primary,
            decoration: InputDecoration(
              hintText: 'e.g. Bench Press',
              hintStyle: GoogleFonts.inter(
                  fontSize: 14, color: widget.muted),
              filled: true,
              fillColor: widget.surfHigh,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: widget.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: widget.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: widget.primary, width: 1.5),
              ),
            ),
          ),
          if (_filtered.isNotEmpty) ...[
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints:
                  const BoxConstraints(maxHeight: 110),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8, runSpacing: 8,
                  children: _filtered
                      .map((s) => GestureDetector(
                            onTap: () => widget.onAdd(s),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: widget.surface,
                                borderRadius:
                                    BorderRadius.circular(20),
                                border: Border.all(
                                    color: widget.border),
                              ),
                              child: Text(s,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: widget.secondary,
                                  )),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () {
                final name = _ctrl.text.trim();
                if (name.isEmpty) return;
                HapticFeedback.mediumImpact();
                widget.onAdd(name);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: widget.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Add',
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

// ── Set Editor Sheet ──────────────────────────────────────────
class _SetEditorSheet extends StatefulWidget {
  final String title;
  final double initialWeight;
  final int initialReps;
  final Color bg, surface, surfHigh, border, primary, muted;
  final Function(double, int) onSave;

  const _SetEditorSheet({
    required this.title,
    required this.onSave,
    required this.bg,
    required this.surface,
    required this.surfHigh,
    required this.border,
    required this.primary,
    required this.muted,
    this.initialWeight = 0,
    this.initialReps = 0,
  });

  @override
  State<_SetEditorSheet> createState() =>
      _SetEditorSheetState();
}

class _SetEditorSheetState extends State<_SetEditorSheet> {
  late TextEditingController _wCtrl;
  late TextEditingController _rCtrl;

  @override
  void initState() {
    super.initState();
    _wCtrl = TextEditingController(
      text: widget.initialWeight > 0
          ? '${widget.initialWeight % 1 == 0 ? widget.initialWeight.toInt() : widget.initialWeight}'
          : '',
    );
    _rCtrl = TextEditingController(
      text: widget.initialReps > 0
          ? '${widget.initialReps}'
          : '',
    );
  }

  @override
  void dispose() {
    _wCtrl.dispose();
    _rCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final w = double.tryParse(_wCtrl.text) ?? 0;
    final r = int.tryParse(_rCtrl.text) ?? 0;
    if (w <= 0 || r <= 0) return;
    HapticFeedback.mediumImpact();
    widget.onSave(w, r);
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
        border: Border(
            top: BorderSide(color: widget.border, width: 1)),
      ),
      padding:
          EdgeInsets.fromLTRB(20, 20, 20, bottom + 24),
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
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.title,
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: widget.primary,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _NumberField(
                  label: 'WEIGHT (KG)',
                  controller: _wCtrl,
                  autofocus: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                          decimal: true),
                  primary: widget.primary,
                  muted: widget.muted,
                  surfHigh: widget.surfHigh,
                  border: widget.border,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _NumberField(
                  label: 'REPS',
                  controller: _rCtrl,
                  keyboardType: TextInputType.number,
                  primary: widget.primary,
                  muted: widget.muted,
                  surfHigh: widget.surfHigh,
                  border: widget.border,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _save,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: widget.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Save Set',
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

// ── Number Field ──────────────────────────────────────────────
class _NumberField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool autofocus;
  final Color primary, muted, surfHigh, border;

  const _NumberField({
    required this.label,
    required this.controller,
    required this.keyboardType,
    required this.primary,
    required this.muted,
    required this.surfHigh,
    required this.border,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: muted,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          autofocus: autofocus,
          keyboardType: keyboardType,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: primary,
          ),
          cursorColor: primary,
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: muted,
            ),
            filled: true,
            fillColor: surfHigh,
            contentPadding: const EdgeInsets.symmetric(
                vertical: 16, horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}