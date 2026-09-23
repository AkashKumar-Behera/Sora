import 'package:flutter_test/flutter_test.dart';
import 'package:cloudbeatz/services/stream_service.dart';
import 'package:cloudbeatz/models/playlist.dart';

void main() {
  group('CloudBeatz Logic & Model Integrity Tests', () {
    test('StreamProvider model serialization and format checks', () {
      final audio = Audio(
        itag: 140,
        audioCodec: Codec.mp4a,
        bitrate: 128000,
        duration: 200000,
        loudnessDb: -1.5,
        url: 'https://example.com/audio.m4a',
        size: 5000000,
      );

      expect(audio.itag, equals(140));
      expect(audio.audioCodec, equals(Codec.mp4a));
      expect(audio.url, equals('https://example.com/audio.m4a'));

      final json = audio.toJson();
      final fromJson = Audio.fromJson(json);
      expect(fromJson.itag, equals(140));
      expect(fromJson.bitrate, equals(128000));
    });

    test('Playlist model JSON serialization', () {
      final playlist = Playlist(
        title: 'My Test Playlist',
        playlistId: 'PL12345',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        songCount: '15',
        description: 'Testing playlist serialization',
      );

      expect(playlist.title, equals('My Test Playlist'));
      expect(playlist.playlistId, equals('PL12345'));

      final json = playlist.toJson();
      expect(json['title'], equals('My Test Playlist'));
      expect(json['playlistId'], equals('PL12345'));
      expect(json['itemCount'], equals('15'));
    });
  });
}
