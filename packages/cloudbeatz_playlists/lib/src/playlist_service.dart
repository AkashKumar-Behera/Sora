import 'package:dio/dio.dart';
import 'models/playlist_models.dart';

class PlaylistService {
  final Dio _dio;

  PlaylistService({Dio? dio}) : _dio = dio ?? Dio();

  /// Fetch playlist tracks by YouTube / Piped playlist ID
  Future<ParsedPlaylist?> getPlaylist(String playlistId) async {
    final cleanId = playlistId.replaceAll('VL', '');
    final mirrors = [
      'https://api.piped.private.coffee/playlists/$cleanId',
      'https://piped.video/api/v1/playlists/$cleanId',
    ];

    for (final mirror in mirrors) {
      try {
        final res = await _dio.get(
          mirror,
          options: Options(
            receiveTimeout: const Duration(seconds: 4),
            sendTimeout: const Duration(seconds: 4),
          ),
        );

        if (res.statusCode == 200 && res.data != null) {
          final data = res.data;
          final title = data['name']?.toString() ?? 'Untitled Playlist';
          final uploader = data['uploader']?.toString() ?? '';
          final thumb = data['thumbnailUrl']?.toString() ?? '';
          final rawTracks = data['relatedStreams'] as List? ?? [];

          final tracks = <PlaylistTrack>[];
          for (final t in rawTracks) {
            final url = t['url']?.toString() ?? '';
            final id = url.replaceFirst('/watch?v=', '');
            final trackTitle = t['title']?.toString() ?? '';
            final artist = t['uploaderName']?.toString() ?? '';
            final trackThumb = t['thumbnail']?.toString() ?? '';
            final duration = t['duration'] as int? ?? 0;

            if (id.isNotEmpty && trackTitle.isNotEmpty) {
              tracks.add(
                PlaylistTrack(
                  id: id,
                  title: trackTitle,
                  artist: artist,
                  thumbnailUrl: trackThumb,
                  durationSeconds: duration,
                ),
              );
            }
          }

          return ParsedPlaylist(
            id: playlistId,
            title: title,
            uploader: uploader,
            thumbnailUrl: thumb,
            trackCount: tracks.length,
            tracks: tracks,
          );
        }
      } catch (_) {
        continue;
      }
    }

    return null;
  }
}
