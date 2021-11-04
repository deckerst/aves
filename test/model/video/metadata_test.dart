import 'package:aves/model/video/metadata.dart';
import 'package:test/test.dart';

void main() {
  test('Video date parsing', () {
    expect(VideoMetadataFormatter.parseVideoDate('2011-05-08T03:46+09:00'), DateTime(2011, 5, 8, 3, 46).millisecondsSinceEpoch);
    expect(VideoMetadataFormatter.parseVideoDate('UTC 2021-05-30 19:14:21'), DateTime(2021, 5, 30, 19, 14, 21).millisecondsSinceEpoch);
  });
}
