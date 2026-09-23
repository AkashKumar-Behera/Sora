import 'package:test/test.dart';
import 'package:cloudbeatz_audio_extractor/cloudbeatz_audio_extractor.dart';

void main() {
  group('cloudbeatz_audio_extractor tests', () {
    test('ExtractedAudioStream model serialization and codec parsing', () {
      final stream = ExtractedAudioStream(
        itag: 140,
        codec: AudioCodec.mp4a,
        bitrate: 128000,
        durationMs: 180000,
        loudnessDb: -2.5,
        url: 'https://rr1---sn-audio.googlevideo.com/test',
        sizeBytes: 4500000,
      );

      expect(stream.itag, equals(140));
      expect(stream.codec, equals(AudioCodec.mp4a));
      expect(stream.url, contains('googlevideo.com'));

      final json = stream.toJson();
      final fromJson = ExtractedAudioStream.fromJson(json);

      expect(fromJson.itag, equals(140));
      expect(fromJson.codec, equals(AudioCodec.mp4a));
      expect(fromJson.bitrate, equals(128000));
    });

    test('ExtractedStreamResult stream selection priorities (iOS vs Android)', () {
      final opusStream = ExtractedAudioStream(
        itag: 251,
        codec: AudioCodec.opus,
        bitrate: 160000,
        durationMs: 180000,
        loudnessDb: -2.0,
        url: 'https://stream.opus',
        sizeBytes: 5000000,
      );

      final aacStream = ExtractedAudioStream(
        itag: 140,
        codec: AudioCodec.mp4a,
        bitrate: 128000,
        durationMs: 180000,
        loudnessDb: -2.0,
        url: 'https://stream.m4a',
        sizeBytes: 4000000,
      );

      final result = ExtractedStreamResult(
        isPlayable: true,
        streams: [opusStream, aacStream],
      );

      // On iOS (enforceAac = true), it must pick AAC (itag 140) to prevent native AVPlayer crash
      final iosStream = result.getHighestQuality(enforceAac: true);
      expect(iosStream?.codec, equals(AudioCodec.mp4a));
      expect(iosStream?.itag, equals(140));

      // On Android/Windows (enforceAac = false), it can pick Opus (itag 251)
      final androidStream = result.getHighestQuality(enforceAac: false);
      expect(androidStream?.itag, equals(251));
    });
  });
}
