import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../providers/score_provider.dart';
import '../../providers/task_provider.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _rating = 0;
  bool _saved = false;

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

  void _save() {
    if (_rating == 0) return;
    HapticFeedback.mediumImpact();
    context.read<ScoreProvider>().saveMoodRating(_rating);
    setState(() => _saved = true);
  }

  @override
  Widget build(BuildContext context) {
    final score = context.watch<ScoreProvider>();
    final tasks = context.watch<TaskProvider>();

    final bg      = AppColors.bg(context);
    final surface = AppColors.surface(context);
    final border  = AppColors.border(context);
    final primary = AppColors.textPrimary(context);
    final muted   = AppColors.textMuted(context);

    final todayRecord = score.todayRecord;
    final completed   = tasks.completedToday.length;
    final total       = tasks.todayTasks.length;
    final todayScore  = score.todayScore;

    // Past 7 days with mood ratings
    final today  = PulseDateUtils.today;
    final recent = List.generate(7, (i) {
      final d = today.subtract(Duration(days: 6 - i));
      return score.recordFor(PulseDateUtils.formatDateKey(d));
    });

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
                    Text('Review', style: GoogleFonts.dmSans(
                      fontSize: 20, fontWeight: FontWeight.w600,
                      color: primary, letterSpacing: -0.4,
                    )),
                    Text(
                      PulseDateUtils.formatDisplay(DateTime.now()),
                      style: GoogleFonts.dmSans(
                          fontSize: 12, color: muted),
                    ),

                    const SizedBox(height: 24),

                    // Today summary card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: border, width: 0.5),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _Summary(
                              label: 'Tasks',
                              value: total == 0
                                  ? '—'
                                  : '$completed / $total',
                              primary: primary,
                              muted: muted,
                            ),
                          ),
                          Container(
                            width: 0.5, height: 36,
                            color: border,
                          ),
                          Expanded(
                            child: _Summary(
                              label: 'Score',
                              value: total == 0
                                  ? '—'
                                  : '${(todayScore * 100).toInt()}%',
                              primary: primary,
                              muted: muted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    Text('How was your day?',
                        style: GoogleFonts.dmSans(
                          fontSize: 16, fontWeight: FontWeight.w600,
                          color: primary, letterSpacing: -0.3,
                        )),
                    const SizedBox(height: 6),
                    Text('Rate your mood from 1 to 10.',
                        style: GoogleFonts.dmSans(
                            fontSize: 13, color: muted)),

                    const SizedBox(height: 22),

                    // Rating circles
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(10, (i) {
                        final n        = i + 1;
                        final selected = _rating == n;
                        return GestureDetector(
                          onTap: _saved
                              ? null
                              : () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _rating = n);
                                },
                          child: AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 180),
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selected
                                  ? primary
                                  : Colors.transparent,
                              border: Border.all(
                                color: selected ? primary : border,
                                width: selected ? 0 : 0.7,
                              ),
                            ),
                            child: Center(
                              child: Text('$n',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                    color: selected ? bg : muted,
                                  )),
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 22),

                    // Mismatch insight
                    if (_rating > 0 && total > 0) ...[
                      _MismatchCard(
                        rating: _rating,
                        actualScore: todayScore,
                        surface: surface,
                        border: border,
                        primary: primary,
                        muted: muted,
                      ),
                      const SizedBox(height: 18),
                    ],

                    // Save
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: _saved ? null : _save,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              vertical: 15),
                          decoration: BoxDecoration(
                            color: _saved
                                ? primary.withOpacity(0.12)
                                : _rating > 0
                                    ? primary
                                    : primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            _saved ? 'Saved' : 'Save',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _saved ? muted : (_rating > 0 ? bg : muted),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Mood history
                    Text('Recent mood',
                        style: GoogleFonts.dmSans(
                          fontSize: 11, fontWeight: FontWeight.w600,
                          color: muted, letterSpacing: 0.5,
                        )),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: border, width: 0.5),
                      ),
                      child: Column(
                        children: List.generate(7, (i) {
                          final d    = today.subtract(
                              Duration(days: 6 - i));
                          final rec  = recent[i];
                          final mood = rec?.userRating ?? 0;
                          final isToday = i == 6;

                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 90,
                                  child: Text(
                                    isToday
                                        ? 'Today'
                                        : DateFormat('EEE, d MMM')
                                            .format(d),
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      fontWeight: isToday
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: isToday
                                          ? primary
                                          : muted,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: mood == 0
                                      ? Container(
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: border,
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        )
                                      : Stack(
                                          children: [
                                            Container(
                                              height: 4,
                                              decoration: BoxDecoration(
                                                color: border,
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                              ),
                                            ),
                                            FractionallySizedBox(
                                              widthFactor: mood / 10,
                                              child: Container(
                                                height: 4,
                                                decoration: BoxDecoration(
                                                  color: primary,
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 20,
                                  child: Text(
                                    mood == 0 ? '—' : '$mood',
                                    textAlign: TextAlign.right,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: mood == 0
                                          ? muted
                                          : primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
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

class _Summary extends StatelessWidget {
  final String label, value;
  final Color primary, muted;
  const _Summary({
    required this.label, required this.value,
    required this.primary, required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.figtree(
          fontSize: 24, fontWeight: FontWeight.w800,
          color: primary, letterSpacing: -0.8,
        )),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.dmSans(
            fontSize: 11, color: muted)),
      ],
    );
  }
}

class _MismatchCard extends StatelessWidget {
  final int rating;
  final double actualScore;
  final Color surface, border, primary, muted;

  const _MismatchCard({
    required this.rating, required this.actualScore,
    required this.surface, required this.border,
    required this.primary, required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    final rNorm = rating / 10.0;
    final diff  = rNorm - actualScore;
    final String text;
    if (diff.abs() < 0.15) {
      text = 'Your perception aligns with your actual output today.';
    } else if (diff > 0) {
      text = 'You rated yourself higher than your output suggests. Stay objective.';
    } else {
      text = 'You may be underselling yourself — your output was stronger than you feel.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Text(text, style: GoogleFonts.dmSans(
        fontSize: 13, color: muted, height: 1.55,
      )),
    );
  }
}