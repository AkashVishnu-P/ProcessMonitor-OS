import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../core/constants/app_constants.dart';

/// Educational Voice Tutor service using Text-to-Speech (TTS)
/// for explaining CPU scheduling algorithms and narrating live OS context switches.
///
/// Uses a "latest-wins pending queue" pattern to eliminate mid-word cutoffs:
///   - If TTS is already speaking when a new narration arrives, the new text is
///     stored in [_pendingNarration] (overwriting any previous pending text).
///   - When the current utterance finishes naturally, [_drainPending] fires the
///     stored narration WITHOUT ever calling stop() mid-utterance.
///   - This guarantees every word is spoken fully before the next one starts.
class VoiceTutorService {
  FlutterTts? _flutterTts;
  bool _isMuted = false;
  bool _isInitialized = false;
  bool _isSpeaking = false;

  /// Holds the most recent narration requested while TTS was busy speaking.
  /// "Latest-wins": rapid context switches overwrite stale pending narrations
  /// so the tutor always announces the most current process state.
  String? _pendingNarration;

  VoiceTutorService({FlutterTts? tts}) : _flutterTts = tts;

  FlutterTts get _tts => _flutterTts ??= FlutterTts();

  bool get isMuted => _isMuted;
  bool get isInitialized => _isInitialized;
  bool get isSpeaking => _isSpeaking;

