import 'dart:convert';
import 'package:dio/dio.dart';
import 'models/search_models.dart';

class MusicSearchService {
  final Dio _dio;

  MusicSearchService({Dio? dio}) : _dio = dio ?? Dio();

  /// Fetches live autocomplete search suggestions as the user types
  Future<List<String>> getSearchSuggestions(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final response = await _dio.get(
        'https://suggestqueries.google.com/complete/search',
        queryParameters: {
          'client': 'youtube',
          'ds': 'yt',
          'q': query,
        },
        options: Options(
          responseType: ResponseType.plain,
          receiveTimeout: const Duration(seconds: 2),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final raw = response.data.toString();
        // Remove JSONP wrapper: window.google.ac.h( [...] )
        final startIndex = raw.indexOf('(');
        final endIndex = raw.lastIndexOf(')');
        if (startIndex != -1 && endIndex != -1) {
          final jsonString = raw.substring(startIndex + 1, endIndex);
          final dynamic parsed = jsonDecode(jsonString);
          if (parsed is List && parsed.length > 1 && parsed[1] is List) {
            final List suggestions = parsed[1] as List;
            return suggestions
                .map((item) => (item as List)[0].toString())
                .toList();
          }
        }
      }
    } catch (_) {}
    return [];
  }

  /// Search music, albums, artists using Piped/Invidious public API endpoints
  Future<SearchResponse> search(
    String query, {
    SearchItemType? filterType,
  }) async {
    final suggestions = await getSearchSuggestions(query);
    final List<SearchResultItem> results = [];

    final endpoints = [
      'https://api.piped.private.coffee/search',
      'https://pipedapi.kavin.rocks/search',
    ];

    for (final base in endpoints) {
      try {
        final filterParam = filterType != null ? filterType.name : 'music_songs';
        final res = await _dio.get(
          base,
          queryParameters: {
            'q': query,
            'filter': filterParam,
          },
          options: Options(
            receiveTimeout: const Duration(seconds: 3),
            sendTimeout: const Duration(seconds: 3),
          ),
        );

        if (res.statusCode == 200 && res.data != null) {
          final items = res.data['items'] as List? ?? [];
          for (final item in items) {
            final url = item['url']?.toString() ?? '';
            final videoId = url.replaceFirst('/watch?v=', '');
            final title = item['title']?.toString() ?? '';
            final uploader = item['uploaderName']?.toString();
            final thumb = item['thumbnail']?.toString() ?? '';
            final durationSec = item['duration'];

            results.add(
              SearchResultItem(
                id: videoId,
                title: title,
                subtitle: uploader,
                artist: uploader,
                duration: durationSec != null ? '$durationSec' : null,
                thumbnailUrl: thumb,
                type: SearchItemType.song,
              ),
            );
          }

          if (results.isNotEmpty) break;
        }
      } catch (_) {
        continue;
      }
    }

    return SearchResponse(
      query: query,
      items: results,
      suggestions: suggestions,
    );
  }
}
