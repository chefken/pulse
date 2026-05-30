import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../providers/score_provider.dart';

class HomeCalendarSheet extends StatefulWidget {
  const HomeCalendarSheet({super.key});

  @override
  State<HomeCalendarSheet> createState() => _HomeCalendarSheetState();
}

class _HomeCalendarSheetState extends State<HomeCalendarSheet> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  void _prev() =>
      setState(() => _month = DateTime(_month.year, _month.month - 1));

  void _next() {
    final now  = DateTime.now();
    final next = DateTime(_month.year, _month.month + 1);
    if (!next.isAfter(DateTime(now.year, now.month))) {
      setState(() => _month = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final score   = context.watch<ScoreProvider>();
    final primary = AppColors.textPrimary(context);
    final muted   = AppColors.textMuted(context);
    final bg      = AppColors.bg(context);
    final surface = AppColors.surface(context);
    final border  = AppColors.border(context);
    final dot     = AppColors.dot(context);

    // Sunday-first grid
    final firstDay    = DateTime(_month.year, _month.month, 1);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final startOffset = firstDay.weekday % 7;
    final today       = PulseDateUtils.today;
    const hdrs        = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollCtrl) {
        return Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(top: BorderSide(color: border, width: 0.5)),
          ),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  width: 32, height: 3,
                  margin: const EdgeInsets.only(top: 12, bottom: 4),
                  decoration: BoxDecoration(
                    color: border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Month nav
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: _prev,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.chevron_left_rounded,
                            size: 22, color: muted),
                      ),
                    ),
                    Text(DateFormat('MMMM yyyy').format(_month),
                        style: GoogleFonts.dmSans(
                          fontSize: 15, fontWeight: FontWeight.w600,
                          color: primary,
                        )),
                    GestureDetector(
                      onTap: _next,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.chevron_right_rounded,
                            size: 22, color: muted),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Weekday headers
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: hdrs.map((h) => Expanded(
                    child: Center(
                      child: Text(h,
                          style: GoogleFonts.dmSans(
                            fontSize: 11, fontWeight: FontWeight.w600,
                            color: muted,
                          )),
                    ),
                  )).toList(),
                ),
              ),

              const SizedBox(height: 8),

              // Grid (fixed height, scrollable content below)
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                        childAspectRatio: 1,
                      ),
                      itemCount: startOffset + daysInMonth,
                      itemBuilder: (_, idx) {
                        if (idx < startOffset) return const SizedBox();

                        final day  = idx - startOffset + 1;
                        final date =
                            DateTime(_month.year, _month.month, day);
                        final key  = PulseDateUtils.formatDateKey(date);

                        final isToday  =
                            PulseDateUtils.isSameDay(date, today);
                        final isFuture = date.isAfter(today);
                        final record   = score.recordFor(key);
                        final hasData  = record != null &&
                            (record.disciplineScore > 0 ||
                                record.userRating > 0);

                        return GestureDetector(
                          onTap: () => _showDaySheet(
                            context, date, key, record,
                            primary, muted, bg, border,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isToday
                                  ? primary.withOpacity(0.08)
                                  : Colors.transparent,
                              border: isToday
                                  ? Border.all(
                                      color: primary, width: 1.2)
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Text('$day',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      fontWeight: isToday
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: isFuture
                                          ? muted.withOpacity(0.30)
                                          : primary,
                                    )),
                                if (hasData)
                                  Container(
                                    width: 4, height: 4,
                                    margin:
                                        const EdgeInsets.only(top: 2),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: dot,
                                    ),
                                  )
                                else
                                  const SizedBox(height: 6),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDaySheet(
    BuildContext context,
    DateTime date,
    String dateKey,
    dynamic record,
    Color primary,
    Color muted,
    Color bg,
    Color border,
  ) {
    final disciplinePercent = record != null
        ? (record.disciplineScore * 100).toInt()
        : null;
    final moodRating   = record?.userRating ?? 0;
    final habitTitles  =
        (record?.completedHabitTitles as List<String>?) ?? <String>[];
    final taskTitles   =
        (record?.completedTaskTitles  as List<String>?) ?? <String>[];

    const days = [
      'SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY',
      'THURSDAY', 'FRIDAY', 'SATURDAY',
    ];
    final dayLabel = days[date.weekday % 7];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: border, width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 32, height: 3,
                margin: const EdgeInsets.only(top: 12, bottom: 22),
                decoration: BoxDecoration(
                  color: border, borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Date heading
            Text(dayLabel,
                style: GoogleFonts.dmSans(
                  fontSize: 10, fontWeight: FontWeight.w600,
                  color: muted, letterSpacing: 1.2,
                )),
            const SizedBox(height: 3),
            Text(DateFormat('d MMMM yyyy').format(date),
                style: GoogleFonts.dmSans(
                  fontSize: 18, fontWeight: FontWeight.w700,
                  color: primary, letterSpacing: -0.4,
                )),

            const SizedBox(height: 20),

            if (disciplinePercent == null &&
                moodRating == 0 &&
                habitTitles.isEmpty &&
                taskTitles.isEmpty)
              Text('No activity logged.',
                  style: GoogleFonts.dmSans(
                      fontSize: 14, color: muted))
            else ...[

              // Discipline + Mood row
              Row(
                children: [
                  if (disciplinePercent != null)
                    Expanded(
                      child: _MetaCol(
                        label: 'Discipline',
                        value: '$disciplinePercent%',
                        primary: primary, muted: muted,
                      ),
                    ),
                  if (disciplinePercent != null)
                    const SizedBox(width: 24),
                  Expanded(
                    child: _MetaCol(
                      label: 'Mood',
                      value: moodRating > 0 ? '$moodRating/10' : '—',
                      primary: primary, muted: muted,
                    ),
                  ),
                ],
              ),

              // Habits
              if (habitTitles.isNotEmpty) ...[
                const SizedBox(height: 18),
                Container(height: 0.5, color: border),
                const SizedBox(height: 14),
                _SheetLabel('Habits', muted),
                const SizedBox(height: 8),
                ...habitTitles.map(
                    (h) => _SheetBullet(h, primary, muted)),
              ],

              // Tasks
              if (taskTitles.isNotEmpty) ...[
                const SizedBox(height: 14),
                _SheetLabel('Tasks', muted),
                const SizedBox(height: 8),
                ...taskTitles.map(
                    (t) => _SheetBullet(t, primary, muted)),
              ],
            ],

            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

// ── Shared sheet widgets ──────────────────────────────────────

class _MetaCol extends StatelessWidget {
  final String label, value;
  final Color primary, muted;
  const _MetaCol({
    required this.label, required this.value,
    required this.primary, required this.muted,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: GoogleFonts.dmSans(
              fontSize: 9, fontWeight: FontWeight.w600,
              color: muted, letterSpacing: 1.4,
            )),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.dmSans(
              fontSize: 18, fontWeight: FontWeight.w700,
              color: primary, letterSpacing: -0.5,
            )),
      ],
    );
  }
}

class _SheetLabel extends StatelessWidget {
  final String text;
  final Color muted;
  const _SheetLabel(this.text, this.muted);
  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(),
      style: GoogleFonts.dmSans(
        fontSize: 9, fontWeight: FontWeight.w600,
        color: muted, letterSpacing: 1.4,
      ));
}

class _SheetBullet extends StatelessWidget {
  final String text;
  final Color primary, muted;
  const _SheetBullet(this.text, this.primary, this.muted);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5, right: 9),
            child: Container(
              width: 4, height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: muted.withOpacity(0.45),
              ),
            ),
          ),
          Expanded(child: Text(text,
              style: GoogleFonts.dmSans(
                  fontSize: 13, color: primary))),
        ],
      ),
    );
  }
}