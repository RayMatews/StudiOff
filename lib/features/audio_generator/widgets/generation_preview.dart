import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/audio_project.dart';

class GenerationPreview extends StatelessWidget {
  final AudioGenerationRequest formState;

  const GenerationPreview({
    super.key,
    required this.formState,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Récapitulatif',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),

          // Summary card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryRow(
                    context,
                    icon: Icons.language,
                    label: 'Langue',
                    value: '${_getFlagEmoji(formState.language)} ${AppConstants.languageNames[formState.language]}',
                  ),
                  const Divider(height: 24),
                  _buildSummaryRow(
                    context,
                    icon: Icons.timer,
                    label: 'Durée',
                    value: AppConstants.durationNames[formState.targetDuration] ?? '${formState.targetDuration}s',
                  ),
                  const Divider(height: 24),
                  _buildSummaryRow(
                    context,
                    icon: Icons.person,
                    label: 'Voix',
                    value: AppConstants.voiceGenderNames[formState.voiceGender] ?? formState.voiceGender,
                  ),
                  const Divider(height: 24),
                  _buildSummaryRow(
                    context,
                    icon: Icons.sentiment_satisfied,
                    label: 'Ton',
                    value: AppConstants.toneNames[formState.tone] ?? formState.tone,
                  ),
                  const Divider(height: 24),
                  _buildSummaryRow(
                    context,
                    icon: Icons.music_note,
                    label: 'Musique',
                    value: AppConstants.musicStyleNames[formState.musicStyle] ?? formState.musicStyle,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Script preview
          Text(
            'Aperçu du script',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Card(
            color: AppTheme.backgroundColor,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (formState.script.isEmpty)
                    Text(
                      'Votre script apparaîtra ici...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textMuted,
                            fontStyle: FontStyle.italic,
                          ),
                    )
                  else
                    Text(
                      formState.script.length > 300
                          ? '${formState.script.substring(0, 300)}...'
                          : formState.script,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.6,
                          ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.text_fields,
                        size: 16,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${formState.script.length} caractères',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textMuted,
                            ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '~${_estimateDuration(formState.script)} sec estimé',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textMuted,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Output info
          Text(
            'Format de sortie',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildOutputChip(context, Icons.audio_file, 'MP3 (Web)'),
              _buildOutputChip(context, Icons.high_quality, 'WAV (HQ)'),
            ],
          ),
          const SizedBox(height: 24),

          // Cost estimation
          Card(
            color: AppTheme.primaryColor.withValues(alpha: 0.05),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.toll, color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Coût estimé',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          '~${(formState.targetDuration / 60).toStringAsFixed(1)} minute(s) de crédit',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
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
    );
  }

  Widget _buildSummaryRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppTheme.primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textMuted,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOutputChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.successColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.successColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.successColor,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  String _getFlagEmoji(String lang) {
    switch (lang) {
      case 'fr':
        return '🇫🇷';
      case 'en':
        return '🇬🇧';
      default:
        return '🌐';
    }
  }

  int _estimateDuration(String text) {
    // Average speaking rate: ~150 words per minute, or ~2.5 words per second
    // Average word length: 5 characters
    final wordCount = text.split(RegExp(r'\s+')).length;
    return (wordCount / 2.5).round();
  }
}
