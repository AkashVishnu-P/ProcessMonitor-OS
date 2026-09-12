import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../models/academic_preset.dart';
import '../providers/simulator_provider.dart';
import '../widgets/gantt_chart_widget.dart';
import '../widgets/process_queue_widget.dart';

class SimulatorScreen extends StatelessWidget {
  const SimulatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sim = Provider.of<SimulatorProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CPU Scheduler Simulator',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(
              sim.isVoiceTutorMuted ? Icons.voice_over_off : Icons.record_voice_over,
              color: sim.isVoiceTutorMuted ? theme.colorScheme.outline : theme.colorScheme.primary,
            ),
            tooltip: sim.isVoiceTutorMuted ? 'Unmute Voice Tutor' : 'Mute Voice Tutor',
            onPressed: () {
              sim.toggleVoiceTutorMute();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    sim.isVoiceTutorMuted ? 'Voice Tutor Muted' : 'Voice Tutor Unmuted',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Simulation',
            onPressed: () => _confirmReset(context, sim),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        children: [
          // 1. Curated Academic Presets Card
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: theme.colorScheme.surfaceContainerHighest.withAlpha(50),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.school_outlined, size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Academic Benchmark Presets',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: AcademicPreset.values.map((preset) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ActionChip(
                            avatar: const Icon(Icons.play_circle_outline, size: 16),
                            label: Text(preset.name, style: const TextStyle(fontSize: 12)),
                            onPressed: () {
                              sim.loadPreset(preset);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Loaded ${preset.name}: ${preset.subtitle}'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Algorithm Configuration & Runtime Controls Card
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Scheduling Algorithm',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (sim.selectedAlgorithm.isPreemptive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.withAlpha(40),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Preemptive',
                            style: TextStyle(
                              color: Color(0xFFD97706),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<SchedulingAlgorithmType>(
                    isExpanded: true,
                    initialValue: sim.selectedAlgorithm,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: SchedulingAlgorithmType.values.map((algo) {
                      return DropdownMenuItem(
                        value: algo,
                        child: Text(
                          algo.displayName,
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: sim.isRunning
                        ? null
                        : (val) {
                            if (val != null) sim.setAlgorithm(val);
                          },
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      ),
                      icon: const Icon(Icons.volume_up, size: 16),
                      label: const Text('Explain Algorithm (Voice Tutor)', style: TextStyle(fontSize: 12)),
                      onPressed: () {
                        sim.explainCurrentAlgorithm();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Speaking explanation for ${sim.selectedAlgorithm.displayName}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),

                  // Priority Notice
                  if (sim.selectedAlgorithm.isPriorityBased) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withAlpha(50),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: theme.colorScheme.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Priority: 1 = Highest Priority, 5 = Lowest Priority',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Round Robin Quantum Selector
                  if (sim.selectedAlgorithm == SchedulingAlgorithmType.roundRobin) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Time Quantum: ${sim.timeQuantum}s',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Slider(
                            value: sim.timeQuantum.toDouble(),
                            min: 1,
                            max: 6,
                            divisions: 5,
                            label: '${sim.timeQuantum}s',
                            onChanged: sim.isRunning
                                ? null
                                : (val) => sim.setTimeQuantum(val.toInt()),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const Divider(height: 20),

                  // Automated Dynamic Workload Generator Stream Toggle
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.bolt,
                              size: 18,
                              color: sim.autoGenerateStream ? Colors.amber[800] : theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Dynamic Traffic Stream (30%/s)',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: sim.autoGenerateStream,
                        onChanged: (val) => sim.toggleAutoGenerateStream(val),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Context Switch Overhead Setting
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.swap_horiz,
                            size: 18,
                            color: sim.contextSwitchDuration > 0 ? Colors.deepOrange : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Context Switch Penalty:',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SegmentedButton<int>(
                        segments: const [
                          ButtonSegment(value: 0, label: Text('0s (Ideal)')),
                          ButtonSegment(value: 1, label: Text('1s (Real)')),
                        ],
                        selected: {sim.contextSwitchDuration},
                        onSelectionChanged: (set) => sim.setContextSwitchDuration(set.first),
                        style: const ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),

                  if (sim.contextSwitchDuration > 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Context Switches: ${sim.totalContextSwitches}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Overhead: ${sim.totalContextSwitchTicks}s (${sim.contextSwitchOverheadPercentage.toStringAsFixed(1)}%)',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.deepOrange),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const Divider(height: 24),

                  // Execution Action Buttons
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Process'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          foregroundColor: theme.colorScheme.onPrimaryContainer,
                        ),
                        onPressed: () => _showAddProcessDialog(context, sim),
                      ),
                      FilledButton.icon(
                        icon: Icon(sim.isRunning ? Icons.pause : Icons.play_arrow, size: 18),
                        label: Text(sim.isRunning ? 'Pause' : 'Start Execution'),
                        style: FilledButton.styleFrom(
                          backgroundColor: sim.isRunning ? Colors.amber[800] : theme.colorScheme.primary,
                        ),
                        onPressed: () {
                          if (sim.isRunning) {
                            sim.pauseSimulation();
                          } else {
                            sim.startSimulation();
                          }
                        },
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.skip_next, size: 18),
                        label: const Text('Step (1s)'),
                        onPressed: sim.isRunning ? null : () => sim.stepTick(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 3. Live Gantt Chart Visualizer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: GanttChartWidget(
              records: sim.ganttRecords,
              currentTick: sim.currentTick,
            ),
          ),

          // Simulation Clock & Academic Metrics Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 6,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Clock: ${sim.currentTick}s',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Avg Wait: ${sim.averageWaitingTime.toStringAsFixed(1)}s',
                    style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Avg Turnaround: ${sim.averageTurnaroundTime.toStringAsFixed(1)}s',
                    style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),

          // 4. RUNNING (CPU) Section
          KanbanSectionWidget(
            title: 'RUNNING (CPU)',
            icon: Icons.speed,
            headerColor: Colors.amber[800]!,
            count: sim.runningProcess != null || sim.isContextSwitching ? 1 : 0,
            content: sim.isContextSwitching
                ? Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withAlpha(30),
                      border: Border.all(color: Colors.amber, width: 1.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber),
                        ),
                        SizedBox(width: 10),
                        Text(
                          '[Context Switch in Progress] Saving PCB & dispatching...',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFD97706)),
                        ),
                      ],
                    ),
                  )
                : sim.runningProcess != null
                    ? ProcessCardWidget(
                        process: sim.runningProcess!,
                        isRunning: true,
                        actionLabel: 'Simulate I/O Block',
                        actionIcon: Icons.pause_circle_outline,
                        onAction: () => sim.simulateIoBlockRunningProcess(),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        alignment: Alignment.center,
                        child: Text(
                          'CPU Idle - Ready to execute',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
          ),

          // 5. READY QUEUE Section
          KanbanSectionWidget(
            title: 'READY QUEUE',
            icon: Icons.queue,
            headerColor: theme.colorScheme.primary,
            count: sim.readyQueue.length,
            content: sim.readyQueue.isEmpty
                ? Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    child: Text(
                      'No processes in Ready Queue',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: sim.readyQueue.length,
                      itemBuilder: (context, index) {
                        return ProcessCardWidget(process: sim.readyQueue[index]);
                      },
                    ),
                  ),
          ),

          // 6. WAITING (I/O) Section
          if (sim.waitingQueue.isNotEmpty)
            KanbanSectionWidget(
              title: 'WAITING / BLOCKED (I/O)',
              icon: Icons.hourglass_empty,
              headerColor: Colors.deepOrange,
              count: sim.waitingQueue.length,
              content: SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: sim.waitingQueue.length,
                  itemBuilder: (context, index) {
                    final process = sim.waitingQueue[index];
                    return ProcessCardWidget(
                      process: process,
                      actionLabel: 'I/O Complete',
                      actionIcon: Icons.play_arrow,
                      onAction: () => sim.simulateIoComplete(process),
                    );
                  },
                ),
              ),
            ),

          // 7. TERMINATED Section
          KanbanSectionWidget(
            title: 'TERMINATED',
            icon: Icons.check_circle_outline,
            headerColor: Colors.green,
            count: sim.terminatedList.length,
            content: sim.terminatedList.isEmpty
                ? Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    child: Text(
                      'No completed processes yet',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: sim.terminatedList.length,
                      itemBuilder: (context, index) {
                        return ProcessCardWidget(process: sim.terminatedList[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          sim.toggleVoiceTutorMute();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                sim.isVoiceTutorMuted ? 'Voice Tutor Muted' : 'Voice Tutor Unmuted',
              ),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        icon: Icon(
          sim.isVoiceTutorMuted ? Icons.voice_over_off : Icons.record_voice_over,
        ),
        label: Text(sim.isVoiceTutorMuted ? 'Tutor Muted' : 'Voice Tutor'),
        backgroundColor: sim.isVoiceTutorMuted
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.primaryContainer,
        foregroundColor: sim.isVoiceTutorMuted
            ? theme.colorScheme.onSurfaceVariant
            : theme.colorScheme.onPrimaryContainer,
      ),
    );
  }

  void _showAddProcessDialog(BuildContext context, SimulatorProvider sim) {
    int burstTime = 4;
    int priority = 2;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Spawn Simulated Process'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Burst Time (CPU execution seconds):', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filledTonal(
                        icon: const Icon(Icons.remove),
                        onPressed: burstTime > 1 ? () => setState(() => burstTime--) : null,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '$burstTime s',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 16),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.add),
                        onPressed: burstTime < 15 ? () => setState(() => burstTime++) : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Priority (1 = Highest, 5 = Lowest):', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filledTonal(
                        icon: const Icon(Icons.remove),
                        onPressed: priority > 1 ? () => setState(() => priority--) : null,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Priority $priority',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 16),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.add),
                        onPressed: priority < 5 ? () => setState(() => priority++) : null,
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    sim.spawnProcess(customBurst: burstTime, customPriority: priority);
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Spawn'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmReset(BuildContext context, SimulatorProvider sim) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Reset Simulation?'),
          content: const Text(
            'This will clear all process queues, reset clock time, and restore initial sample processes.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                sim.resetSimulation();
                Navigator.of(ctx).pop();
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }
}
