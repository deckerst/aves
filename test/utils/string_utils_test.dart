import 'package:aves/utils/string_utils.dart';
import 'package:test/test.dart';

void main() {
  test('Sentence case', () {
    expect('XResolution'.toSentenceCase(), 'X Resolution');
    expect('PixelXDimension'.toSentenceCase(), 'Pixel X Dimension');
    expect('FocalPointX'.toSentenceCase(), 'Focal Point X');

    expect('ISOSpeedRatings[1]'.toSentenceCase(), 'ISO Speed Ratings [1]');
    expect('LegacyIPTCDigest'.toSentenceCase(), 'Legacy IPTC Digest');
    expect('DocumentID'.toSentenceCase(), 'Document ID');

    expect('H'.toSentenceCase(), 'H');
    expect('LW[1]'.toSentenceCase(), 'LW [1]');
  });
}
