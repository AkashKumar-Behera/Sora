import 'package:test/test.dart';
import 'package:cloudbeatz_search/cloudbeatz_search.dart';

void main() {
  group('cloudbeatz_search tests', () {
    test('SearchResultItem serialization and type mapping', () {
      final item = SearchResultItem(
        id: 'track123',
        title: 'Starboy',
        artist: 'The Weeknd',
        subtitle: 'The Weeknd - Topic',
        duration: '230',
        thumbnailUrl: 'https://i.ytimg.com/vi/track123/hqdefault.jpg',
        type: SearchItemType.song,
      );

      expect(item.id, equals('track123'));
      expect(item.type, equals(SearchItemType.song));

      final json = item.toJson();
      final fromJson = SearchResultItem.fromJson(json);

      expect(fromJson.id, equals('track123'));
      expect(fromJson.title, equals('Starboy'));
      expect(fromJson.type, equals(SearchItemType.song));
    });
  });
}
