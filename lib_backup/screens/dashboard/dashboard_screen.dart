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
import 'widgets/streak_badge.dart';
import 'widgets/stats_row.dart';
import '../tasks/add_task_sheet.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  void _syncScore() {
    final tasks  = context.read<TaskProvider>();
    final score  = context.read<ScoreProvider>();
    final streak = context.read<StreakProvider>();
    score.updateTodayScore(
      earned: tasks.earnedPoints,
      total: tasks.totalPoints,
      completedTasks: tasks.completedToday.length,
      totalTasks: tasks.todayTasks.length,
    );
    streak.recalculate(score.allRecords);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _syncScore());
  }

  void _openAddTask() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTaskSheet(),
    ).then((_) => WidgetsBinding.instance
        .addPostFrameCallback((_) => _syncScore()));
  }

  @override
  Widget build(BuildContext context) {
    final tasks   = context.watch<TaskProvider>();
    final score   = context.watch<ScoreProvider>();
    final streak  = context.watch<StreakProvider>();
    final isDark  = Theme.of(context).brightness == Brightness.dark;

    final bg        = AppColors.bg(context);
    final surface   = AppColors.surface(context);
    final border    = AppColors.border(context);
    final primary   = AppColors.textPrimary(context);
    final secondary = AppColors.textSecondary(context);
    final muted     = AppColors.textMuted(context);

    final today     = tasks.todayTasks;
    final habits    = today.where((t) => t.type == TaskType.habit).toList();
    final oneTimers =
        today.where((t) => t.type == TaskType.oneTime).toList();
    final completed = tasks.completedToday.length;
    final total     = today.length;
    final missed    = total - completed;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [

            // ── Top bar ──────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          PulseDateUtils.formatDate(DateTime.now())
                              .toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: muted,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          PulseDateUtils.greeting(),
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        StreakBadge(streak: streak.currentStreak),
                        const SizedBox(width: 10),
                        _ThemeToggle(),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Discipline card ───────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    children: [
                      DisciplineRing(
                        score: score.todayScore,
                        earnedPoints: tasks.earnedPoints,
                        totalPoints: tasks.totalPoints,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DISCIPLINE\nSCORE',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: muted,
                                letterSpacing: 0.6,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TweenAnimationBuilder<double>(
                              tween: Tween(
                                  begin: 0, end: score.todayScore),
                              duration:
                                  const Duration(milliseconds: 1000),
                              curve: Curves.easeOutCubic,
                              builder: (_, v, __) {
                                final c = v >= 0.7
                                    ? AppColors.success
                                    : v >= 0.4
                                        ? primary
                                        : AppColors.danger;
                                return Text(
                                  '${(v * 100).toInt()}%',
                                  style: GoogleFonts.inter(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: c,
                                    letterSpacing: -1.2,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(100),
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(
                                    begin: 0,
                                    end: total == 0
                                        ? 0.0
                                        : completed / total),
                                duration: const Duration(
                                    milliseconds: 800),
                                curve: Curves.easeOutCubic,
                                builder: (_, v, __) {
                                  final c = v >= 0.7
                                      ? AppColors.success
                                      : v >= 0.4
                                          ? primary
                                          : AppColors.danger;
                                  return LinearProgressIndicator(
                                    value: v,
                                    minHeight: 5,
                                    backgroundColor: border,
                                    valueColor:
                                        AlwaysStoppedAnimation(c),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$completed / $total tasks done',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Stats row ─────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: StatsRow(
                  completed: completed,
                  total: total,
                  missed: missed,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // ── Habits section ────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                child: _SectionHeader(
                  title: 'Daily Habits',
                  icon: Icons.repeat_rounded,
                  primary: primary,
                  muted: muted,
                  bg: bg,
                  onAdd: _openAddTask,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),

            habits.isEmpty
                ? SliverToBoxAdapter(
                    child: _EmptySection(
                      message: 'No habits yet. Build your routine.',
                      surface: surface,
                      border: border,
                      muted: muted,
                      onAdd: _openAddTask,
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => TaskTile(
                          key: ValueKey(habits[i].id),
                          task: habits[i],
                          onToggle: () {
                            context
                                .read<TaskProvider>()
                                .toggleTask(habits[i].id);
                            WidgetsBinding.instance
                                .addPostFrameCallback(
                                    (_) => _syncScore());
                          },
                          onSkip: () {
                            HapticFeedback.lightImpact();
                            context
                                .read<TaskProvider>()
                                .skipToday(habits[i].id);
                            WidgetsBinding.instance
                                .addPostFrameCallback(
                                    (_) => _syncScore());
                          },
                          onDelete: () {
                            context
                                .read<TaskProvider>()
                                .deleteTask(habits[i].id);
                            WidgetsBinding.instance
                                .addPostFrameCallback(
                                    (_) => _syncScore());
                          },
                        ),
                        childCount: habits.length,
                      ),
                    ),
                  ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── One-time tasks ────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                child: _SectionHeader(
                  title: "Today's Tasks",
                  icon: Icons.check_circle_outline_rounded,
                  primary: primary,
                  muted: muted,
                  bg: bg,
                  onAdd: _openAddTask,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),

            oneTimers.isEmpty
                ? SliverToBoxAdapter(
                    child: _EmptySection(
                      message: 'No tasks for today.',
                      surface: surface,
                      border: border,
                      muted: muted,
                      onAdd: _openAddTask,
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => TaskTile(
                          key: ValueKey(oneTimers[i].id),
                          task: oneTimers[i],
                          onToggle: () {
                            context
                                .read<TaskProvider>()
                                .toggleTask(oneTimers[i].id);
                            WidgetsBinding.instance
                                .addPostFrameCallback(
                                    (_) => _syncScore());
                          },
                          onDelete: () {
                            context
                                .read<TaskProvider>()
                                .deleteTask(oneTimers[i].id);
                            WidgetsBinding.instance
                                .addPostFrameCallback(
                                    (_) => _syncScore());
                          },
                        ),
                        childCount: oneTimers.length,
                      ),
                    ),
                  ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

// ── Theme Toggle ──────────────────────────────────────────────
class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context) {
    final isDark   = context.watch<ThemeProvider>().isDark;
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
        duration: const Duration(milliseconds: 250),
        width: 42, height: 24,
        decoration: BoxDecoration(
          color: surfHigh,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: border),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment:
              isDark ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Container(
              width: 18, height: 18,
              decoration: BoxDecoration(
                  color: primary, shape: BoxShape.circle),
              child: Icon(
                isDark
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                size: 10,
                color: bg,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color primary, muted, bg;
  final VoidCallback onAdd;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.primary,
    required this.muted,
    required this.bg,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: primary,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.add_rounded, size: 13, color: bg),
                const SizedBox(width: 4),
                Text(
                  'Add',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: bg,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Empty Section ─────────────────────────────────────────────
class _EmptySection extends StatelessWidget {
  final String message;
  final Color surface, border, muted;
  final VoidCallback onAdd;

  const _EmptySection({
    required this.message,
    required this.surface,
    required this.border,
    required this.muted,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onAdd,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: Center(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: muted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}