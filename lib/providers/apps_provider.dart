import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/installed_app.dart';
import '../models/simulated_process.dart';
import '../services/app_list_service.dart';

class AppsProvider extends ChangeNotifier {
  final AppListService _service;
  List<InstalledApp> _apps = [];
  bool _isLoading = false;
  String _searchQuery = '';

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

  AppsProvider({AppListService? service}) : _service = service ?? AppListService() {
    fetchInstalledApps();
  }

  List<InstalledApp> get allApps => List.unmodifiable(_apps);
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  List<InstalledApp> get filteredApps {
    if (_searchQuery.trim().isEmpty) {
      return _apps;
    }
    final query = _searchQuery.toLowerCase().trim();
    return _apps.where((app) =>
        app.name.toLowerCase().contains(query) ||
        app.packageName.toLowerCase().contains(query)).toList();
  }

  int get selectedCount => _apps.where((app) => app.isSelected).length;

  List<InstalledApp> get selectedApps =>
      _apps.where((app) => app.isSelected).toList();

  Future<void> fetchInstalledApps() async {
    _isLoading = true;
    notifyListeners();
    try {
      _apps = await _service.getInstalledApplications();
      // By default ensure first 3 apps are pre-selected for quick demo
      if (_apps.where((a) => a.isSelected).isEmpty) {
        for (int i = 0; i < min(3, _apps.length); i++) {
          _apps[i].isSelected = true;
        }
      }
    } catch (e) {
      debugPrint('AppsProvider error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleAppSelection(InstalledApp app) {
    app.isSelected = !app.isSelected;
    notifyListeners();
  }

  void selectAll() {
    for (final app in _apps) {
      app.isSelected = true;
    }
    notifyListeners();
  }

  void deselectAll() {
    for (final app in _apps) {
      app.isSelected = false;
    }
    notifyListeners();
  }

  /// Converts selected apps into simulated OS processes with realistic scheduling metadata.
  List<SimulatedProcess> generateSimulatedProcesses() {
    final selected = selectedApps;
    final random = Random();
    final List<SimulatedProcess> processes = [];

    for (int i = 0; i < selected.length; i++) {
      final app = selected[i];
      final burst = random.nextInt(19) + 2; // 2 to 20 seconds
      final priority = random.nextInt(10) + 1; // 1 (highest) to 10 (lowest)
      final memoryMb = 120 + random.nextInt(680); // 120MB to 800MB
      final color = _processColors[i % _processColors.length];

      processes.add(SimulatedProcess(
        pid: 1000 + random.nextInt(8999),
        name: app.name,
        burstTime: burst,
        priority: priority,
        memoryMb: memoryMb,
        arrivalTime: 0,
        packageName: app.packageName,
        iconBytes: app.iconBytes,
        state: ProcessState.ready,
        color: color,
      ));
    }

    return processes;
  }
}
