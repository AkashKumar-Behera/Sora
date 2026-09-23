enum SearchItemType { song, video, album, artist, playlist }

class SearchResultItem {
  final String id;
  final String title;
  final String? subtitle;
  final String? artist;
  final String? duration;
  final String thumbnailUrl;
  final SearchItemType type;

  SearchResultItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.artist,
    this.duration,
    required this.thumbnailUrl,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'artist': artist,
        'duration': duration,
        'thumbnailUrl': thumbnailUrl,
        'type': type.name,
      };

  factory SearchResultItem.fromJson(Map<String, dynamic> json) =>
      SearchResultItem(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        subtitle: json['subtitle'],
        artist: json['artist'],
        duration: json['duration'],
        thumbnailUrl: json['thumbnailUrl'] ?? '',
        type: SearchItemType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => SearchItemType.song,
        ),
      );
}

class SearchResponse {
  final String query;
  final List<SearchResultItem> items;
  final List<String> suggestions;

  SearchResponse({
    required this.query,
    this.items = const [],
    this.suggestions = const [],
  });
}
