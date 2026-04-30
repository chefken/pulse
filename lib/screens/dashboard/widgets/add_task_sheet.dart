import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../models/task.dart';
import '../../../providers/task_provider.dart';

class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _ctrl = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;
  TaskType     _type     = TaskType.oneTime;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _submit() {
    final title = _ctrl.text.trim();
    if (title.isEmpty) return;
    HapticFeedback.mediumImpact();
    context.read<TaskProvider>().addTask(Task.create(
      title: title,
      priority: _priority,
      type: _type,
      dateKey: PulseDateUtils.formatDateKey(PulseDateUtils.today),
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bg      = AppColors.bg(context);
    final surfHi  = AppColors.surfaceHigh(context);
    final border  = AppColors.border(context);
    final primary = AppColors.textPrimary(context);
    final muted   = AppColors.textMuted(context);
    final bottom  = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: border, width: 0.5)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, bottom + 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(
            width: 32, height: 3,
            decoration: BoxDecoration(
              color: border, borderRadius: BorderRadius.circular(2),
            ),
          )),
          const SizedBox(height: 22),
          Text('New task', style: GoogleFonts.dmSans(
            fontSize: 17, fontWeight: FontWeight.w600, color: primary,
          )),
          const SizedBox(height: 18),

          // Input
          TextField(
            controller: _ctrl,
            autofocus: true,
            style: GoogleFonts.dmSans(fontSize: 15, color: primary),
            cursorColor: primary,
            decoration: InputDecoration(
              hintText: 'What needs to get done?',
              hintStyle: GoogleFonts.dmSans(fontSize: 14, color: muted),
              filled: true, fillColor: surfHi,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: border, width: 0.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: border, width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: primary, width: 1),
              ),
            ),
          ),

          const SizedBox(height: 18),
          _Label('TYPE', muted),
          const SizedBox(height: 10),
          Row(children: [
            _Chip('One-time', _type == TaskType.oneTime,
                primary, muted, surfHi, border,
                () => setState(() => _type = TaskType.oneTime)),
            const SizedBox(width: 8),
            _Chip('Daily habit', _type == TaskType.habit,
                primary, muted, surfHi, border,
                () => setState(() => _type = TaskType.habit)),
          ]),

          const SizedBox(height: 18),
          _Label('PRIORITY', muted),
          const SizedBox(height: 10),
          Row(children: [
            _Chip('Low', _priority == TaskPriority.low,
                primary, muted, surfHi, border,
                () => setState(() => _priority = TaskPriority.low)),
            const SizedBox(width: 8),
            _Chip('Medium', _priority == TaskPriority.medium,
                primary, muted, surfHi, border,
                () => setState(() => _priority = TaskPriority.medium)),
            const SizedBox(width: 8),
            _Chip('High', _priority == TaskPriority.high,
                primary, muted, surfHi, border,
                () => setState(() => _priority = TaskPriority.high)),
          ]),

          const SizedBox(height: 26),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _submit,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text('Add task',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 15, fontWeight: FontWeight.w600,
                      color: bg,
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final Color muted;
  const _Label(this.text, this.muted);

  @override
  Widget build(BuildContext context) => Text(text,
    style: GoogleFonts.dmSans(
      fontSize: 10, fontWeight: FontWeight.w600,
      color: muted, letterSpacing: 1.2,
    ));
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color primary, muted, surfHigh, border;
  final VoidCallback onTap;

  const _Chip(this.label, this.selected, this.primary, this.muted,
      this.surfHigh, this.border, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); onTap(); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? primary.withOpacity(0.10) : surfHigh,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? primary : border,
            width: selected ? 1 : 0.5,
          ),
        ),
        child: Text(label, style: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected ? primary : muted,
        )),
      ),
    );
  }
}