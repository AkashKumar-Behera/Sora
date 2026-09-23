import 'package:dio/dio.dart';
import 'models/recommendation_models.dart';

class RecommendationService {
  final Dio _dio;

  RecommendationService({Dio? dio}) : _dio = dio ?? Dio();

  /// Fetches similar / next tracks (Radio mode) based on currently playing videoId
  Future<List<RecommendedTrack>> getRelatedTracks(String videoId) async {
    final mirrors = [
      'https://api.piped.private.coffee/streams/$videoId',
      'https://piped.video/api/v1/streams/$videoId',
    ];

    for (final mirror in mirrors) {
      try {
        final res = await _dio.get(
          mirror,
          options: Options(
            receiveTimeout: const Duration(seconds: 3),
            sendTimeout: const Duration(seconds: 3),
          ),
        );

        if (res.statusCode == 200 && res.data != null) {
          final related = res.data['relatedStreams'] as List? ?? [];
          final results = <RecommendedTrack>[];

          for (final item in related) {
            final url = item['url']?.toString() ?? '';
            final id = url.replaceFirst('/watch?v=', '');
            final title = item['title']?.toString() ?? '';
            final uploader = item['uploaderName']?.toString() ?? '';
            final thumb = item['thumbnail']?.toString() ?? '';
            final dur = item['duration'] as int? ?? 0;

            if (id.isNotEmpty && title.isNotEmpty) {
              results.add(
                RecommendedTrack(
                  id: id,
                  title: title,
                  artist: uploader,
                  thumbnailUrl: thumb,
                  durationSeconds: dur,
                ),
              );
            }
          }

          if (results.isNotEmpty) return results;
        }
      } catch (_) {
        continue;
      }
    }

    return [];
  }

  /// Fetches trending songs feed
  Future<DiscoveryShelf> getTrendingSongs({String region = 'IN'}) async {
    final mirrors = [
      'https://api.piped.private.coffee/trending?region=$region',
      'https://piped.video/api/v1/trending?region=$region',
    ];

    for (final mirror in mirrors) {
      try {
        final res = await _dio.get(
          mirror,
          options: Options(
            receiveTimeout: const Duration(seconds: 3),
          ),
        );

        if (res.statusCode == 200 && res.data != null) {
          final items = res.data as List? ?? [];
          final tracks = <RecommendedTrack>[];

          for (final item in items) {
            final url = item['url']?.toString() ?? '';
            final id = url.replaceFirst('/watch?v=', '');
            final title = item['title']?.toString() ?? '';
            final artist = item['uploaderName']?.toString() ?? '';
            final thumb = item['thumbnail']?.toString() ?? '';
            final dur = item['duration'] as int? ?? 0;

            if (id.isNotEmpty) {
              tracks.add(
                RecommendedTrack(
                  id: id,
                  title: title,
                  artist: artist,
                  thumbnailUrl: thumb,
                  durationSeconds: dur,
                ),
              );
            }
          }

          if (tracks.isNotEmpty) {
            return DiscoveryShelf(title: 'Trending Music', tracks: tracks);
          }
        }
      } catch (_) {
        continue;
      }
    }

    return DiscoveryShelf(title: 'Trending Music', tracks: []);
  }
}
