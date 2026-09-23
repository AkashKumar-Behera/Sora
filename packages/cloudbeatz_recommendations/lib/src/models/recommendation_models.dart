class RecommendedTrack {
  final String id;
  final String title;
  final String artist;
  final String thumbnailUrl;
  final int durationSeconds;

  RecommendedTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.thumbnailUrl,
    this.durationSeconds = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'thumbnailUrl': thumbnailUrl,
        'durationSeconds': durationSeconds,
      };

  factory RecommendedTrack.fromJson(Map<String, dynamic> json) =>
      RecommendedTrack(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        artist: json['artist'] ?? '',
        thumbnailUrl: json['thumbnailUrl'] ?? '',
        durationSeconds: json['durationSeconds'] ?? 0,
      );
}

class DiscoveryShelf {
  final String title;
  final List<RecommendedTrack> tracks;

  DiscoveryShelf({
    required this.title,
    this.tracks = const [],
  });
}
