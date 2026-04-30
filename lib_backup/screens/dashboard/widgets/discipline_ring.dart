import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class DisciplineRing extends StatefulWidget {
  final double score;
  final int earnedPoints;
  final int totalPoints;

  const DisciplineRing({
    super.key,
    required this.score,
    required this.earnedPoints,
    required this.totalPoints,
  });

  @override
  State<DisciplineRing> createState() => _DisciplineRingState();
}

class _DisciplineRingState extends State<DisciplineRing>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _scoreCountAnim;

  double _prevScore = 0;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);

    _progressAnim = CurvedAnimation(
        parent: _progressController, curve: Curves.easeOutCubic);
    _pulseAnim = Tween<double>(begin: 0.97, end: 1.03).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _scoreCountAnim =
        Tween<double>(begin: 0, end: widget.score).animate(_progressAnim);
    _progressController.forward();
  }

  @override
  void didUpdateWidget(DisciplineRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _prevScore = oldWidget.score;
      _scoreCountAnim = Tween<double>(begin: _prevScore, end: widget.score)
          .animate(_progressAnim);
      _progressController
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Color _scoreColor(double score, bool isDark) {
    if (score >= 0.7) return AppColors.success;
    if (score >= 0.4) return isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = AppColors.border(context);

    return AnimatedBuilder(
      animation: Listenable.merge([_progressAnim, _pulseAnim]),
      builder: (context, _) {
        final score = _scoreCountAnim.value;
        final color = _scoreColor(score, isDark);
        return Transform.scale(
          scale: _pulseAnim.value,
          child: SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 160, height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.12 * score),
                        blurRadius: 30,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                ),
                CustomPaint(
                  size: const Size(180, 180),
                  painter: _RingPainter(
                    progress: _progressAnim.value * widget.score,
                    color: color,
                    trackColor: trackColor,
                    strokeWidth: 9,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(score * 100).toInt()}%',
                      style: AppTextStyles.scoreDisplay(color),
                    ),
                    const SizedBox(height: 2),
                    Text('DISCIPLINE',
                        style: AppTextStyles.caption(
                            AppColors.textMuted(context))),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Text(
                        '${widget.earnedPoints} / ${widget.totalPoints} pts',
                        style: AppTextStyles.caption(color)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, 2 * math.pi, false,
      Paint()
        ..color = trackColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    if (progress <= 0) return;

    final sweepAngle = 2 * math.pi * progress;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(
      rect, -math.pi / 2, sweepAngle, false,
      Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    final endAngle = -math.pi / 2 + sweepAngle;
    final dotX = center.dx + radius * math.cos(endAngle);
    final dotY = center.dy + radius * math.sin(endAngle);

    canvas.drawCircle(Offset(dotX, dotY), strokeWidth / 2,
        Paint()
          ..color = color
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    canvas.drawCircle(
        Offset(dotX, dotY), strokeWidth / 2, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}