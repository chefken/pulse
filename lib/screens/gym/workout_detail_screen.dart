import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/workout_log.dart';
import '../../providers/workout_provider.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final String dateKey, muscleGroup;

  const WorkoutDetailScreen({
    super.key, required this.dateKey, required this.muscleGroup,
  });

  @override
  Widget build(BuildContext context) {
    final workout = context.watch<WorkoutProvider>();
    final log     = workout.logFor(dateKey);
    final exs     = log?.exercises ?? [];
    final isDone  = log?.completed ?? false;
    final isDark  = Theme.of(context).brightness == Brightness.dark;

    final bg      = AppColors.bg(context);
    final surface = AppColors.surface(context);
    final surfHi  = AppColors.surfaceHigh(context);
    final border  = AppColors.border(context);
    final primary = AppColors.textPrimary(context);
    final second  = AppColors.textSecondary(context);
    final muted   = AppColors.textMuted(context);

    return Scaffold(
      backgroundColor: bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: BoxDecoration(
                color: bg,
                border: Border(
                    bottom: BorderSide(color: border, width: 0.5)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: surface,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: border, width: 0.5),
                      ),
                      child: Icon(Icons.arrow_back_rounded,
                          size: 17, color: second),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(muscleGroup,
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: primary,
                            )),
                        Text(dateKey,
                            style: GoogleFonts.dmSans(
                                fontSize: 11, color: muted)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      workout.toggleCompleted(dateKey);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDone ? primary : surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDone ? primary : border,
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        isDone ? 'Done' : 'Mark done',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDone ? bg : second,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: exs.isEmpty
                  ? _Empty(
                      primary: primary, muted: muted,
                      surface: surface, border: border, bg: bg,
                      onAdd: () => _addEx(context, workout, bg,
                          surface, surfHi, border, primary, muted, second),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding:
                          const EdgeInsets.fromLTRB(20, 16, 20, 100),
                      itemCount: exs.length + 1,
                      itemBuilder: (_, i) {
                        if (i == exs.length) {
                          return _AddExBtn(
                            surface: surface,
                            border: border,
                            primary: primary,
                            onTap: () => _addEx(context, workout, bg,
                                surface, surfHi, border, primary,
                                muted, second),
                          );
                        }
                        return _ExCard(
                          key: ValueKey(exs[i].id),
                          exercise: exs[i],
                          dateKey: dateKey,
                          provider: workout,
                          isDark: isDark,
                          bg: bg,
                          surface: surface,
                          surfHigh: surfHi,
                          border: border,
                          primary: primary,
                          secondary: second,
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

  void _addEx(
      BuildContext ctx, WorkoutProvider w,
      Color bg, Color surface, Color surfHi, Color border,
      Color primary, Color muted, Color secondary) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddExSheet(
        bg: bg, surface: surface, surfHigh: surfHi,
        border: border, primary: primary, muted: muted,
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

class _ExCard extends StatelessWidget {
  final WorkoutExercise exercise;
  final String dateKey;
  final WorkoutProvider provider;
  final bool isDark;
  final Color bg, surface, surfHigh, border, primary, secondary, muted;

  const _ExCard({
    super.key,
    required this.exercise, required this.dateKey,
    required this.provider, required this.isDark,
    required this.bg, required this.surface, required this.surfHigh,
    required this.border, required this.primary,
    required this.secondary, required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border, width: 0.5),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.fitness_center_outlined,
                      size: 15, color: primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(exercise.name,
                      style: GoogleFonts.dmSans(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        color: primary,
                      )),
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    provider.deleteExercise(dateKey, exercise.id);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(Icons.delete_outline_rounded,
                        size: 16, color: muted),
                  ),
                ),
              ],
            ),
          ),

          if (exercise.sets.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              child: Row(
                children: [
                  SizedBox(width: 26,
                    child: Text('SET', style: GoogleFonts.dmSans(
                      fontSize: 9, fontWeight: FontWeight.w600,
                      color: muted, letterSpacing: 1,
                    ))),
                  const SizedBox(width: 12),
                  Expanded(child: Text('WEIGHT', style: GoogleFonts.dmSans(
                    fontSize: 9, fontWeight: FontWeight.w600,
                    color: muted, letterSpacing: 1,
                  ))),
                  Expanded(child: Text('REPS', style: GoogleFonts.dmSans(
                    fontSize: 9, fontWeight: FontWeight.w600,
                    color: muted, letterSpacing: 1,
                  ))),
                  const SizedBox(width: 22),
                ],
              ),
            ),
            ...exercise.sets.asMap().entries.map(
              (e) => _SetRow(
                index: e.key + 1, set: e.value,
                primary: primary, muted: muted, surfHigh: surfHigh,
                onEdit: () => _editSet(context, e.value),
                onDelete: () {
                  HapticFeedback.lightImpact();
                  provider.deleteSet(
                      dateKey, exercise.id, e.value.id);
                },
              ),
            ),
          ],

          // Add set
          GestureDetector(
            onTap: () => _addSet(context),
            child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: primary.withOpacity(0.12), width: 0.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, size: 13,
                      color: primary.withOpacity(0.6)),
                  const SizedBox(width: 5),
                  Text('Add set', style: GoogleFonts.dmSans(
                    fontSize: 12, fontWeight: FontWeight.w500,
                    color: primary.withOpacity(0.6),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addSet(BuildContext ctx) => showModalBottomSheet(
    context: ctx, isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SetSheet(
      title: 'Add set', bg: bg, surfHigh: surfHigh,
      border: border, primary: primary, muted: muted,
      onSave: (w, r) {
        provider.addSet(dateKey, exercise.id, weight: w, reps: r);
        Navigator.pop(ctx);
      },
    ),
  );

  void _editSet(BuildContext ctx, ExerciseSet s) =>
      showModalBottomSheet(
    context: ctx, isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SetSheet(
      title: 'Edit set', initialWeight: s.weight, initialReps: s.reps,
      bg: bg, surfHigh: surfHigh, border: border,
      primary: primary, muted: muted,
      onSave: (w, r) {
        provider.updateSet(dateKey, exercise.id, s.id,
            weight: w, reps: r);
        Navigator.pop(ctx);
      },
    ),
  );
}

class _SetRow extends StatelessWidget {
  final int index;
  final ExerciseSet set;
  final Color primary, muted, surfHigh;
  final VoidCallback onEdit, onDelete;

  const _SetRow({
    required this.index, required this.set,
    required this.primary, required this.muted, required this.surfHigh,
    required this.onEdit, required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 6),
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: surfHigh,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 26,
              child: Container(
                width: 20, height: 20,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text('$index',
                      style: GoogleFonts.dmSans(
                        fontSize: 10, fontWeight: FontWeight.w700,
                        color: primary,
                      )),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${set.weight % 1 == 0 ? set.weight.toInt() : set.weight} kg',
                style: GoogleFonts.dmSans(
                    fontSize: 13, fontWeight: FontWeight.w500,
                    color: primary),
              ),
            ),
            Expanded(
              child: Text('${set.reps} reps',
                  style: GoogleFonts.dmSans(
                      fontSize: 13, fontWeight: FontWeight.w500,
                      color: primary)),
            ),
            GestureDetector(
              onTap: onDelete,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(Icons.close_rounded,
                    size: 14, color: muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final Color primary, muted, surface, border, bg;
  final VoidCallback onAdd;
  const _Empty({
    required this.primary, required this.muted, required this.surface,
    required this.border, required this.bg, required this.onAdd,
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
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.06),
                shape: BoxShape.circle,
                border: Border.all(
                    color: primary.withOpacity(0.10), width: 0.5),
              ),
              child: Icon(Icons.fitness_center_outlined,
                  size: 24, color: primary.withOpacity(0.4)),
            ),
            const SizedBox(height: 16),
            Text('No exercises', style: GoogleFonts.dmSans(
              fontSize: 16, fontWeight: FontWeight.w600, color: primary,
            )),
            const SizedBox(height: 5),
            Text('Add your first exercise to start.',
                style: GoogleFonts.dmSans(
                  fontSize: 13, color: muted, height: 1.5,
                ),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 30, vertical: 13),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text('Add exercise',
                    style: GoogleFonts.dmSans(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: bg,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddExBtn extends StatelessWidget {
  final Color surface, border, primary;
  final VoidCallback onTap;
  const _AddExBtn({
    required this.surface, required this.border,
    required this.primary, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 4, bottom: 20),
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 16, color: primary),
            const SizedBox(width: 7),
            Text('Add exercise', style: GoogleFonts.dmSans(
              fontSize: 14, fontWeight: FontWeight.w600, color: primary,
            )),
          ],
        ),
      ),
    );
  }
}

class _AddExSheet extends StatefulWidget {
  final Color bg, surface, surfHigh, border, primary, muted, secondary;
  final List<String> suggestions;
  final Function(String) onAdd;

  const _AddExSheet({
    required this.bg, required this.surface, required this.surfHigh,
    required this.border, required this.primary, required this.muted,
    required this.secondary, required this.suggestions,
    required this.onAdd,
  });

  @override
  State<_AddExSheet> createState() => _AddExSheetState();
}

class _AddExSheetState extends State<_AddExSheet> {
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
  void dispose() { _ctrl.dispose(); super.dispose(); }

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(
            width: 32, height: 3,
            decoration: BoxDecoration(
              color: widget.border,
              borderRadius: BorderRadius.circular(2),
            ),
          )),
          const SizedBox(height: 20),
          Text('Add exercise', style: GoogleFonts.dmSans(
            fontSize: 16, fontWeight: FontWeight.w600,
            color: widget.primary,
          )),
          const SizedBox(height: 14),
          TextField(
            controller: _ctrl, autofocus: true,
            style: GoogleFonts.dmSans(
                fontSize: 15, color: widget.primary),
            cursorColor: widget.primary,
            decoration: InputDecoration(
              hintText: 'e.g. Bench Press',
              hintStyle: GoogleFonts.dmSans(
                  fontSize: 14, color: widget.muted),
              filled: true, fillColor: widget.surfHigh,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    BorderSide(color: widget.border, width: 0.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    BorderSide(color: widget.border, width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    BorderSide(color: widget.primary, width: 1),
              ),
            ),
          ),
          if (_filtered.isNotEmpty) ...[
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 90),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8, runSpacing: 8,
                  children: _filtered.map((s) => GestureDetector(
                    onTap: () => widget.onAdd(s),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: widget.surfHigh,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: widget.border, width: 0.5),
                      ),
                      child: Text(s, style: GoogleFonts.dmSans(
                        fontSize: 12, color: widget.secondary,
                      )),
                    ),
                  )).toList(),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () {
                final n = _ctrl.text.trim();
                if (n.isEmpty) return;
                HapticFeedback.mediumImpact();
                widget.onAdd(n);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: widget.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text('Add', textAlign: TextAlign.center,
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

class _SetSheet extends StatefulWidget {
  final String title;
  final double initialWeight;
  final int initialReps;
  final Color bg, surfHigh, border, primary, muted;
  final Function(double, int) onSave;

  const _SetSheet({
    required this.title, required this.onSave, required this.bg,
    required this.surfHigh, required this.border,
    required this.primary, required this.muted,
    this.initialWeight = 0, this.initialReps = 0,
  });

  @override
  State<_SetSheet> createState() => _SetSheetState();
}

class _SetSheetState extends State<_SetSheet> {
  late final TextEditingController _w, _r;

  @override
  void initState() {
    super.initState();
    _w = TextEditingController(
      text: widget.initialWeight > 0
          ? '${widget.initialWeight % 1 == 0 ? widget.initialWeight.toInt() : widget.initialWeight}'
          : '',
    );
    _r = TextEditingController(
      text: widget.initialReps > 0 ? '${widget.initialReps}' : '',
    );
  }

  @override
  void dispose() { _w.dispose(); _r.dispose(); super.dispose(); }

  void _save() {
    final wv = double.tryParse(_w.text) ?? 0;
    final rv = int.tryParse(_r.text) ?? 0;
    if (wv <= 0 || rv <= 0) return;
    HapticFeedback.mediumImpact();
    widget.onSave(wv, rv);
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
            child: Text(widget.title, style: GoogleFonts.dmSans(
              fontSize: 16, fontWeight: FontWeight.w600,
              color: widget.primary,
            )),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _NumField(
                label: 'WEIGHT (KG)', ctrl: _w, autofocus: true,
                kb: const TextInputType.numberWithOptions(decimal: true),
                primary: widget.primary, muted: widget.muted,
                surfHigh: widget.surfHigh, border: widget.border,
              )),
              const SizedBox(width: 14),
              Expanded(child: _NumField(
                label: 'REPS', ctrl: _r,
                kb: TextInputType.number,
                primary: widget.primary, muted: widget.muted,
                surfHigh: widget.surfHigh, border: widget.border,
              )),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _save,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: widget.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text('Save', textAlign: TextAlign.center,
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

class _NumField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final TextInputType kb;
  final bool autofocus;
  final Color primary, muted, surfHigh, border;

  const _NumField({
    required this.label, required this.ctrl, required this.kb,
    required this.primary, required this.muted,
    required this.surfHigh, required this.border,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.dmSans(
          fontSize: 9, fontWeight: FontWeight.w600,
          color: muted, letterSpacing: 1.2,
        )),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl, autofocus: autofocus,
          keyboardType: kb, textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
              fontSize: 24, fontWeight: FontWeight.w700, color: primary),
          cursorColor: primary,
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: GoogleFonts.dmSans(
                fontSize: 24, fontWeight: FontWeight.w700, color: muted),
            filled: true, fillColor: surfHigh,
            contentPadding: const EdgeInsets.symmetric(
                vertical: 14, horizontal: 12),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: border, width: 0.5)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: border, width: 0.5)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primary, width: 1)),
          ),
        ),
      ],
    );
  }
}