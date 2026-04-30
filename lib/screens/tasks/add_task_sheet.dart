import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../models/task.dart';
import '../../providers/task_provider.dart';

class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _titleController = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;
  TaskType _type = TaskType.oneTime;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    HapticFeedback.mediumImpact();
    final task = Task.create(
      title: title,
      priority: _priority,
      type: _type,
      dateKey:
          PulseDateUtils.formatDateKey(PulseDateUtils.today),
    );
    context.read<TaskProvider>().addTask(task);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bg       = AppColors.bg(context);
    final surface  = AppColors.surface(context);
    final surfHigh = AppColors.surfaceHigh(context);
    final border   = AppColors.border(context);
    final primary  = AppColors.textPrimary(context);
    final muted    = AppColors.textMuted(context);
    final bottom   = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: border)),
      ),
      padding:
          EdgeInsets.fromLTRB(20, 20, 20, bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'New Task',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: primary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),

          // Title field
          TextField(
            controller: _titleController,
            autofocus: true,
            style: GoogleFonts.inter(fontSize: 15, color: primary),
            cursorColor: primary,
            decoration: InputDecoration(
              hintText: 'What do you need to do?',
              hintStyle:
                  GoogleFonts.inter(fontSize: 14, color: muted),
              filled: true,
              fillColor: surfHigh,
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
                borderSide: BorderSide(color: primary, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 20),
          Text(
            'Priority',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: primary,
            ),
          ),
          const SizedBox(height: 8),

          // Priority chips
          Row(
            children: TaskPriority.values.map((p) {
              final isSelected = _priority == p;
              final label = p == TaskPriority.high
                  ? 'High  3pt'
                  : p == TaskPriority.medium
                      ? 'Med  2pt'
                      : 'Low  1pt';
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _priority = p);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primary.withOpacity(0.1)
                          : surfHigh,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? primary : border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isSelected ? primary : muted,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),
          Text(
            'Type',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: primary,
            ),
          ),
          const SizedBox(height: 8),

          // Type chips
          Row(
            children: [
              _TypeChip(
                label: '🔁  Habit',
                selected: _type == TaskType.habit,
                primary: primary,
                muted: muted,
                surfHigh: surfHigh,
                border: border,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _type = TaskType.habit);
                },
              ),
              const SizedBox(width: 10),
              _TypeChip(
                label: '✅  One-time',
                selected: _type == TaskType.oneTime,
                primary: primary,
                muted: muted,
                surfHigh: surfHigh,
                border: border,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _type = TaskType.oneTime);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _submit,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'Add Task',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: bg,
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

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color primary, muted, surfHigh, border;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.selected,
    required this.primary,
    required this.muted,
    required this.surfHigh,
    required this.border,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? primary.withOpacity(0.1) : surfHigh,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? primary : border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? primary : muted,
          ),
        ),
      ),
    );
  }
}