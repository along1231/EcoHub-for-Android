import 'package:flutter_test/flutter_test.dart';
import 'package:ecohub_android/models/api_parser.dart';

void main() {
  test('parses unified recommends with both recommend and category sections', () {
    final home = ApiParser.parseHome({
      'banners': [],
      'recommends': [
        {
          'id': 'rec_1',
          'kind': 'recommend',
          'title': '院线热映',
          'items': [
            {'id': 101, 'name': '热映甲'},
          ],
        },
        {
          'id': 'cat_1',
          'kind': 'category',
          'title': '电影',
          'nav': {'id': 1, 'pid': 0, 'name': '电影', 'show': true},
          'items': [
            {'id': 102, 'name': '电影乙'},
          ],
          'hot': [
            {'id': 103, 'name': '热播丙'},
          ],
        },
      ],
      'content': [
        {
          'nav': {'id': 1, 'pid': 0, 'name': '电影', 'show': true},
          'movies': [
            {'id': 102, 'name': '电影乙'},
          ],
          'hot': [],
        },
      ],
    });

    expect(home.content.length, 2);
    expect(home.content[0].isCategory, isFalse);
    expect(home.content[0].displayTitle, '院线热映');
    expect(home.content[0].movies.map((m) => m.id), [101]);

    expect(home.content[1].isCategory, isTrue);
    expect(home.content[1].displayTitle, '电影');
    expect(home.content[1].nav.id, 1);
    expect(home.content[1].movies.map((m) => m.id), [102]);
    expect(home.content[1].hot.map((m) => m.id), [103]);
  });

  test('falls back to legacy content on v3.1.6 server without recommends', () {
    final home = ApiParser.parseHome({
      'banners': [],
      'content': [
        {
          'nav': {'id': 2, 'pid': 0, 'name': '剧集', 'show': true},
          'movies': [
            {'id': 201, 'name': '剧集甲'},
          ],
          'hot': [],
        },
      ],
    });

    expect(home.content.length, 1);
    expect(home.content[0].isCategory, isTrue);
    expect(home.content[0].displayTitle, '剧集');
    expect(home.content[0].movies.map((m) => m.id), [201]);
  });

  test('combines v3.1.7 recommends and legacy content categories', () {
    final home = ApiParser.parseHome({
      'banners': [],
      'recommends': [
        {
          'id': 'rec_old',
          'title': '豆瓣高分',
          'items': [
            {'id': 301, 'name': '高分甲'},
          ],
        },
      ],
      'content': [
        {
          'nav': {'id': 3, 'pid': 0, 'name': '动漫', 'show': true},
          'movies': [
            {'id': 302, 'name': '动漫乙'},
          ],
          'hot': [],
        },
      ],
    });

    expect(home.content.length, 2);
    expect(home.content[0].isCategory, isFalse);
    expect(home.content[0].displayTitle, '豆瓣高分');
    expect(home.content[1].isCategory, isTrue);
    expect(home.content[1].displayTitle, '动漫');
  });
}
