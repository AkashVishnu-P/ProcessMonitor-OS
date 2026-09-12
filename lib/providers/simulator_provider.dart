import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/academic_preset.dart';
import '../models/gantt_record.dart';
import '../models/simulated_process.dart';
import '../services/scheduling_algorithms.dart';
import '../services/voice_tutor_service.dart';

class SimulatorProvider extends ChangeNotifier {
  final List<SimulatedProcess> _readyQueue = [];
  SimulatedProcess? _runningProcess;
  final List<SimulatedProcess> _waitingQueue = [];
  final List<SimulatedProcess> _terminatedList = [];
  final List<GanttRecord> _ganttRecords = [];

  SchedulingAlgorithmType _selectedAlgorithm = SchedulingAlgorithmType.roundRobin;
  int _timeQuantum = 2;
  int _currentQuantumTicks = 0;

  // Automated Dynamic Workload Stream
  bool _autoGenerateStream = false;
  double _arrivalProbability = 0.30; // 30% chance per second

  // Context Switch Overhead Penalty
  int _contextSwitchDuration = 0; // 0s (ideal) or 1s (penalty)
  bool _isContextSwitching = false;
  int _currentContextSwitchTicksRemaining = 0;
  int _totalContextSwitches = 0;
  int _totalContextSwitchTicks = 0;

  // Voice Tutor Service for educational TTS narration
  final VoiceTutorService voiceTutor;

  bool _isRunning = false;
  int _currentTick = 0;
  int _pidCounter = 0;
  Timer? _timer;

  // Tracks the last PID that triggered a voice narration, so we only
  // narrate when the running process *actually changes* (not every tick).
  String? _lastNarratedPid;


  // Process color palette for clear visual distinction
  final List<Color> _processColors = [
    const Color(0xFF1E88E5), // Blue
    const Color(0xFF43A047), // Green
    const Color(0xFFFB8C00), // Orange
    const Color(0xFF8E24AA), // Purple
    const Color(0xFFE53935), // Red
    const Color(0xFF00ACC1), // Cyan
    const Color(0xFFFDD835), // Yellow
    const Color(0xFF6D4C41), // Brown
  ];

  SimulatorProvider({VoiceTutorService? voiceTutorService})
      : voiceTutor = voiceTutorService ?? VoiceTutorService() {
    _spawnInitialProcesses();
  }

  // Getters
  List<SimulatedProcess> get readyQueue => List.unmodifiable(_readyQueue);
  SimulatedProcess? get runningProcess => _runningProcess;
  List<SimulatedProcess> get waitingQueue => List.unmodifiable(_waitingQueue);
  List<SimulatedProcess> get terminatedList => List.unmodifiable(_terminatedList);
  List<GanttRecord> get ganttRecords => List.unmodifiable(_ganttRecords);

  SchedulingAlgorithmType get selectedAlgorithm => _selectedAlgorithm;
  int get timeQuantum => _timeQuantum;
  bool get isRunning => _isRunning;
  int get currentTick => _currentTick;

  bool get autoGenerateStream => _autoGenerateStream;
  double get arrivalProbability => _arrivalProbability;

  int get contextSwitchDuration => _contextSwitchDuration;
  bool get isContextSwitching => _isContextSwitching;
  int get totalContextSwitches => _totalContextSwitches;
  int get totalContextSwitchTicks => _totalContextSwitchTicks;
  double get contextSwitchOverheadPercentage =>
      _currentTick > 0 ? (_totalContextSwitchTicks / _currentTick) * 100 : 0.0;

  double get averageWaitingTime =>
      SchedulingAlgorithms.calculateAverageWaitingTime(_terminatedList);
  double get averageTurnaroundTime =>
      SchedulingAlgorithms.calculateAverageTurnaroundTime(_terminatedList);

  // Voice Tutor Controls
  bool get isVoiceTutorMuted => voiceTutor.isMuted;

  void toggleVoiceTutorMute() {
    voiceTutor.toggleMute();
    notifyListeners();
  }

  void setVoiceTutorMuted(bool muted) {
    voiceTutor.setMuted(muted);
    notifyListeners();
  }

  Future<void> explainCurrentAlgorithm() =>
      voiceTutor.explainAlgorithm(_selectedAlgorithm);

  Future<void> explainAlgorithm(SchedulingAlgorithmType algorithm) =>
      voiceTutor.explainAlgorithm(algorithm);

