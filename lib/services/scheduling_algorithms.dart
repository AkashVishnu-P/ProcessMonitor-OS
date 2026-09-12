import '../core/constants/app_constants.dart';
import '../models/simulated_process.dart';

class SchedulingAlgorithms {
  /// Selects the next process to execute from the ready queue based on the algorithm.
  static SimulatedProcess? selectNextProcess({
    required List<SimulatedProcess> readyQueue,
    required SchedulingAlgorithmType algorithm,
  }) {
    if (readyQueue.isEmpty) return null;

    switch (algorithm) {
      case SchedulingAlgorithmType.fcfs:
      case SchedulingAlgorithmType.roundRobin:
        // First Come First Served & Round Robin: Pick from head of ready queue
        return readyQueue.first;

      case SchedulingAlgorithmType.sjf:
        // Shortest Job First (Non-preemptive): Pick process with smallest burst time
        SimulatedProcess shortest = readyQueue.first;
        for (int i = 1; i < readyQueue.length; i++) {
          if (readyQueue[i].burstTime < shortest.burstTime) {
            shortest = readyQueue[i];
          }
        }
        return shortest;

      case SchedulingAlgorithmType.srtf:
        // Shortest Remaining Time First (Preemptive SJF): Pick process with smallest remaining time
        SimulatedProcess shortest = readyQueue.first;
        for (int i = 1; i < readyQueue.length; i++) {
          if (readyQueue[i].remainingTime < shortest.remainingTime) {
            shortest = readyQueue[i];
          }
        }
        return shortest;

      case SchedulingAlgorithmType.pbs:
      case SchedulingAlgorithmType.ppbs:
        // Priority-Based Scheduling (Lower number = Higher priority): Pick process with lowest priority number
        SimulatedProcess highestPriority = readyQueue.first;
        for (int i = 1; i < readyQueue.length; i++) {
          if (readyQueue[i].priority < highestPriority.priority) {
            highestPriority = readyQueue[i];
          }
        }
        return highestPriority;
    }
  }

  /// Evaluates whether the currently running process should be preempted by a process in the ready queue.
  static bool shouldPreempt({
    required SimulatedProcess running,
    required List<SimulatedProcess> readyQueue,
    required SchedulingAlgorithmType algorithm,
  }) {
    if (readyQueue.isEmpty) return false;

    switch (algorithm) {
      case SchedulingAlgorithmType.srtf:
        // Preempt if any ready process has strictly shorter remaining time
        return readyQueue.any((p) => p.remainingTime < running.remainingTime);

      case SchedulingAlgorithmType.ppbs:
        // Preempt if any ready process has strictly higher priority (lower number)
        return readyQueue.any((p) => p.priority < running.priority);

      default:
        return false;
    }
  }

  /// Calculates Average Waiting Time across terminated processes
  static double calculateAverageWaitingTime(List<SimulatedProcess> terminated) {
    if (terminated.isEmpty) return 0.0;
    final totalWait = terminated.fold<int>(0, (sum, p) => sum + p.waitingTime);
    return totalWait / terminated.length;
  }

  /// Calculates Average Turnaround Time across terminated processes
  static double calculateAverageTurnaroundTime(List<SimulatedProcess> terminated) {
    if (terminated.isEmpty) return 0.0;
    final totalTurnaround = terminated.fold<int>(0, (sum, p) => sum + p.turnaroundTime);
    return totalTurnaround / terminated.length;
  }

  /// Calculates Average Response Time across terminated processes
  static double calculateAverageResponseTime(List<SimulatedProcess> terminated) {
    if (terminated.isEmpty) return 0.0;
    final totalResponse = terminated.fold<int>(0, (sum, p) => sum + p.responseTime);
    return totalResponse / terminated.length;
  }

  /// Calculates CPU Utilization % based on busy time versus total elapsed ticks.
  static double calculateCpuUtilization({
    required int totalTicks,
    required int idleTicks,
  }) {
    if (totalTicks <= 0) return 0.0;
    final busyTicks = (totalTicks - idleTicks).clamp(0, totalTicks);
    return (busyTicks / totalTicks) * 100.0;
  }

  /// Calculates Throughput in processes per second (or per 100 seconds for readable scale).
  static double calculateThroughput({
    required int completedCount,
    required int totalTicks,
  }) {
    if (totalTicks <= 0) return 0.0;
    return completedCount / totalTicks;
  }
}
