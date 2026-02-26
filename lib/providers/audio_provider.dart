import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/app_config.dart';
import '../services/audio_service.dart';
import '../models/audio_project.dart';

// Audio service provider
final audioServiceProvider = Provider<AudioService>((ref) => AudioService());

// User's audio projects provider
class AudioProjectsNotifier
    extends StateNotifier<AsyncValue<List<AudioProject>>> {
  final Ref ref;
  List<AudioProject> _demoProjects = _generateDemoProjects();

  AudioProjectsNotifier(this.ref) : super(const AsyncLoading()) {
    _init();
  }

  Future<void> _init() async {
    if (AppConfig.demoMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      state = AsyncData(_demoProjects);
      return;
    }

    try {
      final audioService = ref.read(audioServiceProvider);
      final projects = await audioService.getUserProjects();
      state = AsyncData(projects);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    await _init();
  }

  Future<AudioProject> createAndGenerate(AudioGenerationRequest request) async {
    if (AppConfig.demoMode) {
      // Simuler la génération en mode démo
      await Future.delayed(const Duration(seconds: 2));
      final newProject = AudioProject(
        id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
        userId: 'demo-user',
        title:
            request.title ??
            'Audio ${DateTime.now().day}/${DateTime.now().month}',
        script: request.script,
        language: request.language,
        voiceGender: request.voiceGender,
        voiceId: 'demo-voice',
        tone: request.tone,
        targetDuration: request.targetDuration,
        musicStyle: request.musicStyle,
        status: AudioProjectStatus.completed,
        actualDuration: request.targetDuration,
        creditsUsed: (request.targetDuration / 60).ceil().toDouble(),
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
      );
      _demoProjects = [newProject, ..._demoProjects];
      state = AsyncData(_demoProjects);
      return newProject;
    }

    final audioService = ref.read(audioServiceProvider);

    // Create project
    final project = await audioService.createProject(request);

    // Start generation
    final generatedProject = await audioService.generateAudio(project.id);

    // Refresh list
    await refresh();

    return generatedProject;
  }

  Future<void> deleteProject(String projectId) async {
    if (AppConfig.demoMode) {
      _demoProjects = _demoProjects.where((p) => p.id != projectId).toList();
      state = AsyncData(_demoProjects);
      return;
    }

    final audioService = ref.read(audioServiceProvider);
    await audioService.deleteProject(projectId);
    await refresh();
  }

  /// Duplique un projet existant avec un nouveau titre
  Future<AudioProject> duplicateProject(AudioProject original) async {
    final request = AudioGenerationRequest(
      script: original.script,
      language: original.language,
      voiceGender: original.voiceGender,
      tone: original.tone,
      targetDuration: original.targetDuration,
      musicStyle: original.musicStyle,
      title: '${original.title} (copie)',
    );

    if (AppConfig.demoMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      final newProject = AudioProject(
        id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
        userId: 'demo-user',
        title: request.title!,
        script: request.script,
        language: request.language,
        voiceGender: request.voiceGender,
        voiceId: 'demo-voice',
        tone: request.tone,
        targetDuration: request.targetDuration,
        musicStyle: request.musicStyle,
        status: AudioProjectStatus.draft,
        createdAt: DateTime.now(),
      );
      _demoProjects = [newProject, ..._demoProjects];
      state = AsyncData(_demoProjects);
      return newProject;
    }

    final audioService = ref.read(audioServiceProvider);
    final project = await audioService.createProject(request);
    await refresh();
    return project;
  }

  /// Relance la génération d'un projet échoué
  Future<AudioProject> retryGeneration(String projectId) async {
    if (AppConfig.demoMode) {
      await Future.delayed(const Duration(seconds: 2));
      // Mettre à jour le statut en "completed" pour simuler
      _demoProjects = _demoProjects.map((p) {
        if (p.id == projectId) {
          return p.copyWith(
            status: AudioProjectStatus.completed,
            completedAt: DateTime.now(),
            actualDuration: p.targetDuration,
            creditsUsed: (p.targetDuration / 60).ceil().toDouble(),
          );
        }
        return p;
      }).toList();
      state = AsyncData(_demoProjects);
      return _demoProjects.firstWhere((p) => p.id == projectId);
    }

    final audioService = ref.read(audioServiceProvider);
    final project = await audioService.generateAudio(projectId);
    await refresh();
    return project;
  }
}

// Demo data generator
List<AudioProject> _generateDemoProjects() {
  return [
    AudioProject(
      id: 'demo-1',
      userId: 'demo-user',
      title: 'Promo Soldes d\'été',
      script:
          'Découvrez nos soldes exceptionnelles ! Jusqu\'à -50% sur toute la collection été. Offre valable jusqu\'au 31 juillet.',
      language: 'fr',
      voiceGender: 'female',
      voiceId: 'demo-voice',
      tone: 'dynamic',
      targetDuration: 30,
      musicStyle: 'energetic',
      status: AudioProjectStatus.completed,
      actualDuration: 28,
      creditsUsed: 1,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      completedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    AudioProject(
      id: 'demo-2',
      userId: 'demo-user',
      title: 'Spot Radio - Nouveau produit',
      script:
          'Révolutionnez votre quotidien avec notre nouvelle gamme de produits innovants. Disponible dès maintenant dans tous nos points de vente.',
      language: 'fr',
      voiceGender: 'male',
      voiceId: 'demo-voice',
      tone: 'institutional',
      targetDuration: 30,
      musicStyle: 'corporate',
      status: AudioProjectStatus.completed,
      actualDuration: 32,
      creditsUsed: 1,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      completedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    AudioProject(
      id: 'demo-3',
      userId: 'demo-user',
      title: 'Message d\'accueil téléphonique',
      script:
          'Bonjour et bienvenue chez StudiOff. Nous mettons tout en œuvre pour vous offrir le meilleur service. Veuillez patienter, un conseiller va prendre votre appel.',
      language: 'fr',
      voiceGender: 'female',
      voiceId: 'demo-voice',
      tone: 'neutral',
      targetDuration: 15,
      musicStyle: 'calm',
      status: AudioProjectStatus.processing,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];
}

final audioProjectsProvider =
    StateNotifierProvider<
      AudioProjectsNotifier,
      AsyncValue<List<AudioProject>>
    >((ref) {
      return AudioProjectsNotifier(ref);
    });

// Single project provider (for detail view)
final audioProjectProvider = FutureProvider.family<AudioProject, String>((
  ref,
  projectId,
) async {
  if (AppConfig.demoMode) {
    // En mode démo, chercher dans les projets existants
    await Future.delayed(const Duration(milliseconds: 300));
    final projects = ref.read(audioProjectsProvider);
    return projects.when(
      data: (list) {
        final project = list.where((p) => p.id == projectId).firstOrNull;
        if (project != null) return project;
        throw Exception('Projet non trouvé');
      },
      loading: () => throw Exception('Chargement en cours'),
      error: (e, _) => throw e,
    );
  }

  final audioService = ref.read(audioServiceProvider);
  return audioService.getProject(projectId);
});

// Project status stream provider
final projectStatusProvider = StreamProvider.family<AudioProject, String>((
  ref,
  projectId,
) {
  if (AppConfig.demoMode) {
    // En mode démo, retourner un stream vide ou avec le projet existant
    return ref
        .watch(audioProjectsProvider)
        .when(
          data: (list) {
            final project = list.where((p) => p.id == projectId).firstOrNull;
            if (project != null) {
              return Stream.value(project);
            }
            return Stream.error(Exception('Projet non trouvé'));
          },
          loading: () => const Stream.empty(),
          error: (e, _) => Stream.error(e),
        );
  }

  final audioService = ref.read(audioServiceProvider);
  return audioService.watchProject(projectId);
});

// Audio generation form state
class AudioFormStateNotifier extends StateNotifier<AudioGenerationRequest> {
  AudioFormStateNotifier()
    : super(
        const AudioGenerationRequest(
          script: '',
          language: 'fr',
          voiceGender: 'female',
          tone: 'neutral',
          targetDuration: 30,
          musicStyle: 'corporate',
        ),
      );

  void updateScript(String script) {
    state = state.copyWith(script: script);
  }

  void updateLanguage(String language) {
    state = state.copyWith(language: language);
  }

  void updateVoiceGender(String gender) {
    state = state.copyWith(voiceGender: gender);
  }

  void updateTone(String tone) {
    state = state.copyWith(tone: tone);
  }

  void updateDuration(int duration) {
    state = state.copyWith(targetDuration: duration);
  }

  void updateMusicStyle(String style) {
    state = state.copyWith(musicStyle: style);
  }

  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }

  void reset() {
    state = const AudioGenerationRequest(
      script: '',
      language: 'fr',
      voiceGender: 'female',
      tone: 'neutral',
      targetDuration: 30,
      musicStyle: 'corporate',
    );
  }

  bool get isValid {
    return state.script.trim().isNotEmpty && state.script.length <= 5000;
  }
}

final audioFormStateProvider =
    StateNotifierProvider<AudioFormStateNotifier, AudioGenerationRequest>((
      ref,
    ) {
      return AudioFormStateNotifier();
    });
