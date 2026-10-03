import 'package:aves/ref/bursts.dart';
import 'package:test/test.dart';

void main() {
  test('Realme burst', () {
    expect(BurstPatterns.getKeyForName('IMG20261003081706_BURST000_COVER', [BurstPatterns.realme]), '20261003081706');
    expect(BurstPatterns.getKeyForName('IMG20261003081706_BURST002', [BurstPatterns.realme]), '20261003081706');
  });

  test('Samsung burst', () {
    expect(BurstPatterns.getKeyForName('20151021_072800_006', [BurstPatterns.samsung]), '20151021_072800');
    expect(BurstPatterns.getKeyForName('20151021_072800_007', [BurstPatterns.samsung]), '20151021_072800');
  });

  test('Sony burst', () {
    expect(BurstPatterns.getKeyForName('DSC_0006_BURST20151021072800123', [BurstPatterns.sony]), '20151021072800123');
    expect(BurstPatterns.getKeyForName('DSC_0007_BURST20151021072800123', [BurstPatterns.sony]), '20151021072800123');
  });

  test('Sony predictive capture', () {
    expect(BurstPatterns.getKeyForName('DSCPDC_0002_BURST20180619163426901', [BurstPatterns.sony]), '20180619163426901');
    expect(BurstPatterns.getKeyForName('DSCPDC_0003_BURST20180619163426901_COVER', [BurstPatterns.sony]), '20180619163426901');
  });
}
