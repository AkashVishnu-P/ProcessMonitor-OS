import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CircularChartWidget extends StatelessWidget {
  final double percent; // 0.0 to 1.0
  final String title;
  final String subtitle;
  final Color progressColor;
  final Color? backgroundColor;

  const CircularChartWidget({
    super.key,
    required this.percent,
    required this.title,
    required this.subtitle,
    required this.progressColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clampedPercent = percent.clamp(0.0, 1.0);
    final percentText = '${(clampedPercent * 100).toStringAsFixed(0)}%';

    return Center(
      child: CircularPercentIndicator(
        radius: 68.0,
        lineWidth: 12.0,
        animation: true,
        animateFromLastPercent: true,
        percent: clampedPercent,
        circularStrokeCap: CircularStrokeCap.round,
        backgroundColor: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
        progressColor: progressColor,
        center: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              percentText,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Used',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
