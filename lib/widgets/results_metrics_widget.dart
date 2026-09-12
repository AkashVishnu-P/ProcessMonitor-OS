import 'package:flutter/material.dart';
import '../models/simulated_process.dart';

class ResultsMetricsWidget extends StatelessWidget {
  final List<SimulatedProcess> terminatedList;
  final double averageWaitingTime;
  final double averageTurnaroundTime;
  final double averageResponseTime;
  final double cpuUtilization;
  final double throughput;
  final int totalContextSwitches;
  final int cpuIdleTicks;

  const ResultsMetricsWidget({
    super.key,
    required this.terminatedList,
    required this.averageWaitingTime,
    required this.averageTurnaroundTime,
    required this.averageResponseTime,
    required this.cpuUtilization,
    required this.throughput,
    required this.totalContextSwitches,
    required this.cpuIdleTicks,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assessment_outlined, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Simulation Results & Performance Metrics',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Performance Metric Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                final crossAxisCount = isWide ? 4 : 2;

                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: isWide ? 2.1 : 1.7,
                  children: [
                    _buildMetricTile(
                      context,
                      title: 'Avg Waiting Time',
                      value: '${averageWaitingTime.toStringAsFixed(2)}s',
                      subtitle: 'Total wait across jobs',
                      icon: Icons.hourglass_bottom,
                      color: Colors.amber.shade800,
                    ),
                    _buildMetricTile(
                      context,
                      title: 'Avg Turnaround Time',
                      value: '${averageTurnaroundTime.toStringAsFixed(2)}s',
                      subtitle: 'Completion - Arrival',
                      icon: Icons.timer_outlined,
                      color: Colors.blue.shade700,
                    ),
                    _buildMetricTile(
                      context,
                      title: 'Avg Response Time',
                      value: '${averageResponseTime.toStringAsFixed(2)}s',
                      subtitle: 'First CPU dispatch',
                      icon: Icons.speed,
                      color: Colors.purple.shade600,
                    ),
                    _buildMetricTile(
                      context,
                      title: 'CPU Utilization',
                      value: '${cpuUtilization.toStringAsFixed(1)}%',
                      subtitle: 'Busy ticks / total',
                      icon: Icons.memory,
                      color: Colors.green.shade700,
                    ),
                    _buildMetricTile(
                      context,
                      title: 'Throughput',
                      value: '${throughput.toStringAsFixed(3)}/s',
                      subtitle: '${terminatedList.length} jobs finished',
                      icon: Icons.trending_up,
                      color: Colors.teal.shade700,
                    ),
                    _buildMetricTile(
                      context,
                      title: 'Context Switches',
                      value: '$totalContextSwitches',
                      subtitle: 'Dispatcher interruptions',
                      icon: Icons.swap_horiz,
                      color: Colors.deepOrange.shade700,
                    ),
                    _buildMetricTile(
                      context,
                      title: 'CPU Idle Time',
                      value: '${cpuIdleTicks}s',
                      subtitle: 'Core waiting on jobs',
                      icon: Icons.pause_circle_outline,
                      color: Colors.blueGrey,
                    ),
                    _buildMetricTile(
                      context,
                      title: 'Jobs Completed',
                      value: '${terminatedList.length}',
                      subtitle: 'Terminated PCB records',
                      icon: Icons.check_circle_outline,
                      color: Colors.indigo.shade700,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Per-Process Results Table if any terminated
            if (terminatedList.isNotEmpty) ...[
              Text(
                'Per-Process Execution Log:',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 16,
                  headingRowHeight: 36,
                  dataRowMinHeight: 34,
                  dataRowMaxHeight: 40,
                  columns: const [
                    DataColumn(label: Text('Process')),
                    DataColumn(label: Text('Burst')),
                    DataColumn(label: Text('Arrival')),
                    DataColumn(label: Text('Finish')),
                    DataColumn(label: Text('Turnaround')),
                    DataColumn(label: Text('Waiting')),
                    DataColumn(label: Text('Response')),
                  ],
                  rows: terminatedList.take(8).map((p) {
                    return DataRow(cells: [
                      DataCell(Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: p.color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      )),
                      DataCell(Text('${p.burstTime}s')),
                      DataCell(Text('${p.arrivalTime}s')),
                      DataCell(Text('${p.completionTime ?? 0}s')),
                      DataCell(Text('${p.turnaroundTime}s')),
                      DataCell(Text('${p.waitingTime}s')),
                      DataCell(Text('${p.responseTime}s')),
                    ]);
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 9.5, color: theme.colorScheme.onSurfaceVariant),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
