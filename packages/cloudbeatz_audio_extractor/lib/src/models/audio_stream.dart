enum AudioCodec { mp4a, opus }

class ExtractedAudioStream {
  final int itag;
  final AudioCodec codec;
  final int bitrate;
  final int durationMs;
  final int sizeBytes;
  final double loudnessDb;
  final String url;

  ExtractedAudioStream({
    required this.itag,
    required this.codec,
    required this.bitrate,
    required this.durationMs,
    required this.loudnessDb,
    required this.url,
    required this.sizeBytes,
  });

  Map<String, dynamic> toJson() => {
        'itag': itag,
        'codec': codec.name,
        'bitrate': bitrate,
        'durationMs': durationMs,
        'loudnessDb': loudnessDb,
        'url': url,
        'sizeBytes': sizeBytes,
      };

  factory ExtractedAudioStream.fromJson(Map<String, dynamic> json) =>
      ExtractedAudioStream(
        itag: json['itag'] ?? 0,
        codec: (json['codec'] ?? '').toString().contains('mp4a')
            ? AudioCodec.mp4a
            : AudioCodec.opus,
        bitrate: json['bitrate'] ?? 0,
        durationMs: json['durationMs'] ?? 0,
        loudnessDb: (json['loudnessDb'] as num?)?.toDouble() ?? 0.0,
        url: json['url'] ?? '',
        sizeBytes: json['sizeBytes'] ?? 0,
      );
}

class ExtractedStreamResult {
  final bool isPlayable;
  final String statusMessage;
  final List<ExtractedAudioStream> streams;

  ExtractedStreamResult({
    required this.isPlayable,
    this.statusMessage = 'OK',
    this.streams = const [],
  });

  /// Highest quality audio (AAC/M4A if enforceAac is true for iOS, or highest bitrate WebM/Opus otherwise)
  ExtractedAudioStream? getHighestQuality({bool enforceAac = false}) {
    if (streams.isEmpty) return null;
    if (enforceAac) {
      return streams.lastWhere(
        (s) => s.codec == AudioCodec.mp4a || s.itag == 140 || s.itag == 139,
        orElse: () => streams.first,
      );
    }
    try {
      return streams.firstWhere((s) => s.itag == 251);
    } catch (_) {
      try {
        return streams.firstWhere((s) => s.itag == 140);
      } catch (_) {
        return streams.first;
      }
    }
  }

  /// Low bandwidth audio stream for data-saver mode
  ExtractedAudioStream? getLowQuality({bool enforceAac = false}) {
    if (streams.isEmpty) return null;
    if (enforceAac) {
      return streams.lastWhere(
        (s) => s.codec == AudioCodec.mp4a || s.itag == 139,
        orElse: () => streams.first,
      );
    }
    return streams.lastWhere(
      (s) => s.itag == 249 || s.itag == 139,
      orElse: () => streams.first,
    );
  }
}
