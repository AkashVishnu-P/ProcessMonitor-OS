import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/installed_app.dart';
import '../providers/apps_provider.dart';
import '../providers/simulator_provider.dart';

class AppsScreen extends StatefulWidget {
  final VoidCallback onSimulationGenerated;

  const AppsScreen({
    super.key,
    required this.onSimulationGenerated,
  });

  @override
  State<AppsScreen> createState() => _AppsScreenState();
}

class _AppsScreenState extends State<AppsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appsProvider = Provider.of<AppsProvider>(context);
    final apps = appsProvider.filteredApps;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Installed Applications', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload Applications',
            onPressed: appsProvider.isLoading ? null : () => appsProvider.fetchInstalledApps(),
          ),
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'select_all') {
                appsProvider.selectAll();
              } else if (val == 'deselect_all') {
                appsProvider.deselectAll();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'select_all', child: Text('Select All')),
              PopupMenuItem(value: 'deselect_all', child: Text('Deselect All')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search applications by name or package...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          appsProvider.setSearchQuery('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onChanged: (val) => appsProvider.setSearchQuery(val),
            ),
          ),

          // Educational Notice Banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Select real device apps to convert into educational OS simulation processes.',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11.5),
                  ),
                ),
              ],
            ),
          ),

          // Apps List
          Expanded(
            child: appsProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : apps.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.apps_outlined, size: 48, color: theme.colorScheme.outline),
                            const SizedBox(height: 8),
                            Text('No matching applications found', style: theme.textTheme.bodyMedium),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: apps.length,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        itemBuilder: (context, index) {
                          final app = apps[index];
                          return Card(
                            elevation: 0,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: app.isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                                width: app.isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: CheckboxListTile(
                              value: app.isSelected,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              secondary: _buildAppIcon(app, theme),
                              title: Text(
                                app.name,
                                style: TextStyle(
                                  fontWeight: app.isSelected ? FontWeight.bold : FontWeight.w600,
                                  fontSize: 14.5,
                                ),
                              ),
                              subtitle: Text(
                                app.packageName,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onChanged: (_) => appsProvider.toggleAppSelection(app),
                            ),
                          );
                        },
                      ),
          ),

          // Bottom Action Bar: Selected Apps: X & Generate Simulation Button
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    offset: const Offset(0, -2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Selected Apps : ${appsProvider.selectedCount}',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Ready for scheduling lab',
                        style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Generate Simulation'),
                    onPressed: appsProvider.selectedCount == 0
                        ? null
                        : () => _handleGenerateSimulation(context, appsProvider),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppIcon(InstalledApp app, ThemeData theme) {
    if (app.iconBytes != null && app.iconBytes!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          app.iconBytes!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(app, theme),
        ),
      );
    }
    return _buildFallbackIcon(app, theme);
  }

  Widget _buildFallbackIcon(InstalledApp app, ThemeData theme) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          app.name.isNotEmpty ? app.name[0].toUpperCase() : 'A',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  void _handleGenerateSimulation(BuildContext context, AppsProvider appsProvider) {
    final processes = appsProvider.generateSimulatedProcesses();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.hub_outlined, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Generated Processes'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade700.withValues(alpha: 0.4)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 18, color: Colors.amber.shade900),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Scheduling parameters are simulated because Android does not expose process burst times or scheduling priorities.',
                        style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${processes.length} Processes Generated:',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: processes.length,
                  itemBuilder: (_, i) {
                    final p = processes[i];
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: p.color,
                        child: Text(
                          '${p.pid % 100}',
                          style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text(
                        'PID: ${p.pid} | Burst: ${p.burstTime}s | Priority: ${p.priority} | RAM: ${p.memoryMb} MB | State: Ready',
                        style: const TextStyle(fontSize: 11),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.play_circle_fill),
            label: const Text('Load into OS Simulator'),
            onPressed: () {
              Navigator.of(ctx).pop();
              final simProvider = Provider.of<SimulatorProvider>(context, listen: false);
              simProvider.loadCustomProcesses(processes);
              widget.onSimulationGenerated();
            },
          ),
        ],
      ),
    );
  }
}
