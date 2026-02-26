import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/audio_provider.dart';

class ScriptInput extends ConsumerWidget {
  const ScriptInput({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(audioFormStateProvider);
    final formNotifier = ref.read(audioFormStateProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Votre script marketing',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Collez ou écrivez le texte que vous souhaitez transformer en audio.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        const SizedBox(height: 24),

        // Title field
        TextFormField(
          initialValue: formState.title,
          decoration: const InputDecoration(
            labelText: 'Titre du projet (optionnel)',
            hintText: 'Ex: Spot radio printemps 2026',
            prefixIcon: Icon(Icons.title),
          ),
          onChanged: formNotifier.updateTitle,
        ),
        const SizedBox(height: 24),

        // Script textarea
        TextFormField(
          initialValue: formState.script,
          decoration: InputDecoration(
            labelText: 'Script',
            hintText: 'Entrez votre texte marketing ici...',
            alignLabelWithHint: true,
            helperText: '${formState.script.length} / ${AppConstants.maxScriptLength} caractères',
            helperStyle: TextStyle(
              color: formState.script.length > AppConstants.maxScriptLength
                  ? AppTheme.errorColor
                  : AppTheme.textMuted,
            ),
            errorText: formState.script.length > AppConstants.maxScriptLength
                ? 'Le script est trop long'
                : null,
          ),
          maxLines: 10,
          onChanged: formNotifier.updateScript,
        ),
        const SizedBox(height: 24),

        // Language selection
        Text(
          'Langue',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: AppConstants.supportedLanguages.map((lang) {
            final isSelected = formState.language == lang;
            return ChoiceChip(
              label: Text(
                '${_getFlagEmoji(lang)}  ${AppConstants.languageNames[lang] ?? lang}',
                style: const TextStyle(overflow: TextOverflow.visible),
                softWrap: false,
                maxLines: 1,
              ),
              selected: isSelected,
              onSelected: (_) => formNotifier.updateLanguage(lang),
              selectedColor: AppTheme.primaryColor.withValues(alpha: 0.15),
              checkmarkColor: AppTheme.primaryColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Duration selection
        Text(
          'Durée cible',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: AppConstants.durations.map((duration) {
            final isSelected = formState.targetDuration == duration;
            return ChoiceChip(
              label: Text(
                AppConstants.durationNames[duration] ?? '${duration}s',
                style: const TextStyle(overflow: TextOverflow.visible),
                softWrap: false,
                maxLines: 1,
              ),
              selected: isSelected,
              onSelected: (_) => formNotifier.updateDuration(duration),
              selectedColor: AppTheme.primaryColor.withValues(alpha: 0.15),
              checkmarkColor: AppTheme.primaryColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        // Tips card
        Card(
          color: AppTheme.infoColor.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: AppTheme.infoColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Conseils pour un bon script',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.infoColor,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• Soyez concis et direct\n'
                        '• Utilisez des phrases courtes\n'
                        '• Adaptez la longueur à la durée choisie',
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
}
