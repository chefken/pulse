import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/score_provider.dart';
import '../../providers/streak_provider.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final score  = context.watch<ScoreProvider>();
    final streak = context.watch<StreakProvider>();

    final bg      = AppColors.bg(context);
    final surface = AppColors.surface(context);
    final border  = AppColors.border(context);
    final primary = AppColors.textPrimary(context);
    final muted   = AppColors.textMuted(context);
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final trackC  = isDark
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFEAEAEA);

    final records = score.last30Days;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Progress', style: GoogleFonts.dmSans(
                      fontSize: 20, fontWeight: FontWeight.w600,
                      color: primary, letterSpacing: -0.4,
                    )),

                    const SizedBox(height: 22),

                    // Stats
                    Row(children: [
                      _Stat(label: 'Streak', value: '${streak.currentStreak}d',
                          surface: surface, border: border,
                          primary: primary, muted: muted),
                      const SizedBox(width: 10),
                      _Stat(label: 'Best', value: '${streak.longestStreak}d',
                          surface: surface, border: border,
                          primary: primary, muted: muted),
                      const SizedBox(width: 10),
                      _Stat(
                          label: 'Consistency',
                          value: '${streak.consistency.toStringAsFixed(0)}%',
                          surface: surface, border: border,
                          primary: primary, muted: muted),
                    ]),

                    const SizedBox(height: 18),

                    // Chart
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: border, width: 0.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Discipline — 30 days',
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: muted, letterSpacing: 0.4,
                              )),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 140,
                            child: records.length < 2
                                ? Center(
                                    child: Text(
                                      'Not enough data yet.',
                                      style: GoogleFonts.dmSans(
                                          fontSize: 13, color: muted),
                                    ),
                                  )
                                : LineChart(
                                    LineChartData(
                                      gridData:   FlGridData(show: false),
                                      titlesData: FlTitlesData(show: false),
                                      borderData: FlBorderData(show: false),
                                      minX: 0,
                                      maxX: (records.length - 1)
                                          .toDouble()
                                          .clamp(1, 29),
                                      minY: 0,
                                      maxY: 1,
                                      lineTouchData: LineTouchData(
                                        touchTooltipData:
                                            LineTouchTooltipData(
                                          getTooltipColor: (_) =>
                                              primary.withOpacity(0.08),
                                          getTooltipItems: (spots) =>
                                              spots.map((s) =>
                                                LineTooltipItem(
                                                  '${(s.y * 100).toInt()}%',
                                                  GoogleFonts.dmSans(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: primary,
                                                  ),
                                                )).toList(),
                                        ),
                                      ),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: records
                                              .asMap()
                                              .entries
                                              .map((e) => FlSpot(
                                                    e.key.toDouble(),
                                                    e.value.disciplineScore,
                                                  ))
                                              .toList(),
                                          isCurved: true,
                                          curveSmoothness: 0.35,
                                          color: primary,
                                          barWidth: 1.5,
                                          dotData: FlDotData(
                                            show: true,
                                            getDotPainter: (_, __, ___, ____) =>
                                                FlDotCirclePainter(
                                              radius: 2.5,
                                              color: primary,
                                              strokeWidth: 0,
                                              strokeColor: Colors.transparent,
                                            ),
                                          ),
                                          belowBarData: BarAreaData(
                                            show: true,
                                            gradient: LinearGradient(
                                              colors: [
                                                primary.withOpacity(0.10),
                                                primary.withOpacity(0.0),
                                              ],
                                              begin: Alignment.topCenter,
                                              end:   Alignment.bottomCenter,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    duration:
                                        const Duration(milliseconds: 600),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
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

class _Stat extends StatelessWidget {
  final String label, value;
  final Color surface, border, primary, muted;

  const _Stat({
    required this.label, required this.value,
    required this.surface, required this.border,
    required this.primary, required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: GoogleFonts.figtree(
              fontSize: 20, fontWeight: FontWeight.w800,
              color: primary, letterSpacing: -0.5,
            )),
            const SizedBox(height: 2),
            Text(label, style: GoogleFonts.dmSans(
                fontSize: 10, color: muted)),
          ],
        ),
      ),
    );
  }
}