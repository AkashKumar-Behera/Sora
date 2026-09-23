import 'package:test/test.dart';
import 'package:cloudbeatz_playlists/cloudbeatz_playlists.dart';

void main() {
  group('cloudbeatz_playlists tests', () {
    test('ParsedPlaylist & PlaylistTrack models serialization', () {
      final track = PlaylistTrack(
        id: 'track1',
        title: 'Song 1',
        artist: 'Artist 1',
        thumbnailUrl: 'https://i.ytimg.com/vi/track1/hqdefault.jpg',
        durationSeconds: 195,
      );

      final playlist = ParsedPlaylist(
        id: 'PL999',
        title: 'Workout Beats',
        description: 'High energy tracks',
        uploader: 'CloudBeatz Curators',
        thumbnailUrl: 'https://i.ytimg.com/vi/thumb/hqdefault.jpg',
        trackCount: 1,
        tracks: [track],
      );

      expect(playlist.id, equals('PL999'));
      expect(playlist.tracks.length, equals(1));
      expect(playlist.tracks.first.title, equals('Song 1'));

      final json = playlist.toJson();
      expect(json['id'], equals('PL999'));
      expect((json['tracks'] as List).length, equals(1));
    });
  });
}
