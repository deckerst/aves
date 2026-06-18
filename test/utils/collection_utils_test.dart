import 'package:aves_utils/aves_utils.dart';
import 'package:test/test.dart';

enum _TestEnum { apple, pear, platypus }

void main() {
  test('enum by name', () {
    expect(_TestEnum.values.safeByName('platypus'), _TestEnum.platypus);
    expect(_TestEnum.values.safeByName('_TestEnum.platypus'), _TestEnum.platypus);
    expect(_TestEnum.values.safeByName('_TestEnum.pluribus'), null);
  });

  test('enum by name ignoring case', () {
    expect(_TestEnum.values.safeByName('PlatyPus', ignoreCase: true), _TestEnum.platypus);
    expect(_TestEnum.values.safeByName('_testenum.PlatyPus', ignoreCase: true), _TestEnum.platypus);
    expect(_TestEnum.values.safeByName('_testenum.pluribus', ignoreCase: true), null);
  });
}
