import 'package:flutter/material.dart';
import '../models/simulated_process.dart';

class MemoryVisualizationWidget extends StatelessWidget {
  final int totalMemoryMb;
  final int kernelMemoryMb;
  final SimulatedProcess? runningProcess;
  final List<SimulatedProcess> readyQueue;
  final List<SimulatedProcess> waitingQueue;

  const MemoryVisualizationWidget({
    super.key,
    required this.totalMemoryMb,
    required this.kernelMemoryMb,
    this.runningProcess,
    required this.readyQueue,
    required this.waitingQueue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate process memory allocations
    final runningMem = runningProcess?.memoryMb ?? 0;
    final readyMem = readyQueue.fold<int>(0, (sum, p) => sum + p.memoryMb);
    final waitingMem = waitingQueue.fold<int>(0, (sum, p) => sum + p.memoryMb);
    final totalAllocated = kernelMemoryMb + runningMem + readyMem + waitingMem;
    final freeMem = (totalMemoryMb - totalAllocated).clamp(0, totalMemoryMb);

    final usedPercent = ((totalAllocated / totalMemoryMb) * 100).clamp(0.0, 100.0);

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
                Icon(Icons.storage_outlined, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Simulated RAM Memory Allocation',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '$totalAllocated MB / $totalMemoryMb MB (${usedPercent.toStringAsFixed(0)}%)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Visual Memory Bar Stack
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 28,
                color: theme.colorScheme.surfaceContainerHighest,
                child: Row(
                  children: [
                    // Kernel partition
                    _buildSegment(
                      fraction: kernelMemoryMb / totalMemoryMb,
                      color: const Color(0xFF4A148C),
                      label: 'Kernel',
                    ),
                    // Running process partition
                    if (runningProcess != null && runningMem > 0)
                      _buildSegment(
                        fraction: runningMem / totalMemoryMb,
                        color: runningProcess!.color,
                        label: runningProcess!.name,
                      ),
                    // Ready processes partition
                    ...readyQueue.map((p) => _buildSegment(
                          fraction: p.memoryMb / totalMemoryMb,
                          color: p.color.withValues(alpha: 0.8),
                          label: p.name,
                        )),
                    // Waiting processes partition
                    ...waitingQueue.map((p) => _buildSegment(
                          fraction: p.memoryMb / totalMemoryMb,
                          color: p.color.withValues(alpha: 0.5),
                          label: p.name,
                        )),
                    // Free Memory partition
                    if (freeMem > 0)
                      _buildSegment(
                        fraction: freeMem / totalMemoryMb,
                        color: const Color(0xFFE0E0E0).withValues(alpha: 0.35),
                        label: 'Free',
                        isFree: true,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Memory Allocation Legend & Badges
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildLegendChip('Kernel', '$kernelMemoryMb MB', const Color(0xFF4A148C)),
                if (runningProcess != null)
                  _buildLegendChip('${runningProcess!.name} (Running)', '$runningMem MB', runningProcess!.color),
                ...readyQueue.take(4).map((p) => _buildLegendChip(p.name, '${p.memoryMb} MB', p.color)),
                if (readyQueue.length > 4)
                  _buildLegendChip('+${readyQueue.length - 4} More', '', theme.colorScheme.onSurfaceVariant),
                _buildLegendChip('Free RAM', '$freeMem MB', const Color(0xFF9E9E9E)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegment({
    required double fraction,
    required Color color,
    required String label,
    bool isFree = false,
  }) {
    final flex = (fraction * 1000).round().clamp(1, 1000);
    return Expanded(
      flex: flex,
      child: Tooltip(
        message: '$label: ${(fraction * totalMemoryMb).round()} MB',
        child: Container(
          color: color,
          height: double.infinity,
          alignment: Alignment.center,
          child: flex > 60
              ? Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isFree ? Colors.black54 : Colors.white,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildLegendChip(String title, String memory, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
          if (memory.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              '($memory)',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }
}
