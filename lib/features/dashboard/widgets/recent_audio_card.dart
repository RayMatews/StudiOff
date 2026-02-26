import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/audio_project.dart';
import '../../../services/audio_service.dart';

class RecentAudioCard extends StatefulWidget {
  final AudioProject project;

  const RecentAudioCard({super.key, required this.project});

  @override
  State<RecentAudioCard> createState() => _RecentAudioCardState();
}

class _RecentAudioCardState extends State<RecentAudioCard> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getStatusIcon(),
                      color: _getStatusColor(),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.project.title,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _formatDate(widget.project.createdAt),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Tags
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _buildTag(context, widget.project.language.toUpperCase()),
                  _buildTag(context, '${widget.project.targetDuration}s'),
                  _buildTag(context, widget.project.musicStyle),
                ],
              ),
              const SizedBox(height: 12),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
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
              ),
              // Download button if completed
              if (widget.project.status == AudioProjectStatus.completed) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _downloadAudio,
                        icon: const Icon(Icons.download, size: 18),
                        label: const Text('Télécharger'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _togglePlayPause,
                      icon: Icon(
                        _isPlaying
                            ? Icons.pause_circle
                            : Icons.play_circle_outline,
                      ),
                      color: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Text(
        label,
        softWrap: false,
        overflow: TextOverflow.visible,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
      ),
    );
  }

  Color _getStatusColor() {
    switch (widget.project.status) {
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
    switch (widget.project.status) {
      case AudioProjectStatus.completed:
        return Icons.check_circle;
      case AudioProjectStatus.processing:
        return Icons.hourglass_empty;
      case AudioProjectStatus.failed:
        return Icons.error;
      case AudioProjectStatus.draft:
        return Icons.edit;
    }
  }

  String _getStatusText() {
    switch (widget.project.status) {
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

  Future<void> _downloadAudio() async {
    try {
      final audioService = AudioService();
      final downloadUrl = await audioService.getDownloadUrl(widget.project.id);
      if (await canLaunchUrl(Uri.parse(downloadUrl))) {
        await launchUrl(Uri.parse(downloadUrl));
      }
    } catch (e) {
      // Handle error - could show a snackbar
      debugPrint('Download failed: $e');
    }
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        setState(() => _isPlaying = false);
      } else {
        final audioService = AudioService();
        final previewUrl = await audioService.getDownloadUrl(widget.project.id);
        await _audioPlayer.play(UrlSource(previewUrl));
        setState(() => _isPlaying = true);
      }
    } catch (e) {
      debugPrint('Playback failed: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (diff.inDays == 1) {
      return 'Hier';
    } else if (diff.inDays < 7) {
      return 'Il y a ${diff.inDays} jours';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
