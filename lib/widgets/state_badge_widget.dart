import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

/// Clean academic badge widget visualizing standard OS 5-state process lifecycle.
class StateBadgeWidget extends StatelessWidget {
  final ProcessState state;
  final bool compact;
  final bool showIcon;

  const StateBadgeWidget({
    super.key,
    required this.state,
    this.compact = false,
    this.showIcon = true,
  });

  Color _getStateColor() {
    switch (state) {
      case ProcessState.newProcess:
        return const Color(0xFF0288D1); // Cyan/Blue (Newly admitted)
      case ProcessState.ready:
        return const Color(0xFFF57C00); // Amber/Orange (Ready in memory queue)
      case ProcessState.running:
        return const Color(0xFF2E7D32); // Emerald Green (Actively on CPU)
      case ProcessState.waiting:
        return const Color(0xFF7B1FA2); // Deep Purple (Blocked for I/O)
      case ProcessState.terminated:
        return const Color(0xFF616161); // Slate Grey (Execution complete)
    }
  }

  IconData _getStateIcon() {
    switch (state) {
      case ProcessState.newProcess:
        return Icons.add_circle_outline;
      case ProcessState.ready:
        return Icons.hourglass_top_rounded;
      case ProcessState.running:
        return Icons.play_arrow_rounded;
      case ProcessState.waiting:
        return Icons.pause_rounded;
      case ProcessState.terminated:
        return Icons.check_circle_outline_rounded;
    }
  }

  String _getStateLabel() {
    switch (state) {
      case ProcessState.newProcess:
        return 'NEW';
      case ProcessState.ready:
        return 'READY';
      case ProcessState.running:
        return 'RUNNING';
      case ProcessState.waiting:
        return 'WAITING';
      case ProcessState.terminated:
        return 'DONE';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStateColor();
    final label = _getStateLabel();
    final icon = _getStateIcon();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 5 : 7,
        vertical: compact ? 1.5 : 3,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        border: Border.all(color: color.withAlpha(120), width: 1.0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showIcon) ...[
            Icon(icon, size: compact ? 10 : 12, color: color),
            SizedBox(width: compact ? 3 : 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 9 : 10,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
