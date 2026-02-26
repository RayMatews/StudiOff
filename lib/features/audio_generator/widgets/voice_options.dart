import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/audio_provider.dart';

class VoiceOptions extends ConsumerWidget {
  const VoiceOptions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(audioFormStateProvider);
    final formNotifier = ref.read(audioFormStateProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Options de voix',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Personnalisez la voix qui lira votre script.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        const SizedBox(height: 32),

        // Gender selection
        Text(
          'Genre de la voix',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: AppConstants.voiceGenders.map((gender) {
            final isSelected = formState.voiceGender == gender;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: gender == 'male' ? 8 : 0,
                  left: gender == 'female' ? 8 : 0,
                ),
                child: _VoiceGenderCard(
                  gender: gender,
                  isSelected: isSelected,
                  onTap: () => formNotifier.updateVoiceGender(gender),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),

        // Tone selection
        Text(
          'Ton de la voix',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Le ton influence le rythme et l\'émotion de la voix.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textMuted,
              ),
        ),
        const SizedBox(height: 16),
        Column(
          children: AppConstants.tones.map((tone) {
            final isSelected = formState.tone == tone;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ToneOptionCard(
                tone: tone,
                isSelected: isSelected,
                onTap: () => formNotifier.updateTone(tone),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Voice preview hint
        Card(
          color: AppTheme.primaryColor.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.play_circle_outline, color: AppTheme.primaryColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aperçu audio',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Un aperçu sera disponible dans le panneau de droite une fois l\'audio généré.',
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
}

class _VoiceGenderCard extends StatelessWidget {
  final String gender;
  final bool isSelected;
  final VoidCallback onTap;

  const _VoiceGenderCard({
    required this.gender,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                gender == 'male' ? Icons.man : Icons.woman,
                size: 48,
                color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
              ),
              const SizedBox(height: 12),
              Text(
                AppConstants.voiceGenderNames[gender] ?? gender,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppTheme.primaryColor : null,
                    ),
              ),
              if (isSelected) ...[
                const SizedBox(height: 8),
                Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ToneOptionCard extends StatelessWidget {
  final String tone;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToneOptionCard({
    required this.tone,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor.withValues(alpha: 0.2)
                      : AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getToneIcon(),
                  color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.toneNames[tone] ?? tone,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? AppTheme.primaryColor : null,
                          ),
                    ),
                    Text(
                      _getToneDescription(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getToneIcon() {
    switch (tone) {
      case 'neutral':
        return Icons.balance;
      case 'dynamic':
        return Icons.bolt;
      case 'institutional':
        return Icons.business;
      default:
        return Icons.mic;
    }
  }

  String _getToneDescription() {
    switch (tone) {
      case 'neutral':
        return 'Voix posée et professionnelle';
      case 'dynamic':
        return 'Voix énergique et engageante';
      case 'institutional':
        return 'Voix formelle et autoritaire';
      default:
        return '';
    }
  }
}