  /// Globally toggles mute status so students/professors can silence the tutor during viva presentations.
  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      stop();
    }
  }

  void setMuted(bool muted) {
    _isMuted = muted;
    if (_isMuted) {
      stop();
    }
  }

  /// Initializes the TTS engine with speech parameters and completion-based queue handlers.
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.75); // Faster delivery: finishes within 1s quanta
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      _tts.setStartHandler(() {
        _isSpeaking = true;
      });

      // When an utterance finishes naturally, drain any pending narration.
      // This is the key fix: _drainPending() speaks without calling stop().
      _tts.setCompletionHandler(() {
        _isSpeaking = false;
        _drainPending();
      });

      _tts.setCancelHandler(() {
        _isSpeaking = false;
        _drainPending();
      });

      _tts.setErrorHandler((dynamic msg) {
        _isSpeaking = false;
        _pendingNarration = null; // Discard on error; don't replay broken state
        debugPrint('VoiceTutorService TTS error: $msg');
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('VoiceTutorService initialization notice: $e');
    }
  }

  /// Drains the pending narration queue after the current utterance completes.
  /// Called only from completion/cancel handlers — never calls stop().
  void _drainPending() {
    if (_pendingNarration != null && !_isMuted) {
      final text = _pendingNarration!;
      _pendingNarration = null;
      _speakDirect(text);
    }
  }

  /// Internal: fires _tts.speak() immediately without any stop() guard.
  /// Caller must ensure mute/init checks are done before calling this.
  void _speakDirect(String text) {
    _isSpeaking = true;
    _tts.speak(text).catchError((Object e) {
      _isSpeaking = false;
      debugPrint('VoiceTutorService speak error: $e');
    });
  }

  /// Speaks [text] using the pending-queue strategy:
  ///   - TTS idle  → speak immediately (no stop() call).
  ///   - TTS busy  → store as [_pendingNarration]; completionHandler will fire it.
  Future<void> speak(String text) async {
    if (_isMuted) return;
    try {
      if (!_isInitialized) {
        await init();
      }
      if (_isSpeaking) {
        // Latest-wins: overwrite stale pending with the most recent event
        _pendingNarration = text;
        return;
      }
      _pendingNarration = null;
      _speakDirect(text);
    } catch (e) {
      _isSpeaking = false;
      debugPrint('VoiceTutorService speech error: $e');
    }
  }

  /// Halts active speech and clears any queued narration.
  Future<void> stop() async {
    _isSpeaking = false;
    _pendingNarration = null;
    try {
      if (_flutterTts != null) {
        await _tts.stop();
      }
    } catch (e) {
      debugPrint('VoiceTutorService stop error: $e');
    }
  }

  /// Feature A: Static Academic Explanations
  /// Returns a concise 2-sentence academic definition detailing how the algorithm works
  /// and highlighting its primary disadvantage for viva evaluation.
  static String getAlgorithmAcademicExplanation(SchedulingAlgorithmType algorithm) {
    switch (algorithm) {
      case SchedulingAlgorithmType.fcfs:
        return 'First-Come-First-Serve schedules processes strictly in the order of their arrival without preemption. '
            'Its primary disadvantage is the Convoy Effect, where short processes suffer high waiting times behind long CPU-burst jobs.';

      case SchedulingAlgorithmType.sjf:
        return 'Shortest Job First selects the ready process with the smallest CPU burst time next, provably minimizing average waiting time in batch systems. '
            'Its primary disadvantage is starvation of longer jobs and the practical impossibility of knowing future burst times in interactive systems.';

      case SchedulingAlgorithmType.srtf:
        return 'Shortest Remaining Time First is the preemptive variant of Shortest Job First that preempts the CPU if a newly arrived process requires less remaining time. '
            'Its primary disadvantage is high context switching overhead and indefinite starvation of CPU-intensive workloads.';

      case SchedulingAlgorithmType.roundRobin:
        return 'Round Robin allocates each ready process a fixed time quantum before cyclically preempting it to the rear of the ready queue. '
            'Its primary disadvantage is high sensitivity to quantum size, generating excessive context switching overhead if the quantum is configured too short.';

      case SchedulingAlgorithmType.pbs:
        return 'Priority-Based Scheduling executes the ready process with the highest priority to completion without interruption. '
            'Its primary disadvantage is indefinite blocking or starvation, where low-priority processes can be blocked indefinitely without dynamic aging.';

      case SchedulingAlgorithmType.ppbs:
        return 'Preemptive Priority Scheduling immediately interrupts the running process whenever a process with strictly higher priority arrives in the ready queue. '
            'Its primary disadvantage is frequent preemption cascades and indefinite starvation of low-priority background workloads.';
    }
  }

  /// Feature A: Speaks the 2-sentence academic explanation for the given algorithm.
  Future<void> explainAlgorithm(SchedulingAlgorithmType algorithm) async {
    final explanation = getAlgorithmAcademicExplanation(algorithm);
    await speak(explanation);
  }

  /// Feature A+: Extended Academic Explanations for Viva & Lab Defense
  static String getConceptExplanation(String topic) {
    switch (topic.toLowerCase().trim()) {
      case 'context switching':
        return 'A context switch saves the state of the active process into its PCB and restores another. It is pure operating system overhead with zero user progress.';
      case 'waiting time':
        return 'Waiting time is the total duration a process spends in the ready queue awaiting CPU execution. Minimizing average waiting time is a primary goal of scheduling.';
      case 'turnaround time':
        return 'Turnaround time is the total elapsed time from process admission to completion, calculated as completion time minus arrival time.';
      case 'response time':
        return 'Response time measures the delay between process arrival and its very first CPU dispatch, critical for interactive systems and user interfaces.';
      case 'cpu utilization':
        return 'CPU utilization is the percentage of time the processor core executes user processes instead of remaining idle or in context-switch overhead.';
      case 'throughput':
        return 'Throughput represents the number of processes completed per unit time. High throughput indicates an efficient, non-blocking scheduler.';
      case 'process states':
        return 'The five-state process model transitions tasks through New, Ready, Running, Waiting, and Terminated, managed by short and long term schedulers.';
      case 'memory management':
        return 'Memory management partitions physical RAM between the operating system kernel and active processes, dynamically allocating and reclaiming memory blocks.';
      case 'process creation':
        return 'Process creation initializes a Process Control Block with a PID, allocating initial memory and placing the task in the ready queue.';
      case 'deadlock':
        return 'Deadlock occurs when multiple processes hold resources while waiting on each other in a circular chain, requiring Coffman conditions to hold.';
      case 'paging':
        return 'Paging divides virtual memory into fixed pages and physical memory into frames, eliminating external fragmentation using page tables.';
      case 'page replacement':
        return 'Page replacement algorithms like FIFO and LRU select which memory frame to evict to disk when a page fault occurs and RAM is full.';
      case 'disk scheduling':
        return 'Disk scheduling algorithms like FCFS, SSTF, and SCAN order I/O read-write requests to minimize mechanical seek time and latency.';
      default:
        return 'Operating system scheduling manages CPU allocation across competing processes to optimize throughput, latency, and fairness.';
    }
  }

  /// Speaks the academic explanation for an OS concept.
  Future<void> explainConcept(String topic) async {
    final explanation = getConceptExplanation(topic);
    await speak(explanation);
  }

  /// Feature B: Live Narration — queues a context-switch announcement.
  /// If TTS is busy, stores in [_pendingNarration] so the current word finishes first.
  Future<void> narrateContextSwitch({
    String? preemptedPid,
    required String runningPid,
    String? reason,
  }) async {
    if (_isMuted) return;
    await speak('Switched to $runningPid');
  }

  /// Short live narration for process termination.
  Future<void> narrateTermination(String completedPid) async {
    if (_isMuted) return;
    await speak('$completedPid done');
  }

  /// Live narration for dynamic arrival preemption.
  Future<void> narrateDynamicArrival(String pid, int priority) async {
    if (_isMuted) return;
    await speak('New: $pid');
  }

  void dispose() {
    stop();
  }
}
