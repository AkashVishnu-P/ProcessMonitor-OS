import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/apps_provider.dart';
import 'providers/metrics_provider.dart';
import 'providers/simulator_provider.dart';
import 'screens/apps_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/simulator_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProcessMonitorApp());
}

class ProcessMonitorApp extends StatelessWidget {
  const ProcessMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MetricsProvider>(
          create: (_) => MetricsProvider(),
        ),
        ChangeNotifierProvider<AppsProvider>(
          create: (_) => AppsProvider(),
        ),
        ChangeNotifierProvider<SimulatorProvider>(
          create: (_) => SimulatorProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Process Monitor',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const MainNavigationScreen(),
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const DashboardScreen(),
      AppsScreen(
        onSimulationGenerated: () {
          setState(() {
            _currentIndex = 2; // Auto-navigate to OS Simulator Lab
          });
        },
      ),
      const SimulatorScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.apps_outlined),
            selectedIcon: Icon(Icons.apps),
            label: 'Installed Apps',
          ),
          NavigationDestination(
            icon: Icon(Icons.developer_board_outlined),
            selectedIcon: Icon(Icons.developer_board),
            label: 'OS Simulator',
          ),
        ],
      ),
    );
  }
}

