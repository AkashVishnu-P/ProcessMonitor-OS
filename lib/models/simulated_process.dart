import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

/// Represents a Process Control Block (PCB) in Operating Systems.
/// Tracks scheduling metadata, CPU execution timings, memory requirements, and the 5-state process lifecycle.
class SimulatedProcess {
  final int pid;
  final String name;
  final int burstTime; // Total CPU burst requirements (seconds)
  int remainingTime; // Remaining CPU burst units to completion
  final int arrivalTime; // Tick when process was admitted to the system
  final int priority; // Priority number: 1 = Highest (Real-time), 10 = Lowest (Batch)
  final int memoryMb; // Simulated RAM footprint in Megabytes
  final String? packageName;
  final Uint8List? iconBytes;
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
    this.memoryMb = 256,
    this.packageName,
    this.iconBytes,
    this.startTime,
    this.completionTime,
    this.waitingTime = 0,
    this.turnaroundTime = 0,
    this.state = ProcessState.ready,
    required this.color,
  }) : remainingTime = remainingTime ?? burstTime;

  double get progressRatio =>
      burstTime > 0 ? (burstTime - remainingTime) / burstTime : 0.0;

  /// Response Time in OS: time elapsed from arrival until first CPU dispatch.
  int get responseTime =>
      startTime != null ? (startTime! - arrivalTime).clamp(0, 999999) : 0;

  SimulatedProcess copyWith({
    int? pid,
    String? name,
    int? burstTime,
    int? remainingTime,
    int? arrivalTime,
    int? priority,
    int? memoryMb,
    String? packageName,
    Uint8List? iconBytes,
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
      memoryMb: memoryMb ?? this.memoryMb,
      packageName: packageName ?? this.packageName,
      iconBytes: iconBytes ?? this.iconBytes,
      startTime: startTime ?? this.startTime,
      completionTime: completionTime ?? this.completionTime,
      waitingTime: waitingTime ?? this.waitingTime,
      turnaroundTime: turnaroundTime ?? this.turnaroundTime,
      state: state ?? this.state,
      color: color ?? this.color,
    );
  }
}

