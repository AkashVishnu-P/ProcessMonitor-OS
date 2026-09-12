class AppConstants {
  static const String appName = 'Process Monitor';
  static const String hardwareChannel = 'com.processmonitor.process_monitor/hardware';
  static const int autoRefreshIntervalSeconds = 3;

  // OS Sandbox restriction message for educational context
  static const String sandboxRestrictionTitle = 'Modern Android Sandboxing Notice';
  static const String sandboxRestrictionMessage =
      'Android 10+ restricts access to system-wide running tasks (GET_TASKS deprecated) '
      'for privacy and security. Process Monitor provides real-time device hardware telemetry '
      'paired with an interactive OS Concepts Simulator to visualize CPU scheduling algorithms.';
}

enum SchedulingAlgorithmType {
  fcfs('First-Come-First-Serve (FCFS)'),
  sjf('Shortest Job First (SJF) - Non-Preemptive'),
  srtf('Shortest Remaining Time First (SRTF) - Preemptive'),
  roundRobin('Round Robin (RR)'),
  pbs('Priority-Based Scheduling (PBS) - Non-Preemptive'),
  ppbs('Preemptive Priority Scheduling (PPBS)');

  final String displayName;
  const SchedulingAlgorithmType(this.displayName);

  bool get isPreemptive =>
      this == SchedulingAlgorithmType.srtf ||
      this == SchedulingAlgorithmType.ppbs ||
      this == SchedulingAlgorithmType.roundRobin;

  bool get isPriorityBased =>
      this == SchedulingAlgorithmType.pbs ||
      this == SchedulingAlgorithmType.ppbs;
}

enum ProcessState {
  newProcess('New'),
  ready('Ready Queue'),
  running('Running (CPU)'),
  waiting('Waiting (I/O)'),
  terminated('Terminated');

  final String label;
  const ProcessState(this.label);
}
