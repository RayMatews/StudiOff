import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/theme/app_theme.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String? audioUrl;
  final String title;
  final bool showWaveform;
  final bool compact;

  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
    this.title = '',
    this.showWaveform = true,
    this.compact = false,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupPlayer();
  }

  void _setupPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _playerState = state);
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() => _duration = duration);
      }
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() => _position = position);
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (widget.audioUrl == null) return;

    setState(() => _isLoading = true);

    try {
      if (_playerState == PlayerState.playing) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(UrlSource(widget.audioUrl!));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de lecture: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _seek(double value) async {
    final position = Duration(milliseconds: value.toInt());
    await _audioPlayer.seek(position);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.audioUrl == null) {
      return _buildDisabledState();
    }

    if (widget.compact) {
      return _buildCompactPlayer();
    }

    return _buildFullPlayer();
  }

  Widget _buildDisabledState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.music_off, color: AppTheme.textMuted, size: 24),
          const SizedBox(width: 12),
          Text(
            'Audio non disponible',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMuted,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactPlayer() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPlayButton(size: 36),
        const SizedBox(width: 8),
        Text(
          _formatDuration(_position),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
        ),
        const SizedBox(width: 4),
        Text(
          '/ ${_formatDuration(_duration)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textMuted,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
        ),
      ],
    );
  }

  Widget _buildFullPlayer() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.05),
            AppTheme.secondaryColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          // Title
          if (widget.title.isNotEmpty) ...[
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
          ],

          // Waveform placeholder
          if (widget.showWaveform) ...[
            _buildWaveform(),
            const SizedBox(height: 16),
          ],

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Skip back
              IconButton(
                onPressed: () async {
                  final newPosition = _position - const Duration(seconds: 10);
                  await _audioPlayer.seek(
                    newPosition.isNegative ? Duration.zero : newPosition,
                  );
                },
                icon: const Icon(Icons.replay_10),
                iconSize: 28,
                color: AppTheme.textSecondary,
              ),

              const SizedBox(width: 8),

              // Play/Pause
              _buildPlayButton(size: 56),

              const SizedBox(width: 8),

              // Skip forward
              IconButton(
                onPressed: () async {
                  final newPosition = _position + const Duration(seconds: 10);
                  if (newPosition < _duration) {
                    await _audioPlayer.seek(newPosition);
                  }
                },
                icon: const Icon(Icons.forward_10),
                iconSize: 28,
                color: AppTheme.textSecondary,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress bar
          Row(
            children: [
              Text(
                _formatDuration(_position),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                    activeTrackColor: AppTheme.primaryColor,
                    inactiveTrackColor: AppTheme.borderColor,
                    thumbColor: AppTheme.primaryColor,
                    overlayColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: _position.inMilliseconds.toDouble(),
                    min: 0,
                    max: _duration.inMilliseconds.toDouble().clamp(1, double.infinity),
                    onChanged: _seek,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _formatDuration(_duration),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textMuted,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton({required double size}) {
    final isPlaying = _playerState == PlayerState.playing;

    return GestureDetector(
      onTap: _isLoading ? null : _togglePlayPause,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _isLoading
            ? const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              )
            : Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: size * 0.5,
              ),
      ),
    );
  }

  Widget _buildWaveform() {
    // Animated waveform visualization
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(30, (index) {
          final progress = _duration.inMilliseconds > 0
              ? _position.inMilliseconds / _duration.inMilliseconds
              : 0.0;
          final isActive = index / 30 <= progress;
          final height = (20 + (index % 5) * 8).toDouble();

          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 4,
            height: height,
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.primaryColor
                  : AppTheme.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}
