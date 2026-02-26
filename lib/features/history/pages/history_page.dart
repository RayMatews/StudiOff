import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/audio_provider.dart';
import '../../../models/audio_project.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(audioProjectsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text('Historique des audios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(audioProjectsProvider),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: projects.when(
        data: (projectList) {
          if (projectList.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildProjectList(context, ref, projectList);
        },
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
                onPressed: () => ref.invalidate(audioProjectsProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/generate'),
        icon: const Icon(Icons.add),
        label: const Text('Nouvel audio'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: AppTheme.textMuted,
            ),
            const SizedBox(height: 24),
            Text(
              'Aucun audio généré',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vos audios générés apparaîtront ici.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textMuted,
                  ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.push('/generate'),
              icon: const Icon(Icons.add),
              label: const Text('Créer mon premier audio'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectList(
    BuildContext context,
    WidgetRef ref,
    List<AudioProject> projects,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _HistoryCard(project: project),
        );
      },
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final AudioProject project;

  const _HistoryCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/audio/${project.id}'),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Status icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getStatusColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getStatusIcon(),
                color: _getStatusColor(),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          project.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      _buildStatusBadge(context),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    project.script.length > 100
                        ? '${project.script.substring(0, 100)}...'
                        : project.script,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Tags row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTag(context, '🌐 ${project.language.toUpperCase()}'),
                      _buildTag(context, '⏱️ ${project.targetDuration}s'),
                      _buildTag(context, '🎵 ${project.musicStyle}'),
                      _buildTag(context, '🗣️ ${project.voiceGender}'),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Footer row
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(project.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textMuted,
                            ),
                      ),
                      const Spacer(),

                      // Actions
                      if (project.status == AudioProjectStatus.completed) ...[
                        IconButton(
                          icon: const Icon(Icons.play_circle_outline),
                          onPressed: () => context.push('/audio/${project.id}'),
                          tooltip: 'Écouter',
                          color: AppTheme.primaryColor,
                        ),
                        IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () => context.push('/audio/${project.id}'),
                          tooltip: 'Télécharger MP3',
                          color: AppTheme.successColor,
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: () => context.push('/audio/${project.id}'),
                          tooltip: 'Voir détails',
                        ),
                      ],
                      if (project.status == AudioProjectStatus.processing)
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusText(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _getStatusColor(),
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Text(
        label,
        softWrap: false,
        overflow: TextOverflow.visible,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  Color _getStatusColor() {
    switch (project.status) {
      case AudioProjectStatus.completed:
        return AppTheme.successColor;
      case AudioProjectStatus.processing:
        return AppTheme.warningColor;
      case AudioProjectStatus.failed:
        return AppTheme.errorColor;
      case AudioProjectStatus.draft:
        return AppTheme.textMuted;
    }
  }

  IconData _getStatusIcon() {
    switch (project.status) {
      case AudioProjectStatus.completed:
        return Icons.check_circle;
      case AudioProjectStatus.processing:
        return Icons.hourglass_empty;
      case AudioProjectStatus.failed:
        return Icons.error;
      case AudioProjectStatus.draft:
        return Icons.edit_note;
    }
  }

  String _getStatusText() {
    switch (project.status) {
      case AudioProjectStatus.completed:
        return 'Terminé';
      case AudioProjectStatus.processing:
        return 'En cours...';
      case AudioProjectStatus.failed:
        return 'Échec';
      case AudioProjectStatus.draft:
        return 'Brouillon';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
