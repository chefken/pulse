import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'providers/theme_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/gym/gym_screen.dart';
import 'screens/progress/progress_screen.dart';
import 'screens/review/review_screen.dart';

class PulseApp extends StatelessWidget {
  const PulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'Pulse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: tp.themeMode,
      home: const HomeScreen(),
    );
  }
}

// ── Shell ─────────────────────────────────────────────────────
class PulseShell extends StatefulWidget {
  const PulseShell({super.key});

  @override
  State<PulseShell> createState() => _PulseShellState();
}

class _PulseShellState extends State<PulseShell> {
  int _index = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    GymScreen(),
    ProgressScreen(),
    ReviewScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final bg        = AppColors.surface(context);
    final border    = AppColors.border(context);
    final primary   = AppColors.textPrimary(context);
    final muted     = AppColors.textMuted(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: AppColors.darkSurface,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: AppColors.lightSurface,
            ),
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.02, 0),
                end: Offset.zero,
              ).animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: child,
            ),
          ),
          child: KeyedSubtree(
            key: ValueKey(_index),
            child: _screens[_index],
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: bg,
            border: Border(top: BorderSide(color: border, width: 1)),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
          ),
          child: SafeArea(
            child: SizedBox(
              height: 60,
              child: Row(
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    index: 0,
                    current: _index,
                    primary: primary,
                    muted: muted,
                    onTap: (i) => setState(() => _index = i),
                  ),
                  _NavItem(
                    icon: Icons.fitness_center_rounded,
                    label: 'Gym',
                    index: 1,
                    current: _index,
                    primary: primary,
                    muted: muted,
                    onTap: (i) => setState(() => _index = i),
                  ),
                  _NavItem(
                    icon: Icons.bar_chart_rounded,
                    label: 'Progress',
                    index: 2,
                    current: _index,
                    primary: primary,
                    muted: muted,
                    onTap: (i) => setState(() => _index = i),
                  ),
                  _NavItem(
                    icon: Icons.nights_stay_rounded,
                    label: 'Review',
                    index: 3,
                    current: _index,
                    primary: primary,
                    muted: muted,
                    onTap: (i) => setState(() => _index = i),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index, current;
  final Color primary, muted;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
    required this.primary,
    required this.muted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? primary.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon,
                  size: 22, color: isActive ? primary : muted),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight:
                    isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? primary : muted,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}