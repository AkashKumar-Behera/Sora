import 'package:dio/dio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'models/audio_stream.dart';

class _CachedStreamEntry {
  final ExtractedStreamResult result;
  final DateTime timestamp;

  _CachedStreamEntry(this.result) : timestamp = DateTime.now();

  bool get isExpired => DateTime.now().difference(timestamp).inMinutes > 180;
}

/// Extractor service providing fast, resilient audio stream URLs.
class AudioStreamProvider {
  static YoutubeExplode? _ytClient;
  static final Map<String, _CachedStreamEntry> _cache = {};

  static YoutubeExplode get _yt {
    _ytClient ??= YoutubeExplode();
    return _ytClient!;
  }

  /// Reset internal persistent YouTube client (useful if IP rotated or network changed)
  static void resetClient() {
    try {
      _ytClient?.close();
    } catch (_) {}
    _ytClient = null;
  }

  /// Clears in-memory stream cache
  static void clearCache() => _cache.clear();

  /// Resolve high-speed audio stream URLs for a given YouTube video ID.
  static Future<ExtractedStreamResult> resolveStream(
    String videoId, {
    String title = '',
    String artist = '',
  }) async {
    // 0. Cache check
    if (_cache.containsKey(videoId)) {
      final entry = _cache[videoId]!;
      if (!entry.isExpired && entry.result.isPlayable) {
        return entry.result;
      }
      _cache.remove(videoId);
    }

    // 1. Direct YouTubeExplode Manifest
    try {
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      final audioStreams = manifest.audioOnly;
      if (audioStreams.isNotEmpty) {
        final result = ExtractedStreamResult(
          isPlayable: true,
          statusMessage: 'OK',
          streams: audioStreams
              .map(
                (e) => ExtractedAudioStream(
                  itag: e.tag,
                  codec: e.audioCodec.contains('mp')
                      ? AudioCodec.mp4a
                      : AudioCodec.opus,
                  bitrate: e.bitrate.bitsPerSecond,
                  durationMs: 0,
                  loudnessDb: 0.0,
                  url: e.url.toString(),
                  sizeBytes: e.size.totalBytes,
                ),
              )
              .toList(),
        );
        _cache[videoId] = _CachedStreamEntry(result);
        return result;
      }
    } catch (_) {
      resetClient();
    }

    // 2. Fallback: Piped API mirrors
    final pipedMirrors = [
      'https://api.piped.private.coffee/streams/$videoId',
      'https://piped.video/api/v1/streams/$videoId',
    ];

    for (final mirror in pipedMirrors) {
      try {
        final dio = Dio();
        final response = await dio.get(
          mirror,
          options: Options(
            receiveTimeout: const Duration(milliseconds: 1500),
            sendTimeout: const Duration(milliseconds: 1500),
          ),
        );

        if (response.statusCode == 200 && response.data != null) {
          final streams = response.data['audioStreams'] as List? ?? [];
          if (streams.isNotEmpty) {
            final target = streams.firstWhere(
              (s) => s['itag'] == 140 || s['format'] == 'M4A',
              orElse: () => streams.first,
            );
            final url = target['url']?.toString();
            if (url != null && url.isNotEmpty) {
              final result = ExtractedStreamResult(
                isPlayable: true,
                statusMessage: 'OK',
                streams: [
                  ExtractedAudioStream(
                    itag: target['itag'] ?? 140,
                    codec: AudioCodec.mp4a,
                    bitrate: target['bitrate'] ?? 128000,
                    durationMs: 0,
                    loudnessDb: 0.0,
                    url: url,
                    sizeBytes: 0,
                  ),
                ],
              );
              _cache[videoId] = _CachedStreamEntry(result);
              return result;
            }
          }
        }
      } catch (_) {
        continue;
      }
    }

    // 3. Fallback: Cobalt resolvers
    final cobaltMirrors = [
      'https://co.wuk.sh',
      'https://api.cobalt.tools',
    ];

    for (final host in cobaltMirrors) {
      try {
        final dio = Dio();
        final response = await dio.post(
          '$host/',
          data: {
            'url': 'https://www.youtube.com/watch?v=$videoId',
            'downloadMode': 'audio',
            'audioFormat': 'mp3',
          },
          options: Options(
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            receiveTimeout: const Duration(milliseconds: 1500),
            sendTimeout: const Duration(milliseconds: 1500),
          ),
        );

        if (response.statusCode == 200 && response.data != null) {
          final streamUrl = response.data['url']?.toString();
          if (streamUrl != null && streamUrl.isNotEmpty) {
            final result = ExtractedStreamResult(
              isPlayable: true,
              statusMessage: 'OK',
              streams: [
                ExtractedAudioStream(
                  itag: 140,
                  codec: AudioCodec.mp4a,
                  bitrate: 320000,
                  durationMs: 0,
                  loudnessDb: 0.0,
                  url: streamUrl,
                  sizeBytes: 0,
                ),
              ],
            );
            _cache[videoId] = _CachedStreamEntry(result);
            return result;
          }
        }
      } catch (_) {
        continue;
      }
    }

    return ExtractedStreamResult(
      isPlayable: false,
      statusMessage: 'Failed to extract audio stream',
    );
  }
}
