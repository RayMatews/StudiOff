enum AudioProjectStatus {
  draft,
  processing,
  completed,
  failed,
}

class AudioProject {
  final String id;
  final String userId;
  final String title;
  final String script;
  final String language;
  final String voiceGender;
  final String voiceId;
  final String tone;
  final int targetDuration;
  final String musicStyle;
  final String? musicTrackId;
  final AudioProjectStatus status;
  final String? voiceFileUrl;
  final String? musicFileUrl;
  final String? outputFileUrl;
  final String? outputFileUrlWav;
  final int? actualDuration;
  final double? creditsUsed;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? completedAt;

  const AudioProject({
    required this.id,
    required this.userId,
    required this.title,
    required this.script,
    required this.language,
    required this.voiceGender,
    required this.voiceId,
    required this.tone,
    required this.targetDuration,
    required this.musicStyle,
    this.musicTrackId,
    this.status = AudioProjectStatus.draft,
    this.voiceFileUrl,
    this.musicFileUrl,
    this.outputFileUrl,
    this.outputFileUrlWav,
    this.actualDuration,
    this.creditsUsed,
    this.errorMessage,
    required this.createdAt,
    this.completedAt,
  });

  factory AudioProject.fromJson(Map<String, dynamic> json) {
    return AudioProject(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      script: json['script'] as String,
      language: json['language'] as String,
      voiceGender: json['voiceGender'] as String,
      voiceId: json['voiceId'] as String? ?? '',
      tone: json['tone'] as String,
      targetDuration: json['targetDuration'] as int,
      musicStyle: json['musicStyle'] as String,
      musicTrackId: json['musicTrackId'] as String?,
      status: _parseStatus(json['status'] as String?),
      voiceFileUrl: json['voiceFileUrl'] as String?,
      musicFileUrl: json['musicFileUrl'] as String?,
      outputFileUrl: json['outputFileUrl'] as String?,
      outputFileUrlWav: json['outputFileUrlWav'] as String?,
      actualDuration: json['actualDuration'] as int?,
      creditsUsed: (json['creditsUsed'] as num?)?.toDouble(),
      errorMessage: json['errorMessage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'script': script,
      'language': language,
      'voiceGender': voiceGender,
      'voiceId': voiceId,
      'tone': tone,
      'targetDuration': targetDuration,
      'musicStyle': musicStyle,
      'musicTrackId': musicTrackId,
      'status': status.name,
      'voiceFileUrl': voiceFileUrl,
      'musicFileUrl': musicFileUrl,
      'outputFileUrl': outputFileUrl,
      'outputFileUrlWav': outputFileUrlWav,
      'actualDuration': actualDuration,
      'creditsUsed': creditsUsed,
      'errorMessage': errorMessage,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  static AudioProjectStatus _parseStatus(String? status) {
    switch (status) {
      case 'processing':
        return AudioProjectStatus.processing;
      case 'completed':
        return AudioProjectStatus.completed;
      case 'failed':
        return AudioProjectStatus.failed;
      default:
        return AudioProjectStatus.draft;
    }
  }

  AudioProject copyWith({
    String? id,
    String? userId,
    String? title,
    String? script,
    String? language,
    String? voiceGender,
    String? voiceId,
    String? tone,
    int? targetDuration,
    String? musicStyle,
    String? musicTrackId,
    AudioProjectStatus? status,
    String? voiceFileUrl,
    String? musicFileUrl,
    String? outputFileUrl,
    String? outputFileUrlWav,
    int? actualDuration,
    double? creditsUsed,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return AudioProject(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      script: script ?? this.script,
      language: language ?? this.language,
      voiceGender: voiceGender ?? this.voiceGender,
      voiceId: voiceId ?? this.voiceId,
      tone: tone ?? this.tone,
      targetDuration: targetDuration ?? this.targetDuration,
      musicStyle: musicStyle ?? this.musicStyle,
      musicTrackId: musicTrackId ?? this.musicTrackId,
      status: status ?? this.status,
      voiceFileUrl: voiceFileUrl ?? this.voiceFileUrl,
      musicFileUrl: musicFileUrl ?? this.musicFileUrl,
      outputFileUrl: outputFileUrl ?? this.outputFileUrl,
      outputFileUrlWav: outputFileUrlWav ?? this.outputFileUrlWav,
      actualDuration: actualDuration ?? this.actualDuration,
      creditsUsed: creditsUsed ?? this.creditsUsed,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class AudioGenerationRequest {
  final String script;
  final String language;
  final String voiceGender;
  final String tone;
  final int targetDuration;
  final String musicStyle;
  final String? title;

  const AudioGenerationRequest({
    required this.script,
    required this.language,
    required this.voiceGender,
    required this.tone,
    required this.targetDuration,
    required this.musicStyle,
    this.title,
  });

  factory AudioGenerationRequest.fromJson(Map<String, dynamic> json) {
    return AudioGenerationRequest(
      script: json['script'] as String,
      language: json['language'] as String,
      voiceGender: json['voiceGender'] as String,
      tone: json['tone'] as String,
      targetDuration: json['targetDuration'] as int,
      musicStyle: json['musicStyle'] as String,
      title: json['title'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'script': script,
      'language': language,
      'voiceGender': voiceGender,
      'tone': tone,
      'targetDuration': targetDuration,
      'musicStyle': musicStyle,
      'title': title,
    };
  }

  AudioGenerationRequest copyWith({
    String? script,
    String? language,
    String? voiceGender,
    String? tone,
    int? targetDuration,
    String? musicStyle,
    String? title,
  }) {
    return AudioGenerationRequest(
      script: script ?? this.script,
      language: language ?? this.language,
      voiceGender: voiceGender ?? this.voiceGender,
      tone: tone ?? this.tone,
      targetDuration: targetDuration ?? this.targetDuration,
      musicStyle: musicStyle ?? this.musicStyle,
      title: title ?? this.title,
    );
  }
}
