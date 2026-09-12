import 'package:flutter/material.dart';
import '../providers/simulator_provider.dart';
import '../services/voice_tutor_service.dart';
import '../utils/professor_explanations.dart';

class ProfessorModeBottomSheet extends StatefulWidget {
  final SimulatorProvider provider;
  final VoiceTutorService voiceTutor;

  const ProfessorModeBottomSheet({
    super.key,
    required this.provider,
    required this.voiceTutor,
  });

  static void show(BuildContext context, SimulatorProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProfessorModeBottomSheet(
        provider: provider,
        voiceTutor: provider.voiceTutor,
      ),
    );
  }

  @override
  State<ProfessorModeBottomSheet> createState() => _ProfessorModeBottomSheetState();
}

class _ProfessorModeBottomSheetState extends State<ProfessorModeBottomSheet> {
  ExplanationItem? _activeExplanation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = widget.provider;

    // Collect explanations: Live audit items first + general items
    final List<ExplanationItem> items = [];

    if (provider.lastDecisionProcess != null && provider.lastDecisionReason != null) {
      items.add(ProfessorExplanations.explainWhyChosen(
        algorithm: provider.selectedAlgorithm.displayName,
        processName: provider.lastDecisionProcess!,
        reason: provider.lastDecisionReason!,
      ));
    }

    if (provider.lastPreemptedProcess != null && provider.lastPreemptionNewProcess != null) {
      items.add(ProfessorExplanations.explainWhyPreempted(
        algorithm: provider.selectedAlgorithm.displayName,
        preemptedProcess: provider.lastPreemptedProcess!,
        newProcess: provider.lastPreemptionNewProcess!,
        reason: provider.lastPreemptionReason ?? 'preemptive priority/burst check',
      ));
    }

    items.addAll(ProfessorExplanations.getGeneralExplanations());

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.school, color: theme.colorScheme.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Professor Mode — Viva Tutor',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Audio explanations & conceptual analysis',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Content body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_activeExplanation != null) ...[
                  _buildActiveExplanationCard(context, _activeExplanation!),
                  const SizedBox(height: 16),
                  Text(
                    'More Questions & Viva Topics:',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                ],
                ...items.map((item) => _buildQuestionTile(context, item)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionTile(BuildContext context, ExplanationItem item) {
    final theme = Theme.of(context);
    final isSelected = _activeExplanation?.title == item.title;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Icon(
          item.category.contains('Audit') ? Icons.bolt : Icons.help_outline,
          color: item.category.contains('Audit') ? Colors.amber.shade800 : theme.colorScheme.primary,
        ),
        title: Text(
          item.title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          item.category,
          style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
        ),
        trailing: Icon(
          Icons.volume_up_outlined,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        onTap: () {
          setState(() {
            _activeExplanation = item;
          });
          widget.voiceTutor.speak(item.speechText);
        },
      ),
    );
  }

  Widget _buildActiveExplanationCard(BuildContext context, ExplanationItem item) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.category.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.volume_up, size: 16),
                label: const Text('Speak Again', style: TextStyle(fontSize: 12)),
                onPressed: () {
                  widget.voiceTutor.speak(item.speechText);
                },
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.stop_circle_outlined, size: 22),
                tooltip: 'Stop Voice',
                onPressed: () => widget.voiceTutor.stop(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.speechText,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            item.detailedExplanation,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
