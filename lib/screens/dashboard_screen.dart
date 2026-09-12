import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../providers/metrics_provider.dart';
import '../widgets/circular_chart_widget.dart';
import '../widgets/metric_card_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Non-Functional Requirement: pause sensor polling when in background to save battery
    final provider = Provider.of<MetricsProvider>(context, listen: false);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      provider.pauseAutoRefresh();
    } else if (state == AppLifecycleState.resumed) {
      provider.resumeAutoRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metricsProvider = Provider.of<MetricsProvider>(context);
    final metrics = metricsProvider.metrics;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.analytics_outlined, size: 22),
            const SizedBox(width: 8),
            Text(
              AppConstants.appName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: metricsProvider.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            tooltip: 'Refresh Metrics',
            onPressed: metricsProvider.isLoading ? null : () => metricsProvider.fetchMetrics(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => metricsProvider.fetchMetrics(),
        child: metrics == null && metricsProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                children: [
                  // Auto-refresh control banner
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.sync,
                              size: 18,
                              color: metricsProvider.isAutoRefreshEnabled
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Auto-refresh (every 3s)',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        Switch.adaptive(
                          value: metricsProvider.isAutoRefreshEnabled,
                          onChanged: (val) => metricsProvider.toggleAutoRefresh(val),
                        ),
                      ],
                    ),
                  ),

                  // 1. System Overview Card
                  MetricCardWidget(
                    title: 'System Overview',
                    icon: Icons.smartphone,
                    iconColor: theme.colorScheme.primary,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoItem(
                                context,
                                label: 'Device',
                                value: metrics != null
                                    ? '${metrics.manufacturer} ${metrics.deviceName}'
                                    : 'Loading...',
                              ),
                            ),
                            Expanded(
                              child: _buildInfoItem(
                                context,
                                label: 'Model',
                                value: metrics?.model ?? 'Loading...',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoItem(
                                context,
                                label: 'Android OS',
                                value: metrics != null ? 'Android ${metrics.androidVersion}' : 'Loading...',
                              ),
                            ),
                            Expanded(
                              child: _buildInfoItem(
                                context,
                                label: 'API Level',
                                value: metrics != null ? 'API ${metrics.apiLevel}' : 'Loading...',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // CPU Processor & Cores Card (Module 1)
                  MetricCardWidget(
                    title: 'CPU Processor & Cores',
                    icon: Icons.developer_board,
                    iconColor: const Color(0xFFD32F2F),
                    trailing: Text(
                      metrics != null ? '${metrics.cpuUsagePercent.toStringAsFixed(1)}% Usage' : '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFD32F2F),
                      ),
                    ),
                    child: metrics == null
                        ? const Center(child: CircularProgressIndicator())
                        : Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: CircularChartWidget(
                                  percent: (metrics.cpuUsagePercent / 100.0).clamp(0.0, 1.0),
                                  title: '${metrics.cpuUsagePercent.toStringAsFixed(0)}%',
                                  subtitle: 'Load',
                                  progressColor: metrics.cpuUsagePercent > 80
                                      ? Colors.red
                                      : metrics.cpuUsagePercent > 50
                                          ? Colors.orange
                                          : const Color(0xFFD32F2F),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildMetricRow(
                                      context,
                                      label: 'CPU Cores',
                                      value: '${metrics.cpuCores} Cores',
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildMetricRow(
                                      context,
                                      label: 'CPU Load',
                                      value: '${metrics.cpuUsagePercent.toStringAsFixed(1)}%',
                                      color: const Color(0xFFD32F2F),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildMetricRow(
                                      context,
                                      label: 'Interval',
                                      value: 'Every 3s',
                                      color: Colors.green,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),

                  // 2. Memory (RAM) Monitor Card
                  MetricCardWidget(
                    title: 'Memory (RAM) Monitor',
                    icon: Icons.memory,
                    iconColor: const Color(0xFF8E24AA),
                    trailing: metrics?.isLowMemory == true
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.withAlpha(30),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Low Memory Warning',
                              style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          )
                        : null,
                    child: metrics == null
                        ? const Center(child: CircularProgressIndicator())
                        : Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: CircularChartWidget(
                                  percent: metrics.ramUsageRatio,
                                  title: '${metrics.ramUsagePercent}%',
                                  subtitle: 'Used',
                                  progressColor: metrics.ramUsagePercent > 85
                                      ? Colors.red
                                      : metrics.ramUsagePercent > 70
                                          ? Colors.orange
                                          : const Color(0xFF8E24AA),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildMetricRow(
                                      context,
                                      label: 'Used RAM',
                                      value: '${metrics.usedRamGB.toStringAsFixed(1)} GB',
                                      color: const Color(0xFF8E24AA),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildMetricRow(
                                      context,
                                      label: 'Free RAM',
                                      value: '${metrics.availableRamGB.toStringAsFixed(1)} GB',
                                      color: Colors.green,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildMetricRow(
                                      context,
                                      label: 'Total RAM',
                                      value: '${metrics.totalRamGB.toStringAsFixed(1)} GB',
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),

                  // 3. Storage Monitor Card
                  MetricCardWidget(
                    title: 'Storage Monitor',
                    icon: Icons.storage,
                    iconColor: const Color(0xFF00897B),
                    trailing: Text(
                      metrics != null ? '${metrics.storageUsagePercent}% Used' : '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00897B),
                      ),
                    ),
                    child: metrics == null
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: metrics.storageUsageRatio,
                                  minHeight: 12,
                                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00897B)),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildStatColumn(
                                    context,
                                    label: 'Used',
                                    value: '${metrics.usedStorageGB.toStringAsFixed(1)} GB',
                                  ),
                                  _buildStatColumn(
                                    context,
                                    label: 'Free',
                                    value: '${metrics.freeStorageGB.toStringAsFixed(1)} GB',
                                  ),
                                  _buildStatColumn(
                                    context,
                                    label: 'Total',
                                    value: '${metrics.totalStorageGB.toStringAsFixed(1)} GB',
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),

                  // 4. Battery Monitor Card
                  MetricCardWidget(
                    title: 'Battery Monitor',
                    icon: Icons.battery_charging_full,
                    iconColor: const Color(0xFFFB8C00),
                    trailing: Text(
                      metrics != null ? '${metrics.batteryLevel}% (${metrics.batteryStatus})' : '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFB8C00),
                      ),
                    ),
                    child: metrics == null
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: metrics.batteryRatio,
                                  minHeight: 12,
                                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    metrics.batteryLevel <= 20
                                        ? Colors.red
                                        : const Color(0xFFFB8C00),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoItem(
                                      context,
                                      label: 'Status',
                                      value: metrics.batteryStatus,
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildInfoItem(
                                      context,
                                      label: 'Health',
                                      value: metrics.batteryHealth,
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildInfoItem(
                                      context,
                                      label: 'Temperature',
                                      value: '${metrics.batteryTemperature.toStringAsFixed(1)} °C',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),

                  // 5. Educational Sandboxing Notice Card
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: theme.colorScheme.primaryContainer.withAlpha(60),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: theme.colorScheme.primary.withAlpha(70),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme.colorScheme.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppConstants.sandboxRestrictionTitle,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppConstants.sandboxRestrictionMessage,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, {required String label, required String value}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricRow(BuildContext context,
      {required String label, required String value, required Color color}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumn(BuildContext context, {required String label, required String value}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
