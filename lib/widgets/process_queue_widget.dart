import 'package:flutter/material.dart';
import '../models/simulated_process.dart';
import 'state_badge_widget.dart';

class ProcessCardWidget extends StatelessWidget {
  final SimulatedProcess process;
  final bool isRunning;
  final VoidCallback? onAction;
  final String? actionLabel;
  final IconData? actionIcon;

  const ProcessCardWidget({
    super.key,
    required this.process,
    this.isRunning = false,
    this.onAction,
    this.actionLabel,
    this.actionIcon,
  });

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return const Color(0xFFE53935); // Red (Highest)
      case 2:
        return const Color(0xFFFB8C00); // Orange
      case 3:
        return const Color(0xFF1E88E5); // Blue
      case 4:
        return const Color(0xFF43A047); // Green
      default:
        return const Color(0xFF757575); // Grey (Lowest)
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priorityColor = _getPriorityColor(process.priority);

    return Container(
      width: isRunning ? double.infinity : 210,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: process.color.withAlpha(25),
        border: Border.all(
          color: isRunning ? process.color : process.color.withAlpha(100),
          width: isRunning ? 2.0 : 1.0,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (process.iconBytes != null && process.iconBytes!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.memory(
                    process.iconBytes!,
                    width: 16,
                    height: 16,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 6),
              ] else ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: process.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        process.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: priorityColor.withAlpha(35),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'P${process.priority}',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: priorityColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              StateBadgeWidget(state: process.state, compact: true, showIcon: false),
              if (isRunning) ...[
                const SizedBox(width: 4),
                const SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(strokeWidth: 1.5),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          if (isRunning) ...[
            Text(
              'Burst: ${process.burstTime}s (Rem: ${process.remainingTime}s) | ${process.memoryMb} MB',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: process.progressRatio,
                backgroundColor: process.color.withAlpha(40),
                valueColor: AlwaysStoppedAnimation<Color>(process.color),
                minHeight: 6,
              ),
            ),
          ] else if (process.completionTime != null) ...[
            Text(
              'TAT: ${process.turnaroundTime}s | Wait: ${process.waitingTime}s | Resp: ${process.responseTime}s',
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Burst: ${process.burstTime}s | RAM: ${process.memoryMb} MB',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 10.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ] else ...[
            Text(
              'Burst: ${process.burstTime}s (Rem: ${process.remainingTime}s) | ${process.memoryMb} MB',
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Wait: ${process.waitingTime}s | Priority: ${process.priority}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 10.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: onAction,
                icon: Icon(actionIcon ?? Icons.swap_horiz, size: 14),
                label: Text(actionLabel!, style: const TextStyle(fontSize: 11)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class KanbanSectionWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color headerColor;
  final int count;
  final Widget content;

  const KanbanSectionWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.headerColor,
    required this.count,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: headerColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: headerColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: headerColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            content,
          ],
        ),
      ),
    );
  }
}
