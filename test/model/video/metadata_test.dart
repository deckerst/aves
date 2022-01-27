import 'package:aves/model/video/metadata.dart';
import 'package:test/test.dart';

void main() {
  test('Video date parsing', () {
    final localOffset = DateTime.now().timeZoneOffset;

    expect(VideoMetadataFormatter.parseVideoDate('2011-05-08T03:46+09:00'), DateTime(2011, 5, 7, 18, 46).add(localOffset).millisecondsSinceEpoch);
    expect(VideoMetadataFormatter.parseVideoDate('UTC 2021-05-30 19:14:21'), DateTime(2021, 5, 30, 19, 14, 21).millisecondsSinceEpoch);
    expect(VideoMetadataFormatter.parseVideoDate('2021/10/31 21:23:17'), DateTime(2021, 10, 31, 21, 23, 17).millisecondsSinceEpoch);
    expect(VideoMetadataFormatter.parseVideoDate('2021-09-10T7:14:49 pmZ'), DateTime(2021, 9, 10, 19, 14, 49).millisecondsSinceEpoch);
  });
}
