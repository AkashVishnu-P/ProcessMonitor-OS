import 'package:flutter/material.dart';

class GanttRecord {
  final String pid;
  final int startTick;
  int endTick;
  final Color color;
  final bool isContextSwitch;
  final String stateLabel;

  GanttRecord({
    required this.pid,
    required this.startTick,
    required this.endTick,
    required this.color,
    this.isContextSwitch = false,
    this.stateLabel = 'Running',
  });

  int get duration => endTick - startTick;

  GanttRecord copyWith({
    String? pid,
    int? startTick,
    int? endTick,
    Color? color,
    bool? isContextSwitch,
    String? stateLabel,
  }) {
    return GanttRecord(
      pid: pid ?? this.pid,
      startTick: startTick ?? this.startTick,
      endTick: endTick ?? this.endTick,
      color: color ?? this.color,
      isContextSwitch: isContextSwitch ?? this.isContextSwitch,
      stateLabel: stateLabel ?? this.stateLabel,
    );
  }
}
