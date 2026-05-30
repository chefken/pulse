import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/task.dart';

class TaskTile extends StatefulWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback? onDelete;
  // onSkip kept in signature for backward compat but no longer renders an icon
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
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late bool _localDone;

  @override
  void initState() {
    super.initState();
    _localDone = widget.task.isCompleted;
    _ctrl  = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
        reverseDuration: const Duration(milliseconds: 80));
    _scale = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(TaskTile old) {
    super.didUpdateWidget(old);
    if (old.task.isCompleted != widget.task.isCompleted) {
      _localDone = widget.task.isCompleted;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _tap() {
    HapticFeedback.lightImpact();
    setState(() => _localDone = !_localDone);
    _ctrl.forward().then((_) => _ctrl.reverse());
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.textPrimary(context);
    final muted   = AppColors.textMuted(context);
    final surface = AppColors.surface(context);
    final border  = AppColors.border(context);
    final bg      = AppColors.bg(context);

    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) =>
          Transform.scale(scale: _scale.value, child: child),
      child: GestureDetector(
        onTap: _tap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color:
                _localDone ? primary.withOpacity(0.05) : surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _localDone
                  ? primary.withOpacity(0.18)
                  : border,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              // Checkbox
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 21, height: 21,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _localDone ? primary : Colors.transparent,
                  border: Border.all(
                    color: _localDone
                        ? primary
                        : muted.withOpacity(0.45),
                    width: 1.2,
                  ),
                ),
                child: _localDone
                    ? Icon(Icons.check_rounded, size: 12, color: bg)
                    : null,
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 180),
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _localDone ? muted : primary,
                        decoration: _localDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: muted,
                        height: 1.3,
                      ),
                      child: Text(widget.task.title),
                    ),
                    if (widget.task.type == TaskType.habit) ...[
                      const SizedBox(height: 2),
                      Text('Daily',
                          style: GoogleFonts.dmSans(
                              fontSize: 10, color: muted)),
                    ],
                  ],
                ),
              ),

              // Only delete icon — skip arrow removed
              if (widget.onDelete != null)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onDelete!();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Icon(Icons.close_rounded,
                        size: 17, color: muted),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}