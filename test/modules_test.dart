import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:process_monitor/core/constants/app_constants.dart';
import 'package:process_monitor/models/simulated_process.dart';
import 'package:process_monitor/providers/apps_provider.dart';
import 'package:process_monitor/providers/simulator_provider.dart';
import 'package:process_monitor/services/scheduling_algorithms.dart';
import 'package:process_monitor/utils/professor_explanations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Module 2 & 3: AppsProvider & Simulated Process Generator Tests', () {
    test('AppsProvider loads mock apps and filters correctly', () async {
      final provider = AppsProvider();
      await provider.fetchInstalledApps();

      expect(provider.allApps.isNotEmpty, isTrue);
      expect(provider.selectedCount, greaterThanOrEqualTo(1));

      // Filter query test
      provider.setSearchQuery('Chrome');
      expect(provider.filteredApps.length, 1);
      expect(provider.filteredApps.first.name, 'Google Chrome');

      provider.setSearchQuery('');
      expect(provider.filteredApps.length, provider.allApps.length);
    });

    test('generateSimulatedProcesses produces realistic OS scheduling parameters', () async {
      final provider = AppsProvider();
      await provider.fetchInstalledApps();

      // Ensure 3 apps selected
      provider.deselectAll();
      provider.toggleAppSelection(provider.allApps[0]); // Chrome
      provider.toggleAppSelection(provider.allApps[1]); // WhatsApp
      provider.toggleAppSelection(provider.allApps[2]); // Spotify

      final processes = provider.generateSimulatedProcesses();
      expect(processes.length, 3);

      for (final p in processes) {
        expect(p.name.isNotEmpty, isTrue);
        expect(p.pid, greaterThanOrEqualTo(1000));
        expect(p.burstTime, inInclusiveRange(2, 20));
        expect(p.priority, inInclusiveRange(1, 10));
        expect(p.memoryMb, inInclusiveRange(120, 800));
        expect(p.state, ProcessState.ready);
        expect(p.arrivalTime, 0);
      }
    });
  });

  group('Module 7: Extended Metrics & Calculations Tests', () {
    test('calculateAverageResponseTime computes correct mean response time', () {
      final p1 = SimulatedProcess(
        pid: 1,
        name: 'P1',
        burstTime: 5,
        arrivalTime: 0,
        startTime: 2, // response time = 2 - 0 = 2
        completionTime: 5,
        color: const Color(0xFF1E88E5),
      );
      final p2 = SimulatedProcess(
        pid: 2,
        name: 'P2',
        burstTime: 4,
        arrivalTime: 1,
        startTime: 5, // response time = 5 - 1 = 4
        completionTime: 9,
        color: const Color(0xFF43A047),
      );

      final avgResp = SchedulingAlgorithms.calculateAverageResponseTime([p1, p2]);
      expect(avgResp, (2 + 4) / 2.0);
    });

    test('calculateCpuUtilization and calculateThroughput work correctly', () {
      final util = SchedulingAlgorithms.calculateCpuUtilization(totalTicks: 10, idleTicks: 2);
      expect(util, 80.0);

      final throughput = SchedulingAlgorithms.calculateThroughput(completedCount: 4, totalTicks: 20);
      expect(throughput, 0.2);
    });
  });

  group('Module 9: RAM Allocation & Tracking Tests', () {
    test('SimulatorProvider tracks kernel and process memory correctly', () {
      final sim = SimulatorProvider();
      expect(sim.totalMemoryMb, 4096);
      expect(sim.kernelMemoryMb, 512);

      // Initial processes exist in ready queue
      final initialAllocated = sim.allocatedProcessMemoryMb;
      expect(initialAllocated, greaterThan(0));
      expect(sim.freeMemoryMb, 4096 - 512 - initialAllocated);

      // Loading custom processes updates memory
      final customProcesses = [
        SimulatedProcess(
          pid: 101,
          name: 'CustomApp',
          burstTime: 4,
          memoryMb: 400,
          arrivalTime: 0,
          color: const Color(0xFF1E88E5),
        ),
      ];
      sim.loadCustomProcesses(customProcesses);

      expect(sim.readyQueue.length, 1);
      expect(sim.allocatedProcessMemoryMb, 400);
      expect(sim.freeMemoryMb, 4096 - 512 - 400);
    });
  });

  group('Module 10: Professor Mode Explanations Tests', () {
    test('Returns comprehensive general viva questions', () {
      final explanations = ProfessorExplanations.getGeneralExplanations();
      expect(explanations.length, greaterThanOrEqualTo(8));

      final titles = explanations.map((e) => e.title).toList();
      expect(titles.any((t) => t.contains('Round Robin')), isTrue);
      expect(titles.any((t) => t.contains('Context Switching')), isTrue);
      expect(titles.any((t) => t.contains('Starvation')), isTrue);
      expect(titles.any((t) => t.contains('Waiting Time')), isTrue);
      expect(titles.any((t) => t.contains('Response Time')), isTrue);
      expect(titles.any((t) => t.contains('5-State')), isTrue);
      expect(titles.any((t) => t.contains('Memory Management')), isTrue);
      expect(titles.any((t) => t.contains('Deadlock')), isTrue);
    });

    test('explainWhyChosen and explainWhyPreempted generate contextual audits', () {
      final chosen = ProfessorExplanations.explainWhyChosen(
        algorithm: 'Shortest Job First',
        processName: 'Google Chrome',
        reason: 'shortest burst time (3s)',
      );
      expect(chosen.title, contains('Google Chrome'));
      expect(chosen.speechText, contains('shortest burst time (3s)'));

      final preempted = ProfessorExplanations.explainWhyPreempted(
        algorithm: 'Preemptive Priority',
        preemptedProcess: 'Camera',
        newProcess: 'WhatsApp',
        reason: 'higher priority job arrived',
      );
      expect(preempted.title, contains('Camera'));
      expect(preempted.speechText, contains('WhatsApp'));
    });
  });
}
