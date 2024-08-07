import 'package:aves/model/media/video/metadata.dart';
import 'package:test/test.dart';

void main() {
  test('Video date parsing', () {
    DateTime shiftTimeZoneOffset(DateTime date) {
      // local time zone offset may not be the same across time (because of DST),
      // so we cannot reliably use `DateTime.now().timeZoneOffset`
      return date.add(date.timeZoneOffset);
    }

    expect(VideoMetadataFormatter.parseVideoDate('2011-05-08T03:46+09:00'), shiftTimeZoneOffset(DateTime(2011, 5, 7, 18, 46)).millisecondsSinceEpoch);
    expect(VideoMetadataFormatter.parseVideoDate('UTC 2021-05-30 19:14:21'), DateTime(2021, 5, 30, 19, 14, 21).millisecondsSinceEpoch);
    expect(VideoMetadataFormatter.parseVideoDate('2021/10/31 21:23:17'), DateTime(2021, 10, 31, 21, 23, 17).millisecondsSinceEpoch);
    expect(VideoMetadataFormatter.parseVideoDate('2021-09-10T7:14:49 pmZ'), DateTime(2021, 9, 10, 19, 14, 49).millisecondsSinceEpoch);
    expect(VideoMetadataFormatter.parseVideoDate('2022-01-28T5:07:46 p. m.Z'), DateTime(2022, 1, 28, 17, 7, 46).millisecondsSinceEpoch);
    expect(VideoMetadataFormatter.parseVideoDate('2012-1-1T12:00:00Z'), DateTime(2012, 1, 1, 12, 0, 0).millisecondsSinceEpoch);
    expect(VideoMetadataFormatter.parseVideoDate('2020.10.14'), DateTime(2020, 10, 14).millisecondsSinceEpoch);
    expect(VideoMetadataFormatter.parseVideoDate('2016:11:16 18:00:00'), DateTime(2016, 11, 16, 18, 0, 0).millisecondsSinceEpoch);
  });

  test('Ambiguous date', () {
    expect(VideoMetadataFormatter.isAmbiguousDate('2011-05-08T03:46+09:00'), false);
    expect(VideoMetadataFormatter.isAmbiguousDate('05-08-2011'), true);
  });
}
