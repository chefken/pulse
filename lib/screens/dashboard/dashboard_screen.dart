import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../models/task.dart';
import '../../providers/task_provider.dart';
import '../../providers/score_provider.dart';
import '../../providers/streak_provider.dart';
import '../../providers/theme_provider.dart';
import 'widgets/discipline_ring.dart';
import 'widgets/task_tile.dart';
import 'widgets/week_tracker.dart';
import 'widgets/add_task_sheet.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  void _sync() {
    final tasks  = context.read<TaskProvider>();
    final score  = context.read<ScoreProvider>();
    final streak = context.read<StreakProvider>();

    score.updateTodayScore(
      earned: tasks.earnedPoints,
      total:  tasks.totalPoints,
      completedTasks: tasks.completedToday.length,
      totalTasks:     tasks.todayTasks.length,
      completedHabitTitles: tasks.habits
          .where((h) => h.isCompleted)
          .map((h) => h.title)
          .toList(),
      completedTaskTitles: tasks.todayTasks
          .where((t) => t.type == TaskType.oneTime && t.isCompleted)
          .map((t) => t.title)
          .toList(),
    );
    streak.recalculate(score.allRecords);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  void _openAdd() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTaskSheet(),
    ).then((_) =>
        WidgetsBinding.instance.addPostFrameCallback((_) => _sync()));
  }

  @override
  Widget build(BuildContext context) {
    final tasks  = context.watch<TaskProvider>();
    final score  = context.watch<ScoreProvider>();
    final streak = context.watch<StreakProvider>();
    final isDark = context.watch<ThemeProvider>().isDark;

    final bg       = AppColors.bg(context);
    final surface  = AppColors.surface(context);
    final border   = AppColors.border(context);
    final primary  = AppColors.textPrimary(context);
    final muted    = AppColors.textMuted(context);
    final surfHigh = AppColors.surfaceHigh(context);

    final today     = tasks.todayTasks;
    final habits    = today.where((t) => t.type == TaskType.habit).toList();
    final oneTimers =
        today.where((t) => t.type == TaskType.oneTime).toList();
    final completed = tasks.completedToday.length;
    final total     = today.length;

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
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            PulseDateUtils.formatDisplay(DateTime.now())
                                .toUpperCase(),
                            style: GoogleFonts.dmSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: muted,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            PulseDateUtils.greeting(),
                            style: GoogleFonts.dmSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: primary,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Streak
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: surfHigh,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: border, width: 0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🔥',
                              style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 5),
                          Text(
                            '${streak.currentStreak}',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    _ThemeToggle(isDark: isDark),
                  ],
                ),
              ),
            ),

            // Discipline ring
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: DisciplineRing(
                  score: score.todayScore,
                  completed: completed,
                  total: total,
                  earnedPoints: tasks.earnedPoints,
                  totalPoints:  tasks.totalPoints,
                ),
              ),
            ),

            // Week tracker
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: WeekTracker(score: score, tasks: tasks),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 30)),

            // Habits section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: _SectionLabel(
                  title: 'Daily habits',
                  primary: primary,
                  muted: muted,
                  bg: bg,
                  onAdd: _openAdd,
                ),
              ),
            ),
            habits.isEmpty
                ? SliverToBoxAdapter(
                    child: _EmptyHint(
                      text: 'No habits yet.',
                      muted: muted,
                      surface: surface,
                      border: border,
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => TaskTile(
                          key: ValueKey(habits[i].id),
                          task: habits[i],
                          onToggle: () {
                            tasks.toggleTask(habits[i].id);
                            WidgetsBinding.instance
                                .addPostFrameCallback((_) => _sync());
                          },
                          onSkip: () {
                            HapticFeedback.lightImpact();
                            tasks.skipToday(habits[i].id);
                            WidgetsBinding.instance
                                .addPostFrameCallback((_) => _sync());
                          },
                          onDelete: () {
                            tasks.deleteTask(habits[i].id);
                            WidgetsBinding.instance
                                .addPostFrameCallback((_) => _sync());
                          },
                        ),
                        childCount: habits.length,
                      ),
                    ),
                  ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // Today tasks
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: _SectionLabel(
                  title: 'Today',
                  primary: primary,
                  muted: muted,
                  bg: bg,
                  onAdd: _openAdd,
                ),
              ),
            ),
            oneTimers.isEmpty
                ? SliverToBoxAdapter(
                    child: _EmptyHint(
                      text: 'Nothing planned.',
                      muted: muted,
                      surface: surface,
                      border: border,
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => TaskTile(
                          key: ValueKey(oneTimers[i].id),
                          task: oneTimers[i],
                          onToggle: () {
                            tasks.toggleTask(oneTimers[i].id);
                            WidgetsBinding.instance
                                .addPostFrameCallback((_) => _sync());
                          },
                          onDelete: () {
                            tasks.deleteTask(oneTimers[i].id);
                            WidgetsBinding.instance
                                .addPostFrameCallback((_) => _sync());
                          },
                        ),
                        childCount: oneTimers.length,
                      ),
                    ),
                  ),

            // Space for floating nav
            const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        ),
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  final bool isDark;
  const _ThemeToggle({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final primary  = AppColors.textPrimary(context);
    final surfHigh = AppColors.surfaceHigh(context);
    final border   = AppColors.border(context);
    final bg       = AppColors.bg(context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        context.read<ThemeProvider>().toggle();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        width: 44, height: 24,
        decoration: BoxDecoration(
          color: surfHigh,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: border, width: 0.5),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOutCubic,
          alignment: isDark
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Container(
              width: 16, height: 16,
              decoration: BoxDecoration(
                  color: primary, shape: BoxShape.circle),
              child: Icon(
                isDark
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                size: 9,
                color: bg,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  final Color primary, muted, bg;
  final VoidCallback onAdd;

  const _SectionLabel({
    required this.title, required this.primary,
    required this.muted, required this.bg, required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: GoogleFonts.dmSans(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: muted, letterSpacing: 0.6,
            )),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, size: 13, color: bg),
                const SizedBox(width: 3),
                Text('Add',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: bg,
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  final Color muted, surface, border;

  const _EmptyHint({
    required this.text, required this.muted,
    required this.surface, required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 0.5),
        ),
        child: Center(
          child: Text(text,
              style: GoogleFonts.dmSans(
                fontSize: 13, color: muted,
              )),
        ),
      ),
    );
  }
}