import 'package:flutter/material.dart';
import '../models/gantt_record.dart';

class GanttChartWidget extends StatefulWidget {
  final List<GanttRecord> records;
  final int currentTick;

  const GanttChartWidget({
    super.key,
    required this.records,
    required this.currentTick,
  });

  @override
  State<GanttChartWidget> createState() => _GanttChartWidgetState();
}

class _GanttChartWidgetState extends State<GanttChartWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant GanttChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-scroll to end as execution progresses
    if (widget.records.length != oldWidget.records.length ||
        widget.currentTick != oldWidget.currentTick) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.records.isEmpty) {
      return Container(
        height: 72,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withAlpha(50),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.colorScheme.outlineVariant.withAlpha(80)),
        ),
        child: Text(
          'Awaiting CPU execution ticks to plot Gantt timeline...',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(40),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outlineVariant.withAlpha(80)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.view_timeline_outlined, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                'Live CPU Execution Timeline',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                'Total: ${widget.currentTick}s',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 64,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.records.length,
              itemBuilder: (context, index) {
                final record = widget.records[index];
                final blockWidth = (record.duration * 38.0).clamp(58.0, 300.0);
                final blockColor = record.isContextSwitch
                    ? const Color(0xFF607D8B) // Slate grey for Context Switch
                    : record.color;
                final isDark = ThemeData.estimateBrightnessForColor(blockColor) == Brightness.dark;
                final textColor = record.isContextSwitch ? Colors.amberAccent : (isDark ? Colors.white : Colors.black87);
                final subTextColor = record.isContextSwitch ? Colors.white70 : (isDark ? Colors.white70 : Colors.black54);
                final stateColor = record.isContextSwitch ? Colors.amber[200]! : (isDark ? Colors.white : Colors.black87);

                return Container(
                  width: blockWidth,
                  margin: const EdgeInsets.only(right: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                  decoration: BoxDecoration(
                    color: blockColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: record.isContextSwitch
                          ? Colors.amber.withAlpha(180)
                          : Colors.black26,
                      width: record.isContextSwitch ? 1.5 : 0.8,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Line 1: Process Identifier
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (record.isContextSwitch) ...[
                            const Icon(Icons.swap_horiz, size: 10, color: Colors.amberAccent),
                            const SizedBox(width: 2),
                          ],
                          Flexible(
                            child: Text(
                              record.pid,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 1),
                      // Line 2: Execution Time Slice interval (e.g. 18s-20s)
                      Text(
                        '${record.startTick}s-${record.endTick}s',
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 1),
                      // Line 3: Exact Process State in parentheses (e.g. (Running))
                      Text(
                        '(${record.stateLabel})',
                        style: TextStyle(
                          color: stateColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
