import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class StatsRow extends StatelessWidget {
  final int completed;
  final int total;
  final int missed;

  const StatsRow({
    super.key,
    required this.completed,
    required this.total,
    required this.missed,
  });

  @override
  Widget build(BuildContext context) {
    final surface = AppColors.surface(context);
    final border  = AppColors.border(context);
    final primary = AppColors.textPrimary(context);
    final muted   = AppColors.textMuted(context);

    return Row(
      children: [
        _StatCard(
          label: 'DONE',
          value: '$completed',
          color: primary,
          surface: surface,
          border: border,
          muted: muted,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'TOTAL',
          value: '$total',
          color: primary,
          surface: surface,
          border: border,
          muted: muted,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'MISSED',
          value: '$missed',
          color: missed > 0 ? AppColors.danger : muted,
          surface: surface,
          border: border,
          muted: muted,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color surface;
  final Color border;
  final Color muted;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.surface,
    required this.border,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              label == 'DONE'
                  ? Icons.check_circle_outline_rounded
                  : label == 'MISSED'
                      ? Icons.cancel_outlined
                      : Icons.list_rounded,
              size: 18,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: muted,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}