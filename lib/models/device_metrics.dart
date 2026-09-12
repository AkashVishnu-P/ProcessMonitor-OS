class DeviceMetrics {
  // System Info
  final String deviceName;
  final String manufacturer;
  final String model;
  final String androidVersion;
  final int apiLevel;

  // RAM Metrics (in bytes and gigabytes)
  final int totalRamBytes;
  final int availableRamBytes;
  final bool isLowMemory;
  final int memoryThresholdBytes;

  // Storage Metrics (in bytes and gigabytes)
  final int totalStorageBytes;
  final int freeStorageBytes;

  // Battery Metrics
  final int batteryLevel; // 0 - 100
  final String batteryStatus; // Charging, Discharging, Full, etc.
  final double batteryTemperature; // in °C
  final String batteryHealth; // Good, Overheat, etc.
  final int batteryVoltage; // in mV

  // CPU Metrics
  final double cpuUsagePercent; // 0.0 - 100.0%
  final int cpuCores;

  // Timestamp of capture
  final DateTime timestamp;

  const DeviceMetrics({
    required this.deviceName,
    required this.manufacturer,
    required this.model,
    required this.androidVersion,
    required this.apiLevel,
    required this.totalRamBytes,
    required this.availableRamBytes,
    required this.isLowMemory,
    required this.memoryThresholdBytes,
    required this.totalStorageBytes,
    required this.freeStorageBytes,
    required this.batteryLevel,
    required this.batteryStatus,
    required this.batteryTemperature,
    required this.batteryHealth,
    required this.batteryVoltage,
    this.cpuUsagePercent = 24.5,
    this.cpuCores = 8,
    required this.timestamp,
  });

  // RAM helper getters
  double get totalRamGB => totalRamBytes / (1024 * 1024 * 1024);
  double get availableRamGB => availableRamBytes / (1024 * 1024 * 1024);
  double get usedRamGB => totalRamGB - availableRamGB;
  double get ramUsageRatio =>
      totalRamBytes > 0 ? (totalRamBytes - availableRamBytes) / totalRamBytes : 0.0;
  int get ramUsagePercent => (ramUsageRatio * 100).round();

  // Storage helper getters
  double get totalStorageGB => totalStorageBytes / (1024 * 1024 * 1024);
  double get freeStorageGB => freeStorageBytes / (1024 * 1024 * 1024);
  double get usedStorageGB => totalStorageGB - freeStorageGB;
  double get storageUsageRatio =>
      totalStorageBytes > 0 ? (totalStorageBytes - freeStorageBytes) / totalStorageBytes : 0.0;
  int get storageUsagePercent => (storageUsageRatio * 100).round();

  // Battery ratio
  double get batteryRatio => batteryLevel.clamp(0, 100) / 100.0;

  factory DeviceMetrics.mock() {
    const totalRam = 8 * 1024 * 1024 * 1024;
    const availRam = 3865470566; // ~3.6 GB free, 4.4 GB used
    const totalStorage = 256 * 1024 * 1024 * 1024;
    const freeStorage = 136365211648; // ~127 GB free

    return DeviceMetrics(
      deviceName: 'Pixel 8 Pro',
      manufacturer: 'Google',
      model: 'GC3VE',
      androidVersion: '14',
      apiLevel: 34,
      totalRamBytes: totalRam,
      availableRamBytes: availRam,
      isLowMemory: false,
      memoryThresholdBytes: 500 * 1024 * 1024,
      totalStorageBytes: totalStorage,
      freeStorageBytes: freeStorage,
      batteryLevel: 87,
      batteryStatus: 'Charging',
      batteryTemperature: 31.4,
      batteryHealth: 'Good',
      batteryVoltage: 4120,
      cpuUsagePercent: 28.5,
      cpuCores: 8,
      timestamp: DateTime.now(),
    );
  }
}
