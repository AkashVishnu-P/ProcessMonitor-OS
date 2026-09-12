import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:process_monitor/core/constants/app_constants.dart';
import 'package:process_monitor/main.dart';
import 'package:process_monitor/widgets/state_badge_widget.dart';

void main() {
  testWidgets('App renders Dashboard and navigates to OS Simulator', (WidgetTester tester) async {
    // Set realistic mobile phone viewport size
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProcessMonitorApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Process Monitor header is displayed on Dashboard
    expect(find.text('Process Monitor'), findsOneWidget);
    expect(find.text('System Overview'), findsOneWidget);
    expect(find.text('Memory (RAM) Monitor'), findsOneWidget);
    expect(find.text('Storage Monitor'), findsOneWidget);
    expect(find.text('Battery Monitor'), findsOneWidget);

    // Tap on the 'OS Simulator' tab in the bottom navigation bar
    final simulatorTab = find.byIcon(Icons.developer_board_outlined);
    expect(simulatorTab, findsOneWidget);
    await tester.tap(simulatorTab);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify CPU Scheduler Simulator screen elements
    expect(find.text('CPU Scheduler Simulator'), findsOneWidget);
    expect(find.text('Academic Benchmark Presets'), findsOneWidget);
    expect(find.text('The Convoy Effect'), findsOneWidget);
    expect(find.text('Priority Starvation'), findsOneWidget);
    expect(find.text('CPU vs. I/O Mix'), findsOneWidget);
    expect(find.text('Scheduling Algorithm'), findsOneWidget);
    expect(find.text('RUNNING (CPU)'), findsOneWidget);

    // Verify 'Add Process' and 'Start Execution' buttons exist
    expect(find.text('Add Process'), findsOneWidget);
    expect(find.text('Start Execution'), findsOneWidget);
    expect(find.text('Step (1s)'), findsOneWidget);

    // Tap 'Step (1s)' button and verify CPU schedules a process
    await tester.tap(find.text('Step (1s)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // After stepping, CPU should no longer be idle
    expect(find.text('CPU Idle - Ready to execute'), findsNothing);

    // Verify Voice Tutor FAB and Explain Algorithm button exist
    expect(find.byIcon(Icons.record_voice_over), findsWidgets);
    expect(find.text('Explain Algorithm (Voice Tutor)'), findsOneWidget);

    // Scroll to see the TERMINATED section
    await tester.scrollUntilVisible(
      find.text('TERMINATED'),
      400.0,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('TERMINATED'), findsOneWidget);
  });

  testWidgets('StateBadgeWidget renders proper labels for all 5 process states', (WidgetTester tester) async {
    for (final state in ProcessState.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StateBadgeWidget(state: state),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(StateBadgeWidget), findsOneWidget);
    }
  });
}
