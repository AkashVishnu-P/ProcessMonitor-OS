import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/simulated_process.dart';

class ProcessStateFlowWidget extends StatelessWidget {
  final SimulatedProcess? runningProcess;
  final int readyCount;
  final int waitingCount;
  final int terminatedCount;

  const ProcessStateFlowWidget({
    super.key,
    this.runningProcess,
    required this.readyCount,
    required this.waitingCount,
    required this.terminatedCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeState = runningProcess != null ? ProcessState.running : (readyCount > 0 ? ProcessState.ready : null);

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
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.hub_outlined, size: 20, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      '5-State Process Lifecycle',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (runningProcess != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      '${runningProcess!.name} is Running',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Flow visualization: New -> Ready <-> Running <-> Waiting -> Terminated
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStateNode(
                    context: context,
                    state: ProcessState.newProcess,
                    title: 'New',
                    subtitle: 'Spawned',
                    icon: Icons.create_new_folder_outlined,
                    color: const Color(0xFF1976D2),
                    isActive: false,
                    badgeCount: null,
                  ),
                  _buildArrow(context, 'Admit', Icons.arrow_forward),
                  _buildStateNode(
                    context: context,
                    state: ProcessState.ready,
                    title: 'Ready',
                    subtitle: 'Queue',
                    icon: Icons.schedule,
                    color: const Color(0xFFF57C00),
                    isActive: activeState == ProcessState.ready,
                    badgeCount: readyCount,
                  ),
                  _buildArrow(context, 'Dispatch / Yield', Icons.sync_alt),
                  _buildStateNode(
                    context: context,
                    state: ProcessState.running,
                    title: 'Running',
                    subtitle: 'CPU Core',
                    icon: Icons.memory,
                    color: const Color(0xFF388E3C),
                    isActive: activeState == ProcessState.running,
                    badgeCount: runningProcess != null ? 1 : 0,
                    isGlow: runningProcess != null,
                  ),
                  _buildArrow(context, 'I/O Event', Icons.swap_horiz),
                  _buildStateNode(
                    context: context,
                    state: ProcessState.waiting,
                    title: 'Waiting',
                    subtitle: 'Blocked I/O',
                    icon: Icons.hourglass_top_outlined,
                    color: const Color(0xFF7B1FA2),
                    isActive: waitingCount > 0,
                    badgeCount: waitingCount,
                  ),
                  _buildArrow(context, 'exit()', Icons.arrow_forward),
                  _buildStateNode(
                    context: context,
                    state: ProcessState.terminated,
                    title: 'Terminated',
                    subtitle: 'Completed',
                    icon: Icons.check_circle_outline,
                    color: const Color(0xFF455A64),
                    isActive: false,
                    badgeCount: terminatedCount,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Silberschatz OS Concept: Long-term scheduler admits New -> Ready. Short-term scheduler dispatches Ready -> Running. Timer preemption moves Running -> Ready. I/O moves Running -> Waiting.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateNode({
    required BuildContext context,
    required ProcessState state,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isActive,
    int? badgeCount,
    bool isGlow = false,
  }) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isActive ? color.withValues(alpha: 0.18) : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? color : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: isActive ? 2.2 : 1.0,
        ),
        boxShadow: isGlow
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isActive ? color : theme.colorScheme.onSurfaceVariant),
              if (badgeCount != null) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: isActive ? color : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: TextStyle(
                      color: isActive ? Colors.white : theme.colorScheme.onSurfaceVariant,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isActive ? color : theme.colorScheme.onSurface,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildArrow(BuildContext context, String label, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          Icon(icon, size: 16, color: theme.colorScheme.primary.withValues(alpha: 0.7)),
        ],
      ),
    );
  }
}