  void _spawnInitialProcesses() {
    _addProcessInternal(burst: 4, priority: 2);
    _addProcessInternal(burst: 3, priority: 1);
    _addProcessInternal(burst: 2, priority: 3);
  }

  void toggleAutoGenerateStream(bool enabled) {
    _autoGenerateStream = enabled;
    notifyListeners();
  }

  void setArrivalProbability(double prob) {
    _arrivalProbability = prob.clamp(0.05, 1.0);
    notifyListeners();
  }

  void setContextSwitchDuration(int seconds) {
    _contextSwitchDuration = seconds.clamp(0, 3);
    notifyListeners();
  }

  void loadPreset(AcademicPreset preset) {
    pauseSimulation();
    _readyQueue.clear();
    _runningProcess = null;
    _waitingQueue.clear();
    _terminatedList.clear();
    _ganttRecords.clear();
    _currentTick = 0;
    _pidCounter = 0;
    _currentQuantumTicks = 0;
    _isContextSwitching = false;
    _currentContextSwitchTicksRemaining = 0;
    _totalContextSwitches = 0;
    _totalContextSwitchTicks = 0;
    _lastNarratedPid = null;

    _selectedAlgorithm = preset.recommendedAlgorithm;

    switch (preset) {
      case AcademicPreset.convoyEffect:
        // P0 is a long CPU monopolizer (16s), P1-P3 are short jobs (2s each)
        _addProcessInternal(burst: 16, priority: 3);
        _addProcessInternal(burst: 2, priority: 2);
        _addProcessInternal(burst: 2, priority: 2);
        _addProcessInternal(burst: 2, priority: 2);
        break;

      case AcademicPreset.priorityStarvation:
        // P0 has lowest priority (5) with 10s burst, while P1-P3 have priority 1-2
        _addProcessInternal(burst: 10, priority: 5);
        _addProcessInternal(burst: 2, priority: 2);
        _addProcessInternal(burst: 2, priority: 1);
        _addProcessInternal(burst: 3, priority: 2);
        break;

      case AcademicPreset.ioBoundMix:
        // Mix of compute-heavy (8s) and quick interactive tasks (2s)
        _addProcessInternal(burst: 8, priority: 3);
        _addProcessInternal(burst: 2, priority: 1);
        _addProcessInternal(burst: 8, priority: 3);
        _addProcessInternal(burst: 2, priority: 2);
        break;
    }

    notifyListeners();
  }

  void spawnProcess({int? customBurst, int? customPriority}) {
    final random = Random();
    final burst = customBurst ?? (random.nextInt(8) + 1); // 1 to 8 seconds
    final priority = customPriority ?? (random.nextInt(5) + 1); // 1 to 5
    _addProcessInternal(burst: burst, priority: priority);

    // Dynamic preemption check upon new arrival
    if (_runningProcess != null && _selectedAlgorithm.isPreemptive) {
      if (SchedulingAlgorithms.shouldPreempt(
        running: _runningProcess!,
        readyQueue: _readyQueue,
        algorithm: _selectedAlgorithm,
      )) {
        _triggerPreemption();
      }
    }

    notifyListeners();
  }

  void _addProcessInternal({required int burst, required int priority}) {
    final color = _processColors[_pidCounter % _processColors.length];
    // OS Concept: Process Creation -> state initialized as newProcess (Secondary Storage / Job Queue)
    final process = SimulatedProcess(
      pid: _pidCounter,
      name: 'P$_pidCounter',
      burstTime: burst,
      priority: priority,
      arrivalTime: _currentTick,
      state: ProcessState.newProcess,
      color: color,
    );
    _pidCounter++;
    // OS Concept: Long-Term Scheduler (Job Scheduler) admits process into Main Memory (Ready Queue)
    process.state = ProcessState.ready;
    _readyQueue.add(process);
  }

  void setAlgorithm(SchedulingAlgorithmType algorithm) {
    if (_selectedAlgorithm == algorithm) return;
    _selectedAlgorithm = algorithm;
    _currentQuantumTicks = 0;
    notifyListeners();
  }

  void setTimeQuantum(int quantum) {
    if (quantum < 1) return;
    _timeQuantum = quantum;
    notifyListeners();
  }

