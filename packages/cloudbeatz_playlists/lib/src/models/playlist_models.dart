class PlaylistTrack {
  final String id;
  final String title;
  final String artist;
  final String thumbnailUrl;
  final int durationSeconds;

  PlaylistTrack({
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

  factory PlaylistTrack.fromJson(Map<String, dynamic> json) => PlaylistTrack(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        artist: json['artist'] ?? '',
        thumbnailUrl: json['thumbnailUrl'] ?? '',
        durationSeconds: json['durationSeconds'] ?? 0,
      );
}

class ParsedPlaylist {
  final String id;
  final String title;
  final String description;
  final String uploader;
  final String thumbnailUrl;
  final int trackCount;
  final List<PlaylistTrack> tracks;

  ParsedPlaylist({
    required this.id,
    required this.title,
    this.description = '',
    this.uploader = '',
    required this.thumbnailUrl,
    this.trackCount = 0,
    this.tracks = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'uploader': uploader,
        'thumbnailUrl': thumbnailUrl,
        'trackCount': trackCount,
        'tracks': tracks.map((t) => t.toJson()).toList(),
      };
}
