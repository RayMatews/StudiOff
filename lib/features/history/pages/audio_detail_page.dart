import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/audio_project.dart';
import '../../../providers/audio_provider.dart';
import '../../shared/widgets/audio_player_widget.dart';

class AudioDetailPage extends ConsumerStatefulWidget {
  final String projectId;

  const AudioDetailPage({super.key, required this.projectId});

  @override
  ConsumerState<AudioDetailPage> createState() => _AudioDetailPageState();
}

class _AudioDetailPageState extends ConsumerState<AudioDetailPage> {
  bool _isDownloading = false;
  bool _isRetrying = false;
  bool _isDuplicating = false;

  Future<void> _downloadAudio(AudioProject project, {bool wav = false}) async {
    // En mode démo, simuler le téléchargement
    if (AppConfig.demoMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Mode démo: Le téléchargement ${wav ? 'WAV' : 'MP3'} serait lancé ici',
          ),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      return;
    }

    setState(() => _isDownloading = true);

    try {
      final audioService = ref.read(audioServiceProvider);
      final url = await audioService.getDownloadUrl(project.id, wav: wav);

      // Créer un lien de téléchargement et le déclencher
      final fileName =
          '${project.title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.${wav ? 'wav' : 'mp3'}';
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..style.display = 'none';
      html.document.body?.children.add(anchor);
      anchor.click();
      anchor.remove();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Téléchargement ${wav ? 'WAV' : 'MP3'} lancé'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Future<void> _duplicateProject(AudioProject project) async {
    setState(() => _isDuplicating = true);

    try {
      final newProject = await ref
          .read(audioProjectsProvider.notifier)
          .duplicateProject(project);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Projet dupliqué avec succès !'),
            backgroundColor: AppTheme.successColor,
            action: SnackBarAction(
              label: 'Voir',
              textColor: Colors.white,
              onPressed: () => context.push('/audio/${newProject.id}'),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDuplicating = false);
      }
    }
  }

  Future<void> _retryGeneration(String projectId) async {
    setState(() => _isRetrying = true);

    try {
      await ref.read(audioProjectsProvider.notifier).retryGeneration(projectId);

      // Rafraîchir la page
      ref.invalidate(audioProjectProvider(projectId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Génération relancée !'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRetrying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectAsync = ref.watch(audioProjectProvider(widget.projectId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Détail de l\'audio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.invalidate(audioProjectProvider(widget.projectId)),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: projectAsync.when(
        data: (project) => _buildContent(context, project),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
              const SizedBox(height: 16),
              Text('Erreur: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(audioProjectProvider(widget.projectId)),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AudioProject project) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.title,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Créé le ${_formatDate(project.createdAt)}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(context, project.status),
                ],
              ),
              const SizedBox(height: 32),

              // Audio Player (if completed)
              if (project.status == AudioProjectStatus.completed) ...[
                AudioPlayerWidget(
                  audioUrl: project.outputFileUrl,
                  title: project.title,
                  showWaveform: true,
                ),
                const SizedBox(height: 24),

                // Download buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isDownloading
                            ? null
                            : () => _downloadAudio(project, wav: false),
                        icon: const Icon(Icons.download),
                        label: const Text('Télécharger MP3'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isDownloading
                            ? null
                            : () => _downloadAudio(project, wav: true),
                        icon: const Icon(Icons.high_quality),
                        label: const Text('Télécharger WAV'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],

              // Processing state
              if (project.status == AudioProjectStatus.processing) ...[
                _buildProcessingCard(context),
                const SizedBox(height: 32),
              ],

              // Error state
              if (project.status == AudioProjectStatus.failed) ...[
                _buildErrorCard(context, project.errorMessage),
                const SizedBox(height: 32),
              ],

              // Project details
              Text(
                'Détails du projet',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildDetailsCard(context, project),
              const SizedBox(height: 24),

              // Script
              Text(
                'Script',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.script,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(height: 1.6),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.text_fields,
                            size: 16,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${project.script.length} caractères',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Actions
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _isDuplicating
                        ? null
                        : () => _duplicateProject(project),
                    icon: _isDuplicating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.copy),
                    label: Text(
                      _isDuplicating ? 'Duplication...' : 'Dupliquer',
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Supprimer l\'audio ?'),
                          content: const Text(
                            'Cette action est irréversible. L\'audio sera définitivement supprimé.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Annuler'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.errorColor,
                              ),
                              child: const Text('Supprimer'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && mounted) {
                        await ref
                            .read(audioProjectsProvider.notifier)
                            .deleteProject(widget.projectId);
                        if (context.mounted) {
                          context.go('/history');
                        }
                      }
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Supprimer'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, AudioProjectStatus status) {
    final (color, text, icon) = switch (status) {
      AudioProjectStatus.completed => (
        AppTheme.successColor,
        'Terminé',
        Icons.check_circle,
      ),
      AudioProjectStatus.processing => (
        AppTheme.warningColor,
        'En cours',
        Icons.hourglass_empty,
      ),
      AudioProjectStatus.failed => (AppTheme.errorColor, 'Échec', Icons.error),
      AudioProjectStatus.draft => (
        AppTheme.textMuted,
        'Brouillon',
        Icons.edit_note,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingCard(BuildContext context) {
    return Card(
      color: AppTheme.warningColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Génération en cours...',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Votre audio est en cours de création. Cette opération peut prendre quelques minutes.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String? errorMessage) {
    return Card(
      color: AppTheme.errorColor.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
            const SizedBox(height: 16),
            Text(
              'La génération a échoué',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.errorColor,
              ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
                ElevatedButton.icon(
                    onPressed: _isRetrying
                      ? null
                      : () => _retryGeneration(widget.projectId),
                  icon: _isRetrying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(_isRetrying ? 'En cours...' : 'Réessayer'),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, AudioProject project) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildDetailRow(
              context,
              icon: Icons.language,
              label: 'Langue',
              value:
                  '${_getFlagEmoji(project.language)} ${AppConstants.languageNames[project.language]}',
            ),
            const Divider(height: 24),
            _buildDetailRow(
              context,
              icon: Icons.person,
              label: 'Voix',
              value:
                  AppConstants.voiceGenderNames[project.voiceGender] ??
                  project.voiceGender,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              context,
              icon: Icons.sentiment_satisfied,
              label: 'Ton',
              value: AppConstants.toneNames[project.tone] ?? project.tone,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              context,
              icon: Icons.music_note,
              label: 'Musique',
              value:
                  AppConstants.musicStyleNames[project.musicStyle] ??
                  project.musicStyle,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              context,
              icon: Icons.timer,
              label: 'Durée',
              value: project.actualDuration != null
                  ? '${project.actualDuration}s (cible: ${project.targetDuration}s)'
                  : '${project.targetDuration}s (cible)',
            ),
            if (project.creditsUsed != null) ...[
              const Divider(height: 24),
              _buildDetailRow(
                context,
                icon: Icons.toll,
                label: 'Crédits utilisés',
                value: '${project.creditsUsed!.toStringAsFixed(2)} minutes',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
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
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.textMuted),
              ),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
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

