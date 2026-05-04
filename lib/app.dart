import 'dart:ui';
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
// Shell
// ─────────────────────────────────────────────────────────────
class PulseShell extends StatefulWidget {
  const PulseShell({super.key});

  @override
  State<PulseShell> createState() => _PulseShellState();
}

class _PulseShellState extends State<PulseShell> {
  int _index = 0;

  final _screens = const [
    DashboardScreen(),
    GymScreen(),
    ReviewScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bgColor = AppColors.bg(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isDark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark)
          .copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: bgColor,
        // extendBody lets the body go behind the nav bar
        extendBody: true,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: CurvedAnimation(
                parent: anim, curve: Curves.easeOut),
            child: child,
          ),
          child: KeyedSubtree(
            key: ValueKey(_index),
            child: _screens[_index],
          ),
        ),
        // The nav bar is built as Scaffold.bottomNavigationBar
        // so Flutter handles safe area + elevation correctly
        bottomNavigationBar: _GlassNavBar(
          current: _index,
          isDark: isDark,
          onTap: (i) => setState(() => _index = i),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Frosted glass nav bar
// Key fix: NO Stack/Positioned inside. Pure Column/Row only.
// BackdropFilter wrapped in ClipRRect, no Opacity ancestors.
// ─────────────────────────────────────────────────────────────
class _GlassNavBar extends StatelessWidget {
  final int current;
  final bool isDark;
  final ValueChanged<int> onTap;

  const _GlassNavBar({
    required this.current,
    required this.isDark,
    required this.onTap,
  });

  static const _items = [
    _NavItem(Icons.home_outlined,           Icons.home_rounded,           'Home'),
    _NavItem(Icons.fitness_center_outlined, Icons.fitness_center_rounded, 'Gym'),
    _NavItem(Icons.nights_stay_outlined,    Icons.nights_stay_rounded,    'Review'),
  ];

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.textPrimary(context);
    final muted   = AppColors.textMuted(context);

    // Padding + ClipRRect + BackdropFilter
    // BackdropFilter must be a DIRECT child of ClipRRect
    // No Opacity, no Stack, no Positioned anywhere in this tree
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 2),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(36),
                color: isDark
                    ? const Color(0xFF111111).withOpacity(0.80)
                    : Colors.white.withOpacity(0.78),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.07),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(isDark ? 0.50 : 0.10),
                    blurRadius: 28,
                    offset: const Offset(0, 6),
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
                      onTap: () => onTap(i),
                    ),
                  );
                }),
              ),
            ),
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
  final bool isActive;
  final Color primary, muted;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.isActive,
    required this.primary,
    required this.muted,
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
        vsync: this,
        duration: const Duration(milliseconds: 130),
        reverseDuration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.82)
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
            // Icon — no AnimatedSwitcher to avoid Positioned issues
            Icon(
              widget.isActive ? widget.item.active : widget.item.inactive,
              size: 22,
              color: widget.isActive ? widget.primary : widget.muted,
            ),
            const SizedBox(height: 4),
            Text(
              widget.item.label,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: widget.isActive
                    ? FontWeight.w700
                    : FontWeight.w400,
                color: widget.isActive ? widget.primary : widget.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}