  void startSimulation() {
    if (_isRunning) return;
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      stepTick();
    });
    notifyListeners();
  }

  void pauseSimulation() {
    if (!_isRunning) return;
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  void resetSimulation() {
    pauseSimulation();
    _readyQueue.clear();
    _runningProcess = null;
    _waitingQueue.clear();
    _terminatedList.clear();
    _ganttRecords.clear();
    _currentTick = 0;
    _pidCounter = 0;
    _currentQuantumTicks = 0;
    _isContextSwitching = false;
    _currentContextSwitchTicksRemaining = 0;
    _totalContextSwitches = 0;
    _totalContextSwitchTicks = 0;
    _lastNarratedPid = null;
    _spawnInitialProcesses();
    notifyListeners();
  }

  void stepTick() {
    _currentTick++;

    // 1. Automated Dynamic Workload Stream arrival check
    if (_autoGenerateStream && Random().nextDouble() < _arrivalProbability) {
      spawnProcess();
    }

    // 2. Increment waiting time for queues
    for (final p in _readyQueue) {
      p.waitingTime++;
    }
    for (final p in _waitingQueue) {
      p.waitingTime++;
    }

    // 3. Handle Transient Context Switching state
    if (_isContextSwitching) {
      _totalContextSwitchTicks++;
      _recordGanttTick(
        '[CS]',
        const Color(0xFF78909C),
        isContextSwitch: true,
        stateLabel: 'Overhead',
      );
      _currentContextSwitchTicksRemaining--;
      if (_currentContextSwitchTicksRemaining <= 0) {
        _isContextSwitching = false;
      }
      notifyListeners();
      return; // CPU spent this second in context switch overhead
    }

    // 4. Short-Term Scheduler (CPU Dispatcher)
    // OS Concept: Process state transitions from Ready -> Running when acquiring the CPU
    if (_runningProcess == null && _readyQueue.isNotEmpty) {
      final next = SchedulingAlgorithms.selectNextProcess(
        readyQueue: _readyQueue,
        algorithm: _selectedAlgorithm,
      );
      if (next != null) {
        _readyQueue.remove(next);
        next.state = ProcessState.running;
        next.startTime ??= _currentTick;
        _runningProcess = next;
        _currentQuantumTicks = 0;
        // Only narrate if a *different* process has been dispatched
        if (_lastNarratedPid != next.name) {
          _lastNarratedPid = next.name;
          voiceTutor.narrateContextSwitch(runningPid: next.name);
        }
      }
    }


    // 5. Execute 1 tick of active process on CPU core
    if (_runningProcess != null) {
      final current = _runningProcess!;
      // Actively update process state to Running before adding to timeline stream
      current.state = ProcessState.running;
      current.remainingTime--;
      _currentQuantumTicks++;

      _recordGanttTick(
        current.name,
        current.color,
        isContextSwitch: false,
        stateLabel: 'Running',
      );

      if (current.remainingTime <= 0) {
        // OS Concept: Process invokes exit() system call; resources reclaimed by kernel
        // Process state transitions from Running -> Terminated
        current.state = ProcessState.terminated;
        current.completionTime = _currentTick;
        current.turnaroundTime = _currentTick - current.arrivalTime;
        current.waitingTime = current.turnaroundTime - current.burstTime;
        if (current.waitingTime < 0) current.waitingTime = 0;

        _terminatedList.insert(0, current);
        _runningProcess = null;
        _currentQuantumTicks = 0;
        voiceTutor.narrateTermination(current.name);

        // Context switch penalty when switching to next job if queue not empty
        if (_contextSwitchDuration > 0 && _readyQueue.isNotEmpty) {
          _triggerContextSwitch();
        }
      } else if (_selectedAlgorithm == SchedulingAlgorithmType.roundRobin &&
          _currentQuantumTicks >= _timeQuantum) {
        // OS Concept: Hardware Timer Interrupt signals Time Quantum Expiration
        // Process state transitions from Running -> Ready (preempted to rear of ready queue)
        final preemptedName = current.name;
        current.state = ProcessState.ready;
        _readyQueue.add(current);
        _runningProcess = null;
        _currentQuantumTicks = 0;

        final nextProcess = _readyQueue.isNotEmpty ? _readyQueue.first.name : 'idle';
        // Always narrate RR preemption — the process genuinely switched
        _lastNarratedPid = nextProcess;
        voiceTutor.narrateContextSwitch(
          preemptedPid: preemptedName,
          runningPid: nextProcess,
          reason: 'quantum expiration',
        );

        if (_contextSwitchDuration > 0) {
          _triggerContextSwitch();
        }
      } else if (_selectedAlgorithm.isPreemptive &&
          SchedulingAlgorithms.shouldPreempt(
            running: current,
            readyQueue: _readyQueue,
            algorithm: _selectedAlgorithm,
          )) {
        // OS Concept: Preemptive Scheduling Interrupt (SRTF or PPBS)
        // High-priority or shorter job enters Ready queue; current running process yields
        // Process state transitions from Running -> Ready
        final preemptedName = current.name;
        current.state = ProcessState.ready;
        _readyQueue.add(current);
        _runningProcess = null;
        _currentQuantumTicks = 0;

        final nextCandidate = SchedulingAlgorithms.selectNextProcess(
          readyQueue: _readyQueue,
          algorithm: _selectedAlgorithm,
        );
        final nextName = nextCandidate?.name ?? 'next process';
        final reason = _selectedAlgorithm == SchedulingAlgorithmType.ppbs
            ? 'higher priority process'
            : 'shorter remaining burst';
        // Always narrate genuine preemptions — a real switch occurred
        _lastNarratedPid = nextName;
        voiceTutor.narrateContextSwitch(
          preemptedPid: preemptedName,
          runningPid: nextName,
          reason: reason,
        );

        if (_contextSwitchDuration > 0) {
          _triggerContextSwitch();
        }
      }
    }


    // Auto-pause when all queues are finished
    if (_runningProcess == null &&
        _readyQueue.isEmpty &&
        _waitingQueue.isEmpty &&
        !_autoGenerateStream &&
        !_isContextSwitching) {
      pauseSimulation();
    }

    notifyListeners();
  }

  void _triggerPreemption() {
    if (_runningProcess != null) {
      // OS Concept: Preemption moves active task: Running -> Ready
      _runningProcess!.state = ProcessState.ready;
      _readyQueue.add(_runningProcess!);
      _runningProcess = null;
      _currentQuantumTicks = 0;
    }
    if (_contextSwitchDuration > 0) {
      _triggerContextSwitch();
    }
  }

  void _triggerContextSwitch() {
    _isContextSwitching = true;
    _currentContextSwitchTicksRemaining = _contextSwitchDuration;
    _totalContextSwitches++;
  }

  void _recordGanttTick(String pid, Color color, {required bool isContextSwitch, String stateLabel = 'Running'}) {
    if (_ganttRecords.isNotEmpty) {
      final last = _ganttRecords.last;
      if (last.pid == pid &&
          last.isContextSwitch == isContextSwitch &&
          last.stateLabel == stateLabel &&
          last.endTick == _currentTick - 1) {
        last.endTick = _currentTick;
        return;
      }
    }
    _ganttRecords.add(GanttRecord(
      pid: pid,
      startTick: _currentTick - 1,
      endTick: _currentTick,
      color: color,
      isContextSwitch: isContextSwitch,
      stateLabel: stateLabel,
    ));
  }

  // Interactive OS concepts: Move process to/from Waiting (simulating I/O operation)
  void simulateIoBlockRunningProcess() {
    if (_runningProcess == null) return;
    final process = _runningProcess!;
    // OS Concept: Process issues I/O system call, moving Running -> Waiting (Blocked)
    process.state = ProcessState.waiting;
    _waitingQueue.add(process);
    _runningProcess = null;
    _currentQuantumTicks = 0;

    if (_contextSwitchDuration > 0 && _readyQueue.isNotEmpty) {
      _triggerContextSwitch();
    }

    notifyListeners();
  }

  void simulateIoComplete(SimulatedProcess process) {
    if (_waitingQueue.remove(process)) {
      // OS Concept: I/O Hardware Interrupt signals completion, moving Waiting -> Ready
      process.state = ProcessState.ready;
      _readyQueue.add(process);

      // Preemption check when I/O completes and returns to Ready
      if (_runningProcess != null && _selectedAlgorithm.isPreemptive) {
        if (SchedulingAlgorithms.shouldPreempt(
          running: _runningProcess!,
          readyQueue: _readyQueue,
          algorithm: _selectedAlgorithm,
        )) {
          _triggerPreemption();
        }
      }

      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    voiceTutor.dispose();
    super.dispose();
  }
}
