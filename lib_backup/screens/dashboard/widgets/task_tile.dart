import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/task.dart';

class TaskTile extends StatefulWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback? onDelete;
  final VoidCallback? onSkip;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    this.onDelete,
    this.onSkip,
  });

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color _priorityColor(bool isDark) {
    switch (widget.task.priority) {
      case TaskPriority.high:
        return AppColors.danger;
      case TaskPriority.medium:
        return isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
      case TaskPriority.low:
        return isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
    }
  }

  String get _priorityLabel {
    switch (widget.task.priority) {
      case TaskPriority.high:   return 'HIGH';
      case TaskPriority.medium: return 'MED';
      case TaskPriority.low:    return 'LOW';
    }
  }

  void _handleTap() async {
    HapticFeedback.lightImpact();
    await _ctrl.forward();
    await _ctrl.reverse();
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final done      = widget.task.isCompleted;
    final surface   = AppColors.surface(context);
    final border    = AppColors.border(context);
    final primary   = AppColors.textPrimary(context);
    final muted     = AppColors.textMuted(context);
    final secondary = AppColors.textSecondary(context);
    final pColor    = _priorityColor(isDark);

    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (_, child) =>
          Transform.scale(scale: _scaleAnim.value, child: child),
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: done ? AppColors.success.withOpacity(0.06) : surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: done ? AppColors.success.withOpacity(0.3) : border,
            ),
          ),
          child: Row(
            children: [
              // Checkbox
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 22, height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? AppColors.success : Colors.transparent,
                  border: Border.all(
                    color: done ? AppColors.success : muted,
                    width: 2,
                  ),
                ),
                child: done
                    ? const Icon(Icons.check_rounded,
                        size: 13, color: Colors.white)
                    : null,
              ),

              const SizedBox(width: 12),

              // Text block
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 220),
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: done ? muted : primary,
                        decoration: done
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: muted,
                        height: 1.4,
                      ),
                      child: Text(widget.task.title),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (widget.task.type == TaskType.habit) ...[
                          Icon(Icons.repeat_rounded,
                              size: 11, color: secondary),
                          const SizedBox(width: 3),
                          Text('Habit',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: secondary,
                                fontWeight: FontWeight.w500,
                              )),
                          const SizedBox(width: 8),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: pColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _priorityLabel,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: pColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${widget.task.points}pt',
                          style: GoogleFonts.inter(
                              fontSize: 11, color: muted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.task.type == TaskType.habit &&
                      widget.onSkip != null)
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        widget.onSkip!();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Icon(Icons.skip_next_rounded,
                            size: 18, color: AppColors.warning),
                      ),
                    ),
                  if (widget.onDelete != null)
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        widget.onDelete!();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Icon(Icons.close_rounded,
                            size: 18, color: muted),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}