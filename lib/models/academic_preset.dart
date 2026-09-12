import '../core/constants/app_constants.dart';

enum AcademicPreset {
  convoyEffect(
    name: 'The Convoy Effect',
    subtitle: 'FCFS vs. SRTF Benchmark',
    description:
        'Large CPU-bound job P0 (16s) delays short tasks P1-P3 (2s each), demonstrating severe Average Waiting Time inflation under FCFS compared to SRTF.',
    recommendedAlgorithm: SchedulingAlgorithmType.fcfs,
  ),
  priorityStarvation(
    name: 'Priority Starvation',
    subtitle: 'Preemptive Priority (PPBS) Benchmark',
    description:
        'Low-priority job P0 (Priority 5, 10s) is starved indefinitely as higher-priority tasks (Priority 1-2) continually monopolize the CPU.',
    recommendedAlgorithm: SchedulingAlgorithmType.ppbs,
  ),
  ioBoundMix(
    name: 'CPU vs. I/O Mix',
    subtitle: 'Mixed Workload Benchmark',
    description:
        'A balanced mix of compute-intensive processes (8s) and quick-yielding interactive tasks (2s) demonstrating time-sliced responsiveness.',
    recommendedAlgorithm: SchedulingAlgorithmType.roundRobin,
  );

  final String name;
  final String subtitle;
  final String description;
  final SchedulingAlgorithmType recommendedAlgorithm;

  const AcademicPreset({
    required this.name,
    required this.subtitle,
    required this.description,
    required this.recommendedAlgorithm,
  });
}
