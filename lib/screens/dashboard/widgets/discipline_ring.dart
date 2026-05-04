import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../../core/theme/app_colors.dart';

class DisciplineRing extends StatefulWidget {
  final double score;
  final int completed, total, earnedPoints, totalPoints;

  const DisciplineRing({
    super.key,
    required this.score,
    required this.completed,
    required this.total,
    required this.earnedPoints,
    required this.totalPoints,
  });

  @override
  State<DisciplineRing> createState() => _DisciplineRingState();
}

class _DisciplineRingState extends State<DisciplineRing>
    with TickerProviderStateMixin {
  late AnimationController _prog, _pulse;
  late Animation<double> _progAnim, _pulseAnim, _countAnim;
  double _prev = 0;

  @override
  void initState() {
    super.initState();
    _prog  = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2600))
      ..repeat(reverse: true);
    _progAnim  = CurvedAnimation(
        parent: _prog, curve: Curves.easeOutCubic);
    _pulseAnim = Tween<double>(begin: 0.985, end: 1.018).animate(
        CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
    _countAnim = Tween<double>(begin: 0, end: widget.score)
        .animate(_progAnim);
    _prog.forward();
  }

  @override
  void didUpdateWidget(DisciplineRing old) {
    super.didUpdateWidget(old);
    if (old.score != widget.score) {
      _prev      = old.score;
      _countAnim = Tween<double>(begin: _prev, end: widget.score)
          .animate(_progAnim);
      _prog..reset()..forward();
    }
  }

  @override
  void dispose() {
    _prog.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.textPrimary(context);
    final muted   = AppColors.textMuted(context);
    final surface = AppColors.surface(context);
    final border  = AppColors.border(context);
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final trackC  = isDark
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFEAEAEA);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Row(
        children: [
          // Ring
          AnimatedBuilder(
            animation: Listenable.merge([_progAnim, _pulseAnim]),
            builder: (_, __) {
              final val = _countAnim.value;
              return Transform.scale(
                scale: _pulseAnim.value,
                child: SizedBox(
                  width: 96, height: 96,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(96, 96),
                        painter: _RingPainter(
                          progress:
                              _progAnim.value * widget.score,
                          color: primary,
                          trackColor: trackC,
                        ),
                      ),
                      Text(
                        '${(val * 100).toInt()}%',
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: primary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: 22),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DISCIPLINE',
                    style: GoogleFonts.dmSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: muted,
                      letterSpacing: 1.8,
                    )),
                const SizedBox(height: 5),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: widget.score),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => Text(
                    '${(v * 100).toInt()}%',
                    style: GoogleFonts.figtree(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: primary,
                      letterSpacing: -1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.completed} of ${widget.total} done',
                  style: GoogleFonts.dmSans(
                      fontSize: 12, color: muted),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0,
                      end: widget.total == 0
                          ? 0.0
                          : widget.completed / widget.total,
                    ),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => LinearProgressIndicator(
                      value: v,
                      minHeight: 3,
                      backgroundColor: trackC,
                      valueColor: AlwaysStoppedAnimation(primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color, trackColor;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 7;
    final p = Paint()
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2, 2 * math.pi, false,
      p..color = trackColor,
    );
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -math.pi / 2, 2 * math.pi * progress, false,
        p..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}