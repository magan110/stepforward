import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PremiumCircularProgress extends StatelessWidget {
  final int steps;
  final int goal;
  final double size;

  const PremiumCircularProgress({
    super.key,
    required this.steps,
    required this.goal,
    this.size = 240.0,
  });

  @override
  Widget build(BuildContext context) {
    double percent = (steps / goal).clamp(0.0, 1.0);
    return CircularPercentIndicator(
      radius: size / 2,
      lineWidth: 20.0,
      animation: true,
      percent: percent,
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_walk,
            size: 40,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 8),
          Text(
            '\$steps',
            style: GoogleFonts.outfit(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            '/ \$goal steps',
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
      circularStrokeCap: CircularStrokeCap.round,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      linearGradient: LinearGradient(
        colors: [
          Theme.of(context).primaryColor,
          Theme.of(context).colorScheme.secondary,
        ],
      ),
    );
  }
}
