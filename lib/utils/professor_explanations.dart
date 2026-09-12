class ExplanationItem {
  final String title;
  final String speechText;
  final String detailedExplanation;
  final String category;

  const ExplanationItem({
    required this.title,
    required this.speechText,
    required this.detailedExplanation,
    required this.category,
  });
}

class ProfessorExplanations {
  static List<ExplanationItem> getGeneralExplanations() {
    return const [
      ExplanationItem(
        title: 'Why is Round Robin fair?',
        category: 'Scheduling Principles',
        speechText:
            'Round Robin is fair because every ready process receives an equal time slice called a quantum. No single compute-heavy task can monopolize the CPU, ensuring starvation-free execution.',
        detailedExplanation:
            'Round Robin (RR) guarantees responsiveness by cycling the CPU through all ready processes using hardware timer interrupts. '
            'Every process is guaranteed a time slice of size Q. If burst time exceeds Q, it is preempted to the rear of the ready queue. '
            'This guarantees an upper bound on waiting time: no process waits more than (n - 1) × Q time units before getting CPU time.',
      ),
      ExplanationItem(
        title: 'Explain Context Switching',
        category: 'CPU Overhead',
        speechText:
            'A context switch occurs when the CPU stops executing one process and saves its state, restoring the state of another. This incurs pure operating system overhead with zero user progress.',
        detailedExplanation:
            'When a context switch occurs, the kernel performs:\n'
            '1. Saves the active process registers, program counter (PC), and stack pointer into its PCB (Process Control Block).\n'
            '2. Flushes CPU caches and invalidates the Translation Lookaside Buffer (TLB).\n'
            '3. Loads the registers and memory mapping of the newly scheduled process.\n'
            'Because the CPU performs zero user work during this time, context switching duration is pure overhead penalty.',
      ),
      ExplanationItem(
        title: 'Explain Starvation and Aging',
        category: 'Fairness & Deadlock',
        speechText:
            'Starvation happens when low-priority or long burst jobs wait indefinitely because higher priority jobs keep arriving. Aging solves this by gradually increasing a waiting task priority over time.',
        detailedExplanation:
            'In Shortest Job First (SJF), Shortest Remaining Time First (SRTF), and Priority-Based Scheduling (PBS), a stream of short or high-priority processes can lock out lower-priority jobs forever (Indefinite Blocking / Starvation).\n\n'
            'The academic solution is "Aging": dynamically incrementing the priority of processes as they remain in the ready queue until they inevitably acquire the CPU.',
      ),
      ExplanationItem(
        title: 'Waiting Time vs Turnaround Time',
        category: 'Metrics & Equations',
        speechText:
            'Turnaround time is the total duration from process submission to completion. Waiting time is only the duration spent waiting in the ready queue without CPU execution.',
        detailedExplanation:
            'Silberschatz OS Equations:\n'
            '• Turnaround Time (TAT) = Completion Time - Arrival Time\n'
            '• Waiting Time (WT) = Turnaround Time - Burst Time\n'
            '• Average WT = (Σ Waiting Time) / Total Processes\n\n'
            'Minimizing average waiting time is the primary optimization metric of batch CPU scheduling.',
      ),
      ExplanationItem(
        title: 'Response Time, CPU Utilization & Throughput',
        category: 'Performance Metrics',
        speechText:
            'Response time measures the delay until first CPU dispatch. CPU utilization is the percentage of time the core executes tasks. Throughput is the number of processes completed per unit time.',
        detailedExplanation:
            'Key Performance Formulas:\n'
            '• Response Time (RT) = First CPU Start Time - Arrival Time (critical for interactive UIs).\n'
            '• CPU Utilization (%) = ((Total Ticks - Idle Ticks) / Total Ticks) × 100% (target: 40% - 90%).\n'
            '• Throughput = Total Completed Processes / Total Simulation Seconds.',
      ),
      ExplanationItem(
        title: 'The 5-State Process Lifecycle',
        category: 'Process Management',
        speechText:
            'Processes transition through New, Ready, Running, Waiting, and Terminated. The CPU dispatcher moves tasks between Ready and Running, while I/O operations move tasks to Waiting.',
        detailedExplanation:
            '1. New: Process Control Block (PCB) is created in secondary storage.\n'
            '2. Ready: Admitted into main memory by Long-Term Scheduler.\n'
            '3. Running: Instructions executed on CPU core by Short-Term Scheduler.\n'
            '4. Waiting: Blocked on I/O device or event wait.\n'
            '5. Terminated: Process completes, calls exit() system call, and kernel reclaims resources.',
      ),
      ExplanationItem(
        title: 'Memory Management & Allocation',
        category: 'Memory Management',
        speechText:
            'Memory management allocates RAM between the operating system kernel and active user processes. When processes terminate, their allocated partitions are freed back to available memory.',
        detailedExplanation:
            'The Operating System manages physical RAM partitions:\n'
            '• Kernel Space: Fixed, protected memory reservation for OS kernel routines and interrupt handlers.\n'
            '• User Space: Dynamic partitions allocated to active processes in Ready, Running, or Waiting states.\n'
            '• Free Memory: Available RAM pool dynamically reallocated as processes spawn and terminate.',
      ),
      ExplanationItem(
        title: 'Deadlock & Prevention',
        category: 'Synchronization',
        speechText:
            'Deadlock occurs when multiple processes are blocked, each holding a resource and waiting for another held resource. Coffman conditions must hold for deadlock to happen.',
        detailedExplanation:
            'Coffman Conditions for Deadlock:\n'
            '1. Mutual Exclusion: Resources are non-shareable.\n'
            '2. Hold and Wait: A process holds resources while requesting new ones.\n'
            '3. No Preemption: Resources cannot be forcibly seized.\n'
            '4. Circular Wait: A closed chain of processes waiting on each other.\n'
            'Deadlock prevention requires invalidating at least one of these four conditions (e.g. Banker\'s Algorithm).',
      ),
      ExplanationItem(
        title: 'Paging and Page Replacement',
        category: 'Virtual Memory',
        speechText:
            'Paging divides virtual memory into fixed pages and physical RAM into frames. Page replacement algorithms like FIFO, LRU, and Optimal handle page faults when memory is full.',
        detailedExplanation:
            'Virtual Memory concepts:\n'
            '• Page: Fixed-size block of virtual address space.\n'
            '• Frame: Fixed-size block of physical RAM.\n'
            '• Page Fault: Hardware interrupt triggered when a requested page is not in physical RAM.\n'
            '• Page Replacement Algorithms: FIFO (First In First Out), LRU (Least Recently Used), and Belady\'s Anomaly.',
      ),
    ];
  }

