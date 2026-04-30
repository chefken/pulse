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
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _tap() async {
    HapticFeedback.lightImpact();
    await _ctrl.forward();
    await _ctrl.reverse();
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final done    = widget.task.isCompleted;
    final primary = AppColors.textPrimary(context);
    final muted   = AppColors.textMuted(context);
    final surface = AppColors.surface(context);
    final border  = AppColors.border(context);

    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) =>
          Transform.scale(scale: _scale.value, child: child),
      child: GestureDetector(
        onTap: _tap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: done ? primary.withOpacity(0.05) : surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: done ? primary.withOpacity(0.18) : border,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              // Checkbox
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 21, height: 21,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? primary : Colors.transparent,
                  border: Border.all(
                    color: done ? primary : muted.withOpacity(0.45),
                    width: 1.2,
                  ),
                ),
                child: done
                    ? Icon(Icons.check_rounded, size: 12,
                        color: AppColors.bg(context))
                    : null,
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 220),
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: done ? muted : primary,
                        decoration: done
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: muted,
                        height: 1.3,
                      ),
                      child: Text(widget.task.title),
                    ),
                    if (widget.task.type == TaskType.habit) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Daily',
                        style: GoogleFonts.dmSans(
                          fontSize: 10, color: muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Skip (habits only)
              if (widget.task.type == TaskType.habit &&
                  widget.onSkip != null)
                _IconBtn(
                  icon: Icons.arrow_forward_rounded,
                  color: muted,
                  onTap: widget.onSkip!,
                ),

              if (widget.onDelete != null)
                _IconBtn(
                  icon: Icons.close_rounded,
                  color: muted,
                  onTap: widget.onDelete!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconBtn({
    required this.icon, required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); onTap(); },
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Icon(icon, size: 17, color: color),
      ),
    );
  }
}