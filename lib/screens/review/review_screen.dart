import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../providers/score_provider.dart';
import '../../providers/theme_provider.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int  _rating = 0;
  bool _saved  = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final r = context.read<ScoreProvider>().todayRecord;
      if (r != null && r.userRating > 0) {
        setState(() {
          _rating = r.userRating;
          _saved  = true;
        });
      }
    });
  }

  void _select(int n) {
    if (_saved) return;
    HapticFeedback.selectionClick();
    setState(() => _rating = n);
  }

  void _save() {
    if (_rating == 0 || _saved) return;
    HapticFeedback.mediumImpact();
    context.read<ScoreProvider>().saveMoodRating(_rating);
    setState(() => _saved = true);
  }

  @override
  Widget build(BuildContext context) {
    final score  = context.watch<ScoreProvider>();
    final isDark = context.watch<ThemeProvider>().isDark;

    final bg      = AppColors.bg(context);
    final surface = AppColors.surface(context);
    final border  = AppColors.border(context);
    final primary = AppColors.textPrimary(context);
    final muted   = AppColors.textMuted(context);
    final trackC  = isDark
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFE8E8E8);

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Review',
                        style: GoogleFonts.dmSans(
                          fontSize: 20, fontWeight: FontWeight.w600,
                          color: primary, letterSpacing: -0.4,
                        )),
                    Text(
                      PulseDateUtils.formatDisplay(DateTime.now()),
                      style: GoogleFonts.dmSans(
                          fontSize: 12, color: muted),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // Mood card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: border, width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('How was your day?',
                          style: GoogleFonts.dmSans(
                            fontSize: 15, fontWeight: FontWeight.w600,
                            color: primary, letterSpacing: -0.3,
                          )),
                      const SizedBox(height: 4),
                      Text('Rate from 1 to 10.',
                          style: GoogleFonts.dmSans(
                              fontSize: 12, color: muted)),

                      const SizedBox(height: 22),

                      // Big number
                      Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          transitionBuilder: (child, anim) =>
                              FadeTransition(opacity: anim, child: child),
                          child: Text(
                            _rating == 0 ? '—' : '$_rating',
                            key: ValueKey(_rating),
                            style: GoogleFonts.figtree(
                              fontSize: 64,
                              fontWeight: FontWeight.w800,
                              color:
                                  _rating == 0 ? muted : primary,
                              letterSpacing: -2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Dots
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: List.generate(10, (i) {
                          final n        = i + 1;
                          final selected = _rating == n;
                          return GestureDetector(
                            onTap: () => _select(n),
                            child: AnimatedContainer(
                              duration:
                                  const Duration(milliseconds: 160),
                              curve: Curves.easeOut,
                              width: selected ? 30 : 26,
                              height: selected ? 30 : 26,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: selected
                                    ? primary
                                    : Colors.transparent,
                                border: Border.all(
                                  color: selected
                                      ? primary
                                      : border,
                                  width: selected ? 0 : 0.7,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '$n',
                                  style: GoogleFonts.dmSans(
                                    fontSize: selected ? 12 : 11,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                    color:
                                        selected ? bg : muted,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 22),

                      // Save
                      SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: _save,
                          child: AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            decoration: BoxDecoration(
                              color: _saved
                                  ? primary.withOpacity(0.08)
                                  : _rating > 0
                                      ? primary
                                      : primary.withOpacity(0.12),
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                            child: Text(
                              _saved ? 'Saved' : 'Save',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _saved
                                    ? muted
                                    : _rating > 0
                                        ? bg
                                        : muted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Discipline graph
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _DisciplineGraph(
                  score: score,
                  surface: surface,
                  border: border,
                  primary: primary,
                  muted: muted,
                  trackColor: trackC,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Discipline graph — fixed and stable
// ─────────────────────────────────────────────────────────────
class _DisciplineGraph extends StatefulWidget {
  final ScoreProvider score;
  final Color surface, border, primary, muted, trackColor;

  const _DisciplineGraph({
    required this.score,
    required this.surface,
    required this.border,
    required this.primary,
    required this.muted,
    required this.trackColor,
  });

  @override
  State<_DisciplineGraph> createState() => _DisciplineGraphState();
}

class _DisciplineGraphState extends State<_DisciplineGraph>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1000));
    _anim = CurvedAnimation(
        parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final records = widget.score.last30Days;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: widget.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Discipline',
                  style: GoogleFonts.dmSans(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: widget.primary, letterSpacing: -0.2,
                  )),
              Text('30 days',
                  style: GoogleFonts.dmSans(
                      fontSize: 11, color: widget.muted)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 130,
            child: records.length < 2
                ? Center(
                    child: Text('Not enough data yet.',
                        style: GoogleFonts.dmSans(
                            fontSize: 13, color: widget.muted)),
                  )
                : AnimatedBuilder(
                    animation: _anim,
                    builder: (_, __) {
                      final count = (records.length * _anim.value)
                          .ceil()
                          .clamp(2, records.length);
                      final visible = records.sublist(0, count);
                      final maxX    = (records.length - 1)
                          .toDouble()
                          .clamp(1.0, 29.0);

                      final spots = visible.asMap().entries.map((e) {
                        return FlSpot(
                          e.key.toDouble(),
                          e.value.disciplineScore
                              .clamp(0.0, 1.0),
                        );
                      }).toList();

                      return LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 0.5,
                            getDrawingHorizontalLine: (_) => FlLine(
                              color: widget.trackColor,
                              strokeWidth: 0.7,
                              dashArray: [4, 6],
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 0.5,
                                reservedSize: 28,
                                getTitlesWidget: (val, _) {
                                  if (val != 0.0 &&
                                      val != 0.5 &&
                                      val != 1.0) {
                                    return const SizedBox();
                                  }
                                  return Text(
                                    '${(val * 100).toInt()}',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 9,
                                      color: widget.muted,
                                    ),
                                  );
                                },
                              ),
                            ),
                            rightTitles: const AxisTitles(
                                sideTitles:
                                    SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles:
                                    SideTitles(showTitles: false)),
                            bottomTitles: const AxisTitles(
                                sideTitles:
                                    SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: maxX,
                          minY: 0,
                          maxY: 1,
                          clipData: const FlClipData.all(),
                          lineTouchData: LineTouchData(
                            touchTooltipData:
                                LineTouchTooltipData(
                              getTooltipColor: (_) =>
                                  widget.primary.withOpacity(0.08),
                              getTooltipItems: (spots) =>
                                  spots
                                      .map((s) => LineTooltipItem(
                                            '${(s.y * 100).toInt()}%',
                                            GoogleFonts.dmSans(
                                              fontSize: 11,
                                              fontWeight:
                                                  FontWeight.w600,
                                              color: widget.primary,
                                            ),
                                          ))
                                      .toList(),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              curveSmoothness: 0.28,
                              color: widget.primary,
                              barWidth: 1.8,
                              dotData: FlDotData(
                                show: records.length <= 14,
                                getDotPainter:
                                    (_, __, ___, ____) =>
                                        FlDotCirclePainter(
                                  radius: 2.5,
                                  color: widget.primary,
                                  strokeWidth: 0,
                                  strokeColor: Colors.transparent,
                                ),
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    widget.primary.withOpacity(0.12),
                                    widget.primary.withOpacity(0.0),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                        duration: Duration.zero,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}