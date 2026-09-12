import 'package:flutter_test/flutter_test.dart';
import 'package:process_monitor/core/constants/app_constants.dart';
import 'package:process_monitor/models/academic_preset.dart';
import 'package:process_monitor/providers/simulator_provider.dart';
import 'package:process_monitor/services/voice_tutor_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SimulatorProvider State Machine Tests', () {
    late SimulatorProvider provider;

    setUp(() {
      provider = SimulatorProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    test('Initial state contains 3 sample processes with priorities', () {
      expect(provider.readyQueue.length, equals(3));
      expect(provider.runningProcess, isNull);
      expect(provider.terminatedList, isEmpty);
      expect(provider.readyQueue.any((p) => p.priority > 0), isTrue);
    });

    test('Spawning a process with custom priority adds to readyQueue', () {
      provider.spawnProcess(customBurst: 5, customPriority: 1);
      expect(provider.readyQueue.length, equals(4));
      expect(provider.readyQueue.last.burstTime, equals(5));
      expect(provider.readyQueue.last.priority, equals(1));
    });

    test('Step tick moves process from readyQueue to runningProcess', () {
      provider.setAlgorithm(SchedulingAlgorithmType.fcfs);
      final firstInQueue = provider.readyQueue.first;

      provider.stepTick();

      expect(provider.runningProcess, isNotNull);
      expect(provider.runningProcess?.pid, equals(firstInQueue.pid));
      expect(provider.readyQueue.length, equals(2));
    });

    test('Round Robin preempts running process when time quantum expires', () {
      provider.setAlgorithm(SchedulingAlgorithmType.roundRobin);
      provider.setTimeQuantum(2);

      provider.resetSimulation();
      final p0 = provider.readyQueue[0];

      // Tick 1
      provider.stepTick();
      expect(provider.runningProcess?.pid, equals(p0.pid));
      expect(provider.runningProcess?.remainingTime, equals(3));

      // Tick 2: Preempted back to queue
      provider.stepTick();
      expect(provider.runningProcess, isNull);
      expect(provider.readyQueue.last.pid, equals(p0.pid));
    });

    test('SRTF preempts running process when shorter process arrives', () {
      provider.setAlgorithm(SchedulingAlgorithmType.srtf);
      provider.resetSimulation();

      // Tick 1: P2 (burst 2) enters CPU, remaining becomes 1
      provider.stepTick();
      // Tick 2: P2 finishes and terminates
      provider.stepTick();
      // Tick 3: P1 (burst 3) enters CPU, remaining becomes 2
      provider.stepTick();

      expect(provider.runningProcess, isNotNull);
      expect(provider.runningProcess?.remainingTime, greaterThan(1));
      final runningPid = provider.runningProcess!.pid;

      // Spawn a shorter process with burst 1 (< remaining 2)
      provider.spawnProcess(customBurst: 1);

      // Preemption triggers: running process returns to readyQueue
      expect(provider.runningProcess, isNull);
      expect(provider.readyQueue.any((p) => p.pid == runningPid), isTrue);

      // Next step tick executes the new shortest process (burst 1), completing it in 1 tick
      provider.stepTick();
      expect(provider.terminatedList.first.burstTime, equals(1));
    });

    test('PPBS preempts running process when higher priority process arrives', () {
      provider.setAlgorithm(SchedulingAlgorithmType.ppbs);
      provider.resetSimulation();

      // Tick 1: P1 (priority 1, burst 3) enters CPU (remaining 2)
      provider.stepTick();
      // Tick 2: P1 executes (remaining 1)
      provider.stepTick();
      // Tick 3: P1 executes and terminates
      provider.stepTick();
      // Tick 4: P0 (priority 2, burst 4) enters CPU (remaining 3)
      provider.stepTick();

      expect(provider.runningProcess, isNotNull);
      expect(provider.runningProcess?.priority, equals(2));

      // Spawn new process with higher priority (Priority 1 < Priority 2)
      provider.spawnProcess(customBurst: 3, customPriority: 1);

      // Preemption should immediately trigger: running process P0 yields back to readyQueue
      expect(provider.runningProcess, isNull);

      // Next step tick should schedule the new Priority 1 process
      provider.stepTick();
      expect(provider.runningProcess?.priority, equals(1));
    });

    test('AcademicPreset.convoyEffect loads P0 (16s) and P1-P3 (2s each)', () {
      provider.loadPreset(AcademicPreset.convoyEffect);

      expect(provider.readyQueue.length, equals(4));
      expect(provider.readyQueue[0].burstTime, equals(16));
      expect(provider.readyQueue[1].burstTime, equals(2));
      expect(provider.readyQueue[2].burstTime, equals(2));
      expect(provider.readyQueue[3].burstTime, equals(2));
      expect(provider.selectedAlgorithm, equals(SchedulingAlgorithmType.fcfs));
    });

    test('AcademicPreset.priorityStarvation loads P0 with lowest priority', () {
      provider.loadPreset(AcademicPreset.priorityStarvation);

      expect(provider.readyQueue.length, equals(4));
      expect(provider.readyQueue[0].priority, equals(5)); // Lowest priority
      expect(provider.selectedAlgorithm, equals(SchedulingAlgorithmType.ppbs));
    });

    test('Dynamic Workload Stream auto-generates processes on clock tick', () {
      provider.resetSimulation();
      provider.toggleAutoGenerateStream(true);
      provider.setArrivalProbability(1.0); // 100% arrival rate for test

      final countBefore = provider.readyQueue.length;
      provider.stepTick();

      // One process moved to CPU or ready queue grew
      final totalActive = provider.readyQueue.length + (provider.runningProcess != null ? 1 : 0);
      expect(totalActive, greaterThan(countBefore));
    });

    test('Context Switch penalty pauses CPU for 1 tick during preemption', () {
      provider.setAlgorithm(SchedulingAlgorithmType.roundRobin);
      provider.setTimeQuantum(2);
      provider.setContextSwitchDuration(1); // 1s context switch overhead
      provider.resetSimulation();

      // Tick 1: runs
      provider.stepTick();
      expect(provider.isContextSwitching, isFalse);

      // Tick 2: runs and quantum expires, preemption triggers context switch
      provider.stepTick();
      expect(provider.isContextSwitching, isTrue);
      expect(provider.totalContextSwitches, greaterThanOrEqualTo(1));

      // Tick 3: CPU spends 1 tick doing context switch
      provider.stepTick();
      expect(provider.totalContextSwitchTicks, equals(1));
      expect(provider.ganttRecords.any((r) => r.isContextSwitch), isTrue);
    });

    test('Live Gantt Chart records contiguous execution slices', () {
      provider.setAlgorithm(SchedulingAlgorithmType.fcfs);
      provider.resetSimulation();

      // Run 3 ticks of the first process (P0 has burst 4)
      provider.stepTick();
      provider.stepTick();
      provider.stepTick();

      // Gantt records should have coalesced ticks of P0 into a single slice of duration 3
      expect(provider.ganttRecords.length, equals(1));
      expect(provider.ganttRecords.first.pid, equals('P0'));
      expect(provider.ganttRecords.first.duration, equals(3));
      expect(provider.ganttRecords.first.startTick, equals(0));
      expect(provider.ganttRecords.first.endTick, equals(3));
    });

    test('Process lifecycle correctly transitions states: Ready -> Running -> Terminated', () {
      provider.setAlgorithm(SchedulingAlgorithmType.fcfs);
      provider.resetSimulation();

      // Initially all staged processes must be in Ready state
      expect(provider.readyQueue.every((p) => p.state == ProcessState.ready), isTrue);

      // Tick 1: P0 dispatched to CPU -> state becomes Running
      provider.stepTick();
      expect(provider.runningProcess, isNotNull);
      expect(provider.runningProcess?.state, equals(ProcessState.running));

      // Tick 2, 3, 4: complete P0 (burst 4)
      provider.stepTick();
      provider.stepTick();
      provider.stepTick();

      // P0 completed execution -> state becomes Terminated
      expect(provider.terminatedList.first.state, equals(ProcessState.terminated));
    });

    test('I/O simulation transitions process states: Running -> Waiting -> Ready', () {
      provider.setAlgorithm(SchedulingAlgorithmType.fcfs);
      provider.resetSimulation();

      // Dispatch P0 to CPU
      provider.stepTick();
      expect(provider.runningProcess?.state, equals(ProcessState.running));

      // Trigger I/O block
      provider.simulateIoBlockRunningProcess();
      expect(provider.runningProcess, isNull);
      expect(provider.waitingQueue.length, equals(1));
      expect(provider.waitingQueue.first.state, equals(ProcessState.waiting));

      // Complete I/O
      final waitingProcess = provider.waitingQueue.first;
      provider.simulateIoComplete(waitingProcess);
      expect(provider.waitingQueue, isEmpty);
      expect(waitingProcess.state, equals(ProcessState.ready));
      expect(provider.readyQueue.contains(waitingProcess), isTrue);
    });

    test('VoiceTutorService provides academic definitions for all 6 algorithms', () {
      for (final algo in SchedulingAlgorithmType.values) {
        final explanation = VoiceTutorService.getAlgorithmAcademicExplanation(algo);
        expect(explanation.isNotEmpty, isTrue);
        expect(explanation.contains('disadvantage'), isTrue);
      }
    });

    test('VoiceTutor mute toggle silences speech', () {
      expect(provider.isVoiceTutorMuted, isFalse);
      provider.toggleVoiceTutorMute();
      expect(provider.isVoiceTutorMuted, isTrue);
      provider.toggleVoiceTutorMute();
      expect(provider.isVoiceTutorMuted, isFalse);
    });
  });
}
