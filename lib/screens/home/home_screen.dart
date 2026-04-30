import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/utils/daily_quotes.dart';
import '../../providers/theme_provider.dart';
import '../../app.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final String _quote;
  late final String _bgPath;

  @override
  void initState() {
    super.initState();
    _quote  = Quotes.random();
    _bgPath = Quotes.randomBg();
    _ctrl   = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100));
    _fade   = CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.12, 1.0, curve: Curves.easeOut));
    _slide  = Tween<Offset>(
            begin: const Offset(0, 0.055), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.12, 1.0, curve: Curves.easeOutCubic)));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _engage() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, __, ___) => const PulseShell(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background
            _BgImage(path: _bgPath),

            // Overlay
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.15),
                    Colors.black.withOpacity(0.38),
                    Colors.black.withOpacity(0.75),
                    Colors.black.withOpacity(0.94),
                    Colors.black,
                  ],
                  stops: const [0.0, 0.22, 0.50, 0.70, 1.0],
                ),
              ),
            ),

            // Content
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(26, 20, 26, 0),
                    child: Text(
                      'PULSE',
                      style: GoogleFonts.figtree(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withOpacity(0.80),
                        letterSpacing: 3.6,
                      ),
                    ),
                  ),

                  const Spacer(),

                  FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(26, 0, 26, 52),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _quote,
                              style: GoogleFonts.figtree(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.08,
                                letterSpacing: -1.0,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Container(
                              width: 28, height: 1.5,
                              color: Colors.white.withOpacity(0.30),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              'Welcome back, chef',
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 20,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.48),
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 40),
                            _EngageButton(onTap: _engage),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BgImage extends StatelessWidget {
  final String path;
  const _BgImage({required this.path});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      fit: BoxFit.cover,
      frameBuilder: (ctx, child, frame, wasSync) {
        if (wasSync || frame != null) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          child: child,
        );
      },
      errorBuilder: (_, __, ___) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF181818), Color(0xFF080808), Color(0xFF000000)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }
}

class _EngageButton extends StatefulWidget {
  final VoidCallback onTap;
  const _EngageButton({required this.onTap});

  @override
  State<_EngageButton> createState() => _EngageButtonState();
}

class _EngageButtonState extends State<_EngageButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _lift;
  late final Animation<double> _tint;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 140),
        reverseDuration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.94)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _lift  = Tween<double>(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _tint  = Tween<double>(begin: 0.0, end: 0.09)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _down(TapDownDetails _) async {
    HapticFeedback.lightImpact();
    await _ctrl.forward();
  }

  Future<void> _up(TapUpDetails _) async {
    await _ctrl.reverse();
    widget.onTap();
  }

  void _cancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _down,
      onTapUp: _up,
      onTapCancel: _cancel,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Transform.scale(
          scale: _scale.value,
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            decoration: BoxDecoration(
              color: Color.lerp(Colors.white, const Color(0xFFDDDDDD), _tint.value),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.55 * _lift.value),
                  blurRadius: 22 * _lift.value,
                  offset: Offset(0, 8 * _lift.value),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.10 * _lift.value),
                  blurRadius: 14 * _lift.value,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ENGAGE',
                  style: GoogleFonts.figtree(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.black.withOpacity(1.0 - _tint.value * 0.3),
                    letterSpacing: 3.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}