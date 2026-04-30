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
import 'screens/review/review_screen.dart';

class PulseApp extends StatelessWidget {
  const PulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'pulse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: tp.themeMode,
      home: const HomeScreen(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Shell — floating nav bar, edge-to-edge
// ─────────────────────────────────────────────────────────────
class PulseShell extends StatefulWidget {
  const PulseShell({super.key});

  @override
  State<PulseShell> createState() => _PulseShellState();
}

class _PulseShellState extends State<PulseShell>
    with TickerProviderStateMixin {
  int _index = 0;

  final _screens = const [
    DashboardScreen(),
    GymScreen(),
    ReviewScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isDark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark)
          .copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.bg(context),
        extendBody: true,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) {
            return FadeTransition(
              opacity: CurvedAnimation(
                  parent: anim, curve: Curves.easeOut),
              child: child,
            );
          },
          child: KeyedSubtree(
            key: ValueKey(_index),
            child: _screens[_index],
          ),
        ),
        bottomNavigationBar: _FloatingNavBar(
          current: _index,
          onTap: (i) => setState(() => _index = i),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Floating glassmorphic nav bar
// ─────────────────────────────────────────────────────────────
class _FloatingNavBar extends StatelessWidget {
  final int current;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({required this.current, required this.onTap});

  static const _items = [
    _NavItem(Icons.home_outlined,           Icons.home_rounded,           'Home'),
    _NavItem(Icons.fitness_center_outlined, Icons.fitness_center_rounded, 'Gym'),
    _NavItem(Icons.nights_stay_outlined,    Icons.nights_stay_rounded,    'Review'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final primary  = AppColors.textPrimary(context);
    final muted    = AppColors.textMuted(context);
    final surface  = AppColors.surface(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Container(
          height: 62,
          decoration: BoxDecoration(
            color: surface.withOpacity(isDark ? 0.92 : 0.94),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: primary.withOpacity(isDark ? 0.10 : 0.08),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.40 : 0.10),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.20 : 0.05),
                blurRadius: 6,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: List.generate(_items.length, (i) {
              return Expanded(
                child: _NavButton(
                  item: _items[i],
                  isActive: i == current,
                  primary: primary,
                  muted: muted,
                  isDark: isDark,
                  onTap: () => onTap(i),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData inactive, active;
  final String label;
  const _NavItem(this.inactive, this.active, this.label);
}

class _NavButton extends StatefulWidget {
  final _NavItem item;
  final bool isActive, isDark;
  final Color primary, muted;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.isActive,
    required this.primary,
    required this.muted,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.88)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) async {
        await _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                widget.isActive ? widget.item.active : widget.item.inactive,
                key: ValueKey(widget.isActive),
                size: 22,
                color: widget.isActive
                    ? widget.primary
                    : widget.muted,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: widget.isActive
                    ? FontWeight.w700
                    : FontWeight.w400,
                color: widget.isActive ? widget.primary : widget.muted,
              ),
              child: Text(widget.item.label),
            ),
          ],
        ),
      ),
    );
  }
}