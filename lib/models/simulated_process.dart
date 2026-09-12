import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

/// Represents a Process Control Block (PCB) in Operating Systems.
/// Tracks scheduling metadata, CPU execution timings, and the 5-state process lifecycle.
class SimulatedProcess {
  final int pid;
  final String name;
  final int burstTime; // Total CPU burst requirements (seconds)
  int remainingTime; // Remaining CPU burst units to completion
  final int arrivalTime; // Tick when process was admitted to the system
  final int priority; // Priority number: 1 = Highest (Real-time), 5 = Lowest (Batch)
  int? startTime; // Tick when CPU was first dispatched to this process
  int? completionTime; // Tick when process finished execution
  int waitingTime; // Total duration spent in Ready queue waiting for CPU
  int turnaroundTime; // Total turnaround time: completionTime - arrivalTime
  ProcessState state; // Current lifecycle state: newProcess, ready, running, waiting, terminated
  final Color color;

  SimulatedProcess({
    required this.pid,
    required this.name,
    required this.burstTime,
    int? remainingTime,
    required this.arrivalTime,
    this.priority = 2,
    this.startTime,
    this.completionTime,
    this.waitingTime = 0,
    this.turnaroundTime = 0,
    this.state = ProcessState.ready,
    required this.color,
  }) : remainingTime = remainingTime ?? burstTime;

  double get progressRatio =>
      burstTime > 0 ? (burstTime - remainingTime) / burstTime : 0.0;

  SimulatedProcess copyWith({
    int? pid,
    String? name,
    int? burstTime,
    int? remainingTime,
    int? arrivalTime,
    int? priority,
    int? startTime,
    int? completionTime,
    int? waitingTime,
    int? turnaroundTime,
    ProcessState? state,
    Color? color,
  }) {
    return SimulatedProcess(
      pid: pid ?? this.pid,
      name: name ?? this.name,
      burstTime: burstTime ?? this.burstTime,
      remainingTime: remainingTime ?? this.remainingTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      priority: priority ?? this.priority,
      startTime: startTime ?? this.startTime,
      completionTime: completionTime ?? this.completionTime,
      waitingTime: waitingTime ?? this.waitingTime,
      turnaroundTime: turnaroundTime ?? this.turnaroundTime,
      state: state ?? this.state,
      color: color ?? this.color,
    );
  }
}
