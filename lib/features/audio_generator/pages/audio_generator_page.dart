import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/audio_provider.dart';
import '../widgets/script_input.dart';
import '../widgets/voice_options.dart';
import '../widgets/music_options.dart';
import '../widgets/generation_preview.dart';

class AudioGeneratorPage extends ConsumerStatefulWidget {
  const AudioGeneratorPage({super.key});

  @override
  ConsumerState<AudioGeneratorPage> createState() => _AudioGeneratorPageState();
}

class _AudioGeneratorPageState extends ConsumerState<AudioGeneratorPage> {
  int _currentStep = 0;
  bool _isGenerating = false;
  String? _errorMessage;

  Future<void> _handleGenerate() async {
    final formState = ref.read(audioFormStateProvider);
    
    if (!ref.read(audioFormStateProvider.notifier).isValid) {
      setState(() {
        _errorMessage = 'Veuillez entrer un script valide';
      });
      return;
    }

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      await ref.read(audioProjectsProvider.notifier)
          .createAndGenerate(formState);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audio en cours de génération...'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        context.go('/dashboard');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la génération: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(audioFormStateProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text('Créer un audio'),
        actions: [
          TextButton.icon(
            onPressed: () {
              ref.read(audioFormStateProvider.notifier).reset();
              setState(() {
                _currentStep = 0;
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Réinitialiser'),
          ),
        ],
      ),
      body: Row(
        children: [
          // Left side: Form steps
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress indicator
                  _buildProgressIndicator(),
                  const SizedBox(height: 32),

                  // Error message
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppTheme.errorColor, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: AppTheme.errorColor),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => setState(() => _errorMessage = null),
                            color: AppTheme.errorColor,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Step content
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildCurrentStep(),
                  ),

                  const SizedBox(height: 32),

                  // Navigation buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentStep > 0)
                        OutlinedButton.icon(
                          onPressed: () => setState(() => _currentStep--),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Précédent'),
                        )
                      else
                        const SizedBox.shrink(),
                      
                      if (_currentStep < 2)
                        ElevatedButton.icon(
                          onPressed: () => setState(() => _currentStep++),
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Suivant'),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: _isGenerating ? null : _handleGenerate,
                          icon: _isGenerating
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.auto_fix_high),
                          label: Text(_isGenerating ? 'Génération...' : 'Générer l\'audio'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Right side: Preview
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                border: Border(
                  left: BorderSide(color: AppTheme.borderColor),
                ),
              ),
              child: GenerationPreview(formState: formState),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final steps = ['Script', 'Voix', 'Musique'];
    
    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          return Expanded(
            child: Container(
              height: 2,
              color: index ~/ 2 < _currentStep
                  ? AppTheme.primaryColor
                  : AppTheme.borderColor,
            ),
          );
        }
        
        final stepIndex = index ~/ 2;
        final isActive = stepIndex == _currentStep;
        final isCompleted = stepIndex < _currentStep;
        
        return GestureDetector(
          onTap: () => setState(() => _currentStep = stepIndex),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.primaryColor
                  : isCompleted
                      ? AppTheme.primaryColor.withValues(alpha: 0.1)
                      : AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive || isCompleted
                    ? AppTheme.primaryColor
                    : AppTheme.borderColor,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isCompleted)
                  Icon(
                    Icons.check,
                    size: 16,
                    color: AppTheme.primaryColor,
                  )
                else
                  Text(
                    '${stepIndex + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : AppTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(width: 8),
                Text(
                  steps[stepIndex],
                  style: TextStyle(
                    color: isActive
                        ? Colors.white
                        : isCompleted
                            ? AppTheme.primaryColor
                            : AppTheme.textSecondary,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return const ScriptInput(key: ValueKey('script'));
      case 1:
        return const VoiceOptions(key: ValueKey('voice'));
      case 2:
        return const MusicOptions(key: ValueKey('music'));
      default:
        return const SizedBox.shrink();
    }
  }
}
