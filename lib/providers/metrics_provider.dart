import 'dart:async';
import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/device_metrics.dart';
import '../services/hardware_service.dart';

class MetricsProvider extends ChangeNotifier {
  final HardwareService _hardwareService;

  DeviceMetrics? _metrics;
  bool _isLoading = false;
  bool _isAutoRefreshEnabled = true;
  Timer? _autoRefreshTimer;
  String? _errorMessage;

  MetricsProvider({HardwareService? hardwareService})
      : _hardwareService = hardwareService ?? HardwareService() {
    fetchMetrics();
    _startAutoRefreshTimer();
  }

  DeviceMetrics? get metrics => _metrics;
  bool get isLoading => _isLoading;
  bool get isAutoRefreshEnabled => _isAutoRefreshEnabled;
  String? get errorMessage => _errorMessage;

  Future<void> fetchMetrics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _metrics = await _hardwareService.fetchDeviceMetrics();
    } catch (e) {
      _errorMessage = 'Failed to load device metrics: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleAutoRefresh(bool enabled) {
    if (_isAutoRefreshEnabled == enabled) return;
    _isAutoRefreshEnabled = enabled;
    if (_isAutoRefreshEnabled) {
      _startAutoRefreshTimer();
    } else {
      _stopAutoRefreshTimer();
    }
    notifyListeners();
  }

  void pauseAutoRefresh() {
    _stopAutoRefreshTimer();
  }

  void resumeAutoRefresh() {
    if (_isAutoRefreshEnabled) {
      _startAutoRefreshTimer();
    }
  }

  void _startAutoRefreshTimer() {
    _stopAutoRefreshTimer();
    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: AppConstants.autoRefreshIntervalSeconds),
      (_) => fetchMetrics(),
    );
  }

  void _stopAutoRefreshTimer() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  @override
  void dispose() {
    _stopAutoRefreshTimer();
    super.dispose();
  }
}
