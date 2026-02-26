import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/audio_provider.dart';

class MusicOptions extends ConsumerWidget {
  const MusicOptions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(audioFormStateProvider);
    final formNotifier = ref.read(audioFormStateProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Musique de fond',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choisissez l\'ambiance musicale de votre spot.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        const SizedBox(height: 32),

        // Music style grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemCount: AppConstants.musicStyles.length,
          itemBuilder: (context, index) {
            final style = AppConstants.musicStyles[index];
            final isSelected = formState.musicStyle == style;

            return _MusicStyleCard(
              style: style,
              isSelected: isSelected,
              onTap: () => formNotifier.updateMusicStyle(style),
            );
          },
        ),
        const SizedBox(height: 32),

        // License info card
        Card(
          color: AppTheme.successColor.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.verified, color: AppTheme.successColor),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Musique libre de droits',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.successColor,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Toutes les musiques sont licenciées pour un usage marketing et publicitaire.',
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
        const SizedBox(height: 16),

        // Technical info
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Traitement audio automatique',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                _buildTechFeature(context, Icons.volume_up, 'Équilibrage voix / musique intelligent'),
                const SizedBox(height: 8),
                _buildTechFeature(context, Icons.graphic_eq, 'Compression légère pour clarté'),
                const SizedBox(height: 8),
                _buildTechFeature(context, Icons.tune, 'Normalisation loudness (web & réseaux)'),
                const SizedBox(height: 8),
                _buildTechFeature(context, Icons.check_circle_outline, 'Prêt à diffusion'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTechFeature(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _MusicStyleCard extends StatelessWidget {
  final String style;
  final bool isSelected;
  final VoidCallback onTap;

  const _MusicStyleCard({
    required this.style,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? _getStyleColor().withValues(alpha: 0.1) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? _getStyleColor() : AppTheme.borderColor,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getStyleColor(),
                      _getStyleColor().withValues(alpha: 0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getStyleIcon(),
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppConstants.musicStyleNames[style] ?? style,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? _getStyleColor() : null,
                    ),
              ),
              Text(
                _getStyleDescription(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textMuted,
                    ),
                textAlign: TextAlign.center,
              ),
              if (isSelected) ...[
                const SizedBox(height: 8),
                Icon(
                  Icons.check_circle,
                  color: _getStyleColor(),
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStyleIcon() {
    switch (style) {
      case 'corporate':
        return Icons.business_center;
      case 'modern':
        return Icons.trending_up;
      case 'calm':
        return Icons.spa;
      case 'energetic':
        return Icons.flash_on;
      default:
        return Icons.music_note;
    }
  }

  Color _getStyleColor() {
    switch (style) {
      case 'corporate':
        return const Color(0xFF3B82F6); // Blue
      case 'modern':
        return const Color(0xFF8B5CF6); // Purple
      case 'calm':
        return const Color(0xFF10B981); // Green
      case 'energetic':
        return const Color(0xFFF59E0B); // Orange
      default:
        return AppTheme.primaryColor;
    }
  }

  String _getStyleDescription() {
    switch (style) {
      case 'corporate':
        return 'Professionnel & sérieux';
      case 'modern':
        return 'Contemporain & tendance';
      case 'calm':
        return 'Relaxant & apaisant';
      case 'energetic':
        return 'Dynamique & motivant';
      default:
        return '';
    }
  }
}
