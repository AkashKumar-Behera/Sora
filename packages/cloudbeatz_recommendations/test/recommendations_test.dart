import 'package:test/test.dart';
import 'package:cloudbeatz_recommendations/cloudbeatz_recommendations.dart';

void main() {
  group('cloudbeatz_recommendations tests', () {
    test('RecommendedTrack serialization', () {
      final track = RecommendedTrack(
        id: 'rec123',
        title: 'Blinding Lights',
        artist: 'The Weeknd',
        thumbnailUrl: 'https://i.ytimg.com/vi/rec123/hqdefault.jpg',
        durationSeconds: 200,
      );

      expect(track.id, equals('rec123'));
      expect(track.durationSeconds, equals(200));

      final json = track.toJson();
      final fromJson = RecommendedTrack.fromJson(json);

      expect(fromJson.id, equals('rec123'));
      expect(fromJson.title, equals('Blinding Lights'));
    });
  });
}