  static ExplanationItem explainWhyChosen({
    required String algorithm,
    required String processName,
    required String reason,
  }) {
    return ExplanationItem(
      title: 'Why did $algorithm choose $processName?',
      category: 'Live Decision Audit',
      speechText:
          'Under $algorithm, the dispatcher selected $processName because it met the optimal criterion: $reason.',
      detailedExplanation:
          'Live Scheduling Decision Analysis:\n\n'
          '• Algorithm: $algorithm\n'
          '• Selected Process: $processName\n'
          '• Selection Rationale: $reason\n\n'
          'The scheduler examined the Ready Queue and applied its selection policy deterministically. All other ready jobs had lower priority or longer execution requirements.',
    );
  }

  static ExplanationItem explainWhyPreempted({
    required String algorithm,
    required String preemptedProcess,
    required String newProcess,
    required String reason,
  }) {
    return ExplanationItem(
      title: 'Why was $preemptedProcess preempted by $newProcess?',
      category: 'Live Preemption Audit',
      speechText:
          'Under $algorithm, process $preemptedProcess was preempted because $newProcess arrived with $reason, or the time quantum expired.',
      detailedExplanation:
          'Preemption Event Log:\n\n'
          '• Preempted Task: $preemptedProcess (moved from Running -> Ready)\n'
          '• Dispatched Task: $newProcess (moved from Ready -> Running)\n'
          '• Trigger: $reason\n\n'
          'In preemptive schedulers, the CPU yields execution to maintain responsiveness or serve urgent real-time deadlines.',
    );
  }
}
