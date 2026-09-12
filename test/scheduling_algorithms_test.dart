import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:process_monitor/core/constants/app_constants.dart';
import 'package:process_monitor/models/simulated_process.dart';
import 'package:process_monitor/services/scheduling_algorithms.dart';

void main() {
  group('Scheduling Algorithms Tests', () {
    test('FCFS selects head of ready queue', () {
      final p1 = SimulatedProcess(
        pid: 1,
        name: 'P1',
        burstTime: 5,
        arrivalTime: 0,
        color: Colors.blue,
      );
      final p2 = SimulatedProcess(
        pid: 2,
        name: 'P2',
        burstTime: 2,
        arrivalTime: 1,
        color: Colors.green,
      );

      final next = SchedulingAlgorithms.selectNextProcess(
        readyQueue: [p1, p2],
        algorithm: SchedulingAlgorithmType.fcfs,
      );

      expect(next, equals(p1));
    });

    test('SJF selects process with smallest burst time', () {
      final p1 = SimulatedProcess(
        pid: 1,
        name: 'P1',
        burstTime: 8,
        remainingTime: 8,
        arrivalTime: 0,
        color: Colors.blue,
      );
      final p2 = SimulatedProcess(
        pid: 2,
        name: 'P2',
        burstTime: 3,
        remainingTime: 3,
        arrivalTime: 1,
        color: Colors.green,
      );
      final p3 = SimulatedProcess(
        pid: 3,
        name: 'P3',
        burstTime: 5,
        remainingTime: 5,
        arrivalTime: 2,
        color: Colors.orange,
      );

      final next = SchedulingAlgorithms.selectNextProcess(
        readyQueue: [p1, p2, p3],
        algorithm: SchedulingAlgorithmType.sjf,
      );

      expect(next, equals(p2));
      expect(next?.burstTime, equals(3));
    });

    test('SRTF selects process with smallest remaining burst time', () {
      final p1 = SimulatedProcess(
        pid: 1,
        name: 'P1',
        burstTime: 8,
        remainingTime: 4, // 4s remaining
        arrivalTime: 0,
        color: Colors.blue,
      );
      final p2 = SimulatedProcess(
        pid: 2,
        name: 'P2',
        burstTime: 3,
        remainingTime: 2, // 2s remaining
        arrivalTime: 1,
        color: Colors.green,
      );

      final next = SchedulingAlgorithms.selectNextProcess(
        readyQueue: [p1, p2],
        algorithm: SchedulingAlgorithmType.srtf,
      );

      expect(next, equals(p2));
    });

    test('SRTF shouldPreempt returns true when shorter process exists in readyQueue', () {
      final running = SimulatedProcess(
        pid: 1,
        name: 'P1',
        burstTime: 6,
        remainingTime: 5,
        arrivalTime: 0,
        color: Colors.blue,
      );
      final ready = SimulatedProcess(
        pid: 2,
        name: 'P2',
        burstTime: 2,
        remainingTime: 2, // 2s < 5s remaining
        arrivalTime: 1,
        color: Colors.green,
      );

      final preempt = SchedulingAlgorithms.shouldPreempt(
        running: running,
        readyQueue: [ready],
        algorithm: SchedulingAlgorithmType.srtf,
      );

      expect(preempt, isTrue);
    });

    test('PBS selects process with highest priority (lowest number)', () {
      final p1 = SimulatedProcess(
        pid: 1,
        name: 'P1',
        burstTime: 5,
        priority: 3,
        arrivalTime: 0,
        color: Colors.blue,
      );
      final p2 = SimulatedProcess(
        pid: 2,
        name: 'P2',
        burstTime: 5,
        priority: 1, // Priority 1 > Priority 3
        arrivalTime: 1,
        color: Colors.green,
      );

      final next = SchedulingAlgorithms.selectNextProcess(
        readyQueue: [p1, p2],
        algorithm: SchedulingAlgorithmType.pbs,
      );

      expect(next, equals(p2));
      expect(next?.priority, equals(1));
    });

    test('PPBS shouldPreempt returns true when higher priority process arrives', () {
      final running = SimulatedProcess(
        pid: 1,
        name: 'P1',
        burstTime: 6,
        priority: 3,
        arrivalTime: 0,
        color: Colors.blue,
      );
      final ready = SimulatedProcess(
        pid: 2,
        name: 'P2',
        burstTime: 4,
        priority: 1, // Priority 1 is higher than running Priority 3
        arrivalTime: 1,
        color: Colors.green,
      );

      final preempt = SchedulingAlgorithms.shouldPreempt(
        running: running,
        readyQueue: [ready],
        algorithm: SchedulingAlgorithmType.ppbs,
      );

      expect(preempt, isTrue);
    });

    test('Average Waiting Time and Turnaround Time calculations', () {
      final p1 = SimulatedProcess(
        pid: 1,
        name: 'P1',
        burstTime: 4,
        arrivalTime: 0,
        waitingTime: 2,
        turnaroundTime: 6,
        color: Colors.blue,
      );
      final p2 = SimulatedProcess(
        pid: 2,
        name: 'P2',
        burstTime: 3,
        arrivalTime: 1,
        waitingTime: 4,
        turnaroundTime: 7,
        color: Colors.green,
      );

      final awt = SchedulingAlgorithms.calculateAverageWaitingTime([p1, p2]);
      final att = SchedulingAlgorithms.calculateAverageTurnaroundTime([p1, p2]);

      expect(awt, equals(3.0));
      expect(att, equals(6.5));
    });
  });
}